using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Godot;
using PokeApiNet;

/// <summary>
/// Generate a PokeApi cache with Pokémon info and Pokémon Art
/// </summary>
/// <remarks>
/// <para>Under GNU General Public License v3</para>
/// <para>Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)</para>
/// </remarks>
public partial class PokemonCache : Node
{
	/// <summary>
	/// Emited when a Pokémon Artwork is downloaded
	/// </summary>
	[Signal]
	public delegate void PokemonArtworkDownloadedEventHandler(string pokemonName, Texture pokemonArtwork);

	private Node _globals;

	private PokeApiClient _pokeClient;

	private readonly Dictionary<string, PokedexEntry> _pokeCache = new();
	private readonly ConcurrentDictionary<string, Tuple<int, string>> _pendingArtworks = new();
	private readonly ConcurrentDictionary<string, bool> _currentDownloadingArtworks = new();


	/// <summary>
	/// Returns <c>true</c> if the cache is loaded, <c>false</c> otherwise.
	/// </summary>
	public bool isCacheReady = false;

	/// <summary>
	/// Reference to Pokédex entry data
	/// </summary>
	private struct PokedexEntry
	{
		/// <summary>
		/// Entry number in National Pokédex
		/// </summary>
		public readonly int EntryNumber;
		/// <summary>
		/// Pokémon's name
		/// </summary>
		public readonly string Name;
		/// <summary>
		/// Pokémon's type color
		/// </summary>
		public Color Color;
		/// <summary>
		/// Pokémon's Artwork
		/// </summary>
		public Texture ArtworkTexture;

		public PokedexEntry(int entryNumber, string name, Color color)
		{
			EntryNumber = entryNumber;
			Name = name;
			Color = color;
			ArtworkTexture = null;
		}
	}

	/// <summary>
	/// Reference to Pokémon data (without artwork)
	/// </summary>
	public readonly struct PokemonData
	{
		/// <summary>
		/// Entry number in National Pokédex
		/// </summary>
		public readonly int EntryNumber;
		/// <summary>
		/// Pokémon's name
		/// </summary>
		public readonly string Name;
		/// <summary>
		/// Pokémon's type color
		/// </summary>
		public readonly Color Color;

		public PokemonData(int entryNumber, string name, Color color)
		{
			EntryNumber = entryNumber;
			Name = name;
			Color = color;
		}
	}

	/// <summary>
	/// Gets the number of Pókemons in National Pokédex
	/// </summary>
	public int Count => _pokeCache.Count;


	private string CachePath => _globals.Get("CACHE_PATH").As<string>();

	private string PokedexPathFile => CachePath.PathJoin("pokedex.json");

	private string GetPokemonArtworkPath(int pokemonEntryNumber) => CachePath.PathJoin($"{pokemonEntryNumber:D4}.png");

	// Called when the node enters the scene tree for the first time.
	public override async void _Ready()
	{
		_globals = GetNode("/root/Globals");
		_pokeClient = new();

		if (FileAccess.FileExists(PokedexPathFile))
		{
			GD.Print("Loading from cache");
			LoadCache();
		}
		else
		{
			GD.Print("Getting cache");
			await PreloadCache();
		}

		isCacheReady = true;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (_pendingArtworks.Any())
		{
			var artworkUrls = _pendingArtworks.Keys.ToList().GetRange(0, Math.Min(_pendingArtworks.Count, 4));
			artworkUrls.ForEach(artworkUrl => {
				var pokemonEntryNumber = _pendingArtworks[artworkUrl].Item1;
				var pokemonName = _pendingArtworks[artworkUrl].Item2;
				DownloadPokemonArtwork(artworkUrl, pokemonEntryNumber, pokemonName);
				_pendingArtworks.TryRemove(artworkUrl, out _);
				_currentDownloadingArtworks.TryAdd(pokemonName, true);
			});
		}
	}

