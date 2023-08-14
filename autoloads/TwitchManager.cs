using System;
using System.Linq;
using Godot;
using TwitchLib.Client;
using TwitchLib.Client.Events;
using TwitchLib.Client.Models;
using static PokemonCache;

/// <summary>
/// Controls twitch message and retrieves Pokémon info
/// </summary>
/// <remarks>
/// <para>Under GNU General Public License v3</para>
/// <para>Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)</para>
/// </remarks>
public partial class TwitchManager : Node
{
    /// <summary>
    /// Emitted when twitch client is connected and pokemon cache is loaded
    /// </summary>
    [Signal]
    public delegate void ManagerReadyEventHandler();

    /// <summary>
    /// Emitted when next Pókemon in Pokédex was found
    /// </summary>
    [Signal]
    public delegate void PokemonFoundEventHandler(string pokemonName, int pokemonEntry, Color pokemonColor, string userName, Color userColor);

    /// <summary>
    /// Emitted when a Pókemon was not found, but exists in Pokédex database
    /// </summary>
    [Signal]
    public delegate void PokemonNotFoundEventHandler();

    /// <summary>
    /// Emitted when current Pokémon artwork is downloaded
    /// </summary>
    [Signal]
    public delegate void PokemonArtworkDownloadedEventHandler(Texture pokemonArtwork);

    private Node _gameSettings;
    private Node _globals;
    private PokemonCache _pokeCache;
    private TwitchClient _twitchClient;

    private int CurrentPokemonEntry => _globals.Get("current_pokemon_entry").As<int>();

    /// <summary>
    /// Returns <c>true</c> if the twitch client is connected and pokemon cache is loaded, <c>false</c> otherwise.
    /// </summary>
    public bool isManagerReady = false;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        _gameSettings = GetNode("/root/GameSettings");
        _gameSettings.Connect("settings_updated", new Callable(this, MethodName.OnGameSettingsUpdated));
        _globals = GetNode("/root/Globals");

        InitializePokemonCache();

        var twitchChannel = _gameSettings.Get("twitch_channel").As<string>();
        InitializeTwitchClient(twitchChannel);
    }

    private void InitializePokemonCache()
    {
        _pokeCache = GetNode<PokemonCache>("/root/PokemonCache");
        _pokeCache.CacheLoaded += OnPokemonCacheLoaded;
        _pokeCache.PokemonArtworkDownloaded += OnPokemonArtworkDownloaded;
    }

    private void InitializeTwitchClient(string twitchChannel)
    {
        try
        {
            if (twitchChannel.Length > 0)
            {
                _twitchClient = new();
                _twitchClient.OnJoinedChannel += OnTwitchChannelJoined;
                _twitchClient.OnMessageReceived += OnTwitchMessageReceived;

                ConnectTwitchClient(twitchChannel);

                if (_pokeCache.isCacheReady)
                {
                    isManagerReady = true;
                    EmitSignal(SignalName.ManagerReady);
                }
            }
        }
        catch (Exception ex)
        {
            GodotUtils.Error(this, ex.ToString());
        }
    }

    private void ConnectTwitchClient(string twitchChannel)
    {
        try
        {
            var credentials = new ConnectionCredentials(GetTwitchAnonymousUser(), "123456");

            _twitchClient.Initialize(credentials, twitchChannel);
            _twitchClient.Connect();
        }
        catch (Exception ex)
        {
            GodotUtils.Error(this, ex.ToString());
        }
    }

    private void OnPokemonCacheLoaded()
    {
        GodotUtils.Log(this, "Cache ready");
        if (_twitchClient != null && _twitchClient.IsConnected)
        {
            isManagerReady = true;
            EmitSignal(SignalName.ManagerReady);
        }
    }

    private void OnTwitchChannelJoined(object sender, OnJoinedChannelArgs e)
    {
        GodotUtils.Log(this, $"Connected to {e.Channel}!");

        if (_pokeCache.isCacheReady)
        {
            isManagerReady = true;
            CallDeferred("emit_signal", SignalName.ManagerReady);
        }
    }

    private void OnTwitchMessageReceived(object sender, OnMessageReceivedArgs e)
    {
        try
        {
            if (e.ChatMessage.ChatReply == null && e.ChatMessage.Message.Split().Length <= 3)
            {
                var pokemonName = e.ChatMessage.Message;
                if (_pokeCache.HasPokemon(pokemonName))
                {
                    var pokemon = _pokeCache.GetPokemonData(pokemonName);
                    if (pokemon.EntryNumber > 0 && pokemon.EntryNumber == CurrentPokemonEntry + 1)
                    {
                        GodotUtils.Log(this, $"{pokemon.Name} found!");
                        EmitPokemonFoundSignal(pokemon, e.ChatMessage);
                    }
                    else
                    {
                        GodotUtils.Log(this, $"{pokemon.Name} is not next");
                        CallDeferred("emit_signal", "PokemonNotFound");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            GD.PrintErr(ex.ToString());
        }
    }

    private void EmitPokemonFoundSignal(PokemonData pokemon, ChatMessage message)
    {
        Color userColor;
        if (message.ColorHex == null)
        {
            var r = new Random();
            userColor = new(r.Next(255), r.Next(255), r.Next(255));
            userColor.Darkened(0.25f);
        }
        else
        {
            userColor = Color.FromString(message.ColorHex, new(0, 0, 0));
        }

        CallDeferred("emit_signal", "PokemonFound", pokemon.Name, pokemon.TypeColor, message.Username, userColor);
    }

    private void OnPokemonArtworkDownloaded(string pokemonName, Texture pokemonArtwork)
    {
        if (_pokeCache.GetPokemonEntryNumber(pokemonName) == CurrentPokemonEntry + 1)
        {
            EmitSignal("PokemonArtworkDownloaded", pokemonArtwork);
        }
    }

    private void OnGameSettingsUpdated(Error result)
    {
        if (result == Error.Ok)
        {
            var twitchChannel = _gameSettings.Get("twitch_channel").As<string>();

            if (_twitchClient != null && !_twitchClient.JoinedChannels.Any(channel => channel.Channel.Equals(twitchChannel)))
            {
                _twitchClient.Disconnect();
                ConnectTwitchClient(twitchChannel);

                if (_pokeCache.isCacheReady)
                {
                    isManagerReady = true;
                    EmitSignal(SignalName.ManagerReady);
                }
            }
            else if (_twitchClient == null)
            {
                InitializeTwitchClient(twitchChannel);
            }
        }
    }

    /// <summary>
    /// Gets a random anonymous user to use with twitch client
    /// </summary>
    private static string GetTwitchAnonymousUser()
    {
        int number = (int)(DateTimeOffset.Now.ToUnixTimeMilliseconds() % 1000000);
        return $"justinfan{number}";
    }
}
