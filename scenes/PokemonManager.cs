using System;
using System.Linq;
using Godot;
using PokeApiNet;
using TwitchLib.Client;
using TwitchLib.Client.Events;
using TwitchLib.Client.Models;
using System.Collections.Generic;

/// <summary>
/// Controls twitch message, retrieve PokeApi info and cache Pokémon Art
/// </summary>
/// <remarks>
/// <para>Under GNU General Public License v3</para>
/// <para>Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)</para>
/// </remarks>
public partial class PokemonManager : Node
{
    [Signal]
    delegate void PokemonFoundEventHandler(string name, string color, Texture2D texture, string username, string usercolor);

    private static Node gameSettings = null;
    private static Node globals = null;

    private PokeApiClient pokeClient;
    private TwitchClient twitchClient;

    private int CurrentPokemonEntry => globals.Get("current_pokemon_entry").As<int>();

    public override void _Ready()
    {
        gameSettings ??= GetNode("/root/GameSettings");
        globals ??= GetNode("/root/Globals");

        InitializePokeApiClient();
        InitializeTwitchClient();
    }

    private void InitializePokeApiClient() {
        pokeClient = new();
    }

    private void InitializeTwitchClient() {
        var twitchChannel = gameSettings.Get("twitch_channel").AsString();

        var credentials = new ConnectionCredentials(GetTwitchRandomUser(), "123456");

        twitchClient = new();
        twitchClient.Initialize(credentials, twitchChannel);
        twitchClient.OnMessageReceived += OnTwitchMessageReceived;

        twitchClient.Connect();
    }

    private async void OnTwitchMessageReceived(object sender, OnMessageReceivedArgs e)
    {
        try
        {
            if (e.ChatMessage.Message.Split().Length <= 2)
            {
                var pokemon = await pokeClient.GetResourceAsync<PokemonSpecies>(e.ChatMessage.Message);
                var pokedexEntry = pokemon.PokedexNumbers.First(pokedex => pokedex.Pokedex.Name.Equals("national"));

                if (pokedexEntry.EntryNumber == CurrentPokemonEntry + 1)
                {
                    GD.Print($"{pokemon.Name} found!");
                    var artUrl = (await pokeClient.GetResourceAsync<Pokemon>(pokemon.Id)).Sprites.Other.OfficialArtwork.FrontDefault;
                }
            }
        }
        catch (Exception ex)
        {
            GD.PrintErr(ex.ToString());
        }
    }

    private static string GetTwitchRandomUser() {
        int number = (int)(DateTimeOffset.Now.ToUnixTimeMilliseconds() % 1000000);
        return $"justinfan{number}";
    }
}