	/// <summary>
	/// Loads Pokémon Cache using cache files
	/// </summary>
	/// <returns></returns>
	public async void LoadCache()
	{
		using var file = FileAccess.Open(PokedexPathFile, FileAccess.ModeFlags.Read);
		var parsedJson = new Json();
		if (parsedJson.Parse(file.GetAsText()) != Error.Ok)
		{
			GD.PushError($"error in {PokedexPathFile}:{parsedJson.GetErrorLine}: {parsedJson.GetErrorMessage}");
			await PreloadCache(); // Try to recover info
			return;
		}

		var pokedexData = parsedJson.Data.AsGodotArray();
		foreach (var entry in pokedexData)
		{
			var pokemonEntryNumber = entry.AsGodotDictionary()["entry_number"].As<int>();
			var pokemonName = entry.AsGodotDictionary()["name"].As<string>();
			var pokemonRealName = entry.AsGodotDictionary()["real_name"].As<string>();
			var pokemonColor = Color.FromHtml(entry.AsGodotDictionary()["color"].As<string>());
			var pokeEntry = new PokedexEntry(pokemonEntryNumber, pokemonName, pokemonColor);

			var cachePath = GetPokemonArtworkPath(pokemonEntryNumber);
			if (FileAccess.FileExists(cachePath))
			{
				var image = new Image();
				if (image.Load(cachePath) != Error.Ok)
				{
					GD.PushError($"Cannot load {cachePath}.");
				}


				pokeEntry.ArtworkTexture = ImageTexture.CreateFromImage(image);
			}

			_pokeCache.Add(pokemonName, pokeEntry);
		}
	}

	/// <summary>
	/// Populates Pokémon Cache
	/// </summary>
	public async Task PreloadCache()
	{
		var cacheData = new Godot.Collections.Array();

		// Get national pokedex
		var pokedex = await _pokeClient.GetResourceAsync<Pokedex>("national");
		var pokeSpecies = await _pokeClient.GetResourceAsync(pokedex.PokemonEntries.Select(entry => entry.PokemonSpecies).ToList());
		foreach (var entry in pokedex.PokemonEntries) {
			GD.Print(entry.PokemonSpecies.Name);
			var pokemon = pokeSpecies.FirstOrDefault(sp => sp.Name == entry.PokemonSpecies.Name);
			var pokemonName = pokemon.Names.FirstOrDefault(name => name.Language.Name.Equals("en"));
			var pokemonColor = _globals.Call("get_pokemon_color", pokemon.Color.Name).AsColor();

			_pokeCache.Add(entry.PokemonSpecies.Name, new PokedexEntry(entry.EntryNumber, pokemonName.Name, pokemonColor));
			cacheData.Add(new Godot.Collections.Dictionary()
			{
				{"entry_number", entry.EntryNumber},
				{"name", pokemon.Name},
				{"real_name", pokemonName.Name},
				{"color", pokemonColor.ToHtml()}
			});
		};

		if (!DirAccess.DirExistsAbsolute(CachePath))
		{
			DirAccess.MakeDirAbsolute(CachePath);
		}

		using var file = FileAccess.Open(PokedexPathFile, FileAccess.ModeFlags.Write);
		if (file == null) {
			GD.PushError($"Cannot open {PokedexPathFile}: {FileAccess.GetOpenError()}");
		}
		file.StoreString(Json.Stringify(cacheData));
		file.Flush();

		// Download first pokemon textures
		var pokeData = _pokeCache.Keys.ToList().GetRange(0, 8);
		foreach (var pokemon in pokeData)
		{
			GetPokemonArtwork(pokemon);
		}
	}

	/// <summary>
	/// Checks if Pokémon exists in National Pokédex
	/// </summary>
	/// <returns><c>true</c> if Pokémon exists in National Pokédex, <c>false</c> otherwise</returns>
	public bool HasPokemon(string pokemonName)
	{
		var escapedPokemonName = GetPokemonName(pokemonName);
		return _pokeCache.ContainsKey(escapedPokemonName);
	}

