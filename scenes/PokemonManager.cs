using System;
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
public partial class PokemonManager : Node
{
    /// <summary>
    /// Emited when new Pókemon is found
    /// </summary>
    [Signal]
    public delegate void PokemonFoundEventHandler(string pokemonName, int pokemonEntry, Color pokemonColor, string userName, Color userColor);

    /// <summary>
    /// Emited when current Pokémon artwork is donwloaded
    /// </summary>
    [Signal]
    public delegate void PokemonArtworkDownloadedEventHandler(Texture pokemonArtwork);

    private Node _gameSettings;
    private Node _globals;
    private PokemonCache _pokeCache;

    private TwitchClient _twitchClient;

    private int CurrentPokemonEntry => _globals.Get("current_pokemon_entry").As<int>();

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        _gameSettings = GetNode("/root/GameSettings");
        _globals = GetNode("/root/Globals");

        InitializePokemonCache();
        InitializeTwitchClient();
    }

    private void InitializePokemonCache()
    {
        _pokeCache = GetNode<PokemonCache>("/root/PokemonCache");
        _pokeCache.PokemonArtworkDownloaded += OnPokemonArtworkDownloaded;
    }

    private void InitializeTwitchClient() {
        var twitchChannel = _gameSettings.Get("twitch_channel").As<string>();

        try
        {
            var credentials = new ConnectionCredentials(GetTwitchAnonymousUser(), "123456");

            _twitchClient = new();
            _twitchClient.Initialize(credentials, twitchChannel);
            _twitchClient.OnJoinedChannel += OnTwitchChannelJoined;
            _twitchClient.OnMessageReceived += OnTwitchMessageReceived;

            _twitchClient.Connect();
        }
        catch (Exception ex)
        {
            GD.PushError(ex.ToString());
        }
    }

    private void OnTwitchChannelJoined(object sender, OnJoinedChannelArgs e)
    {
        GD.Print($"Connected to {e.Channel}!");
    }

    private void OnTwitchMessageReceived(object sender, OnMessageReceivedArgs e)
    {
        try
        {
            if (e.ChatMessage.ChatReply == null && e.ChatMessage.Message.Split().Length <= 3)
            {
                var pokemonName = e.ChatMessage.Message;
                if (_pokeCache.HasPokemon(pokemonName)) {
                    var pokemon = _pokeCache.GetPokemonData(pokemonName);
                    if (pokemon.EntryNumber > 0 && pokemon.EntryNumber == CurrentPokemonEntry + 1)
                    {
                        GD.Print($"{pokemon.Name} found!");
                        EmitPokemonFoundSignal(pokemon, e.ChatMessage);
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
        if (_pokeCache.GetPokemonEntryNumber(pokemonName) == CurrentPokemonEntry + 1) {
            EmitSignal("PokemonArtworkDownloaded", pokemonArtwork);
        }
    }

    private static string GetTwitchAnonymousUser() {
        int number = (int)(DateTimeOffset.Now.ToUnixTimeMilliseconds() % 1000000);
        return $"justinfan{number}";
    }
}