	/// <summary>
	/// Gets the Pokémon entry number in National Pokédex
	/// </summary>
	public int GetPokemonEntryNumber(string pokemonName)
	{
		var escapedPokemonName = GetPokemonName(pokemonName);
		if (_pokeCache.ContainsKey(escapedPokemonName)) {
			var pokeData = _pokeCache[escapedPokemonName];
			return pokeData.EntryNumber;
		}

		return -1;
	}

	/// <summary>
	/// Gets the Pokémon name using entry number in National Pokédex
	/// </summary>
	public string GetPokemonName(int pokemonEntryNumber) {
		return _pokeCache.First(entry => entry.Value.EntryNumber == pokemonEntryNumber).Key;
	}


	/// <summary>
	/// Gets the real Pokémon name using entry number in National Pokédex
	/// </summary>
	public string GetPokemonRealName(int pokemonEntryNumber) {
		return _pokeCache.First(entry => entry.Value.EntryNumber == pokemonEntryNumber).Value.Name;
	}

	/// <summary>
	/// Gets the Pókemon data using name in National Pokédex
	/// </summary>
	public async Task<PokemonData> GetPokemonData(string pokemonName)
	{
		var escapedPokemonName = GetPokemonName(pokemonName);
		var pokeData = _pokeCache[escapedPokemonName];
		return new(pokeData.EntryNumber, escapedPokemonName, pokeData.Color);
	}

	/// <summary>
	/// Gets the Pókemon official artwork
	/// </summary>
	public Texture GetPokemonArtwork(string pokemonName)
	{
		var escapedPokemonName = GetPokemonName(pokemonName);

		var pokeData = _pokeCache[escapedPokemonName];
		if (pokeData.ArtworkTexture == null) {
			var pokemonArtworkPath = GetPokemonArtworkPath(pokeData.EntryNumber);

			if (FileAccess.FileExists(pokemonArtworkPath))
			{
				var image = new Image();
				if (image.Load(pokemonArtworkPath) != Error.Ok)
				{
					GD.PushError($"Cannot load ${pokemonArtworkPath}");
				}

				pokeData.ArtworkTexture = ImageTexture.CreateFromImage(image);
			}
			else
			{
				Task.Run(() => GetPokemonArtwork(pokeData.EntryNumber, escapedPokemonName));
			}
		}

		return pokeData.ArtworkTexture;
	}

	private async Task GetPokemonArtwork(int pokemonEntryNumber, string pokemonName)
	{
		var pokemon = await _pokeClient.GetResourceAsync<Pokemon>(pokemonName);
		var artworkUrl = pokemon.Sprites.Other.OfficialArtwork.FrontDefault;
		if (!_currentDownloadingArtworks.ContainsKey(pokemonName) || !_pendingArtworks.ContainsKey(artworkUrl))
		{
			_pendingArtworks.TryAdd(artworkUrl, new(pokemonEntryNumber, pokemonName));
		}
	}

	private void DownloadPokemonArtwork(string artworkUrl, int pokemonEntryNumber, string pokemonName)
	{
		var request = new PokemonArtworkRequest();
		AddChild(request);

		request.RequestCompleted += OnPokemonArtworkRequestCompleted;
		request.RequestArtwort(artworkUrl, pokemonEntryNumber, pokemonName);
	}

	private void OnPokemonArtworkRequestCompleted(string pokemonName, Texture pokemonArtwork)
	{
		GD.Print($"{pokemonName} artwork downloaded!");
		var pokeData = _pokeCache[pokemonName];
		pokeData.ArtworkTexture = pokemonArtwork;
		_currentDownloadingArtworks.TryRemove(pokemonName, out _);
		EmitSignal("PokemonArtworkDownloaded", pokemonName, pokemonArtwork);
	}

	/// <summary>
	/// Sanitize Pókemon name to use as pokeapi.co
	/// </summary>
	/// <param name="unescapePokemonName"></param>
	/// <returns></returns>
	private static string GetPokemonName(string unescapePokemonName)
	{
		return unescapePokemonName.Replace(" ", "-").Replace("'", "").Replace(".", "").ToLower();
	}
}
