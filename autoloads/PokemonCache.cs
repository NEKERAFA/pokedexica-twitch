using System;
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
    /// Emitted when cache is ready to use
    /// </summary>
    [Signal]
    public delegate void CacheLoadedEventHandler();

    /// <summary>
    /// Emitted when a Pokémon Artwork is downloaded
    /// </summary>
    [Signal]
    public delegate void PokemonArtworkDownloadedEventHandler(string pokemonName, Texture pokemonArtwork);

    private Node _globals;
    private PokeApiClient _pokeClient;

    private readonly Dictionary<string, PokedexEntry> _pokeCache = new();
    private readonly HashSet<string> _pendingArtworks = new();

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
        public Color TypeColor;
        /// <summary>
        /// Pokémon's Artwork
        /// </summary>
        public Texture ArtworkTexture;

        public PokedexEntry(int entryNumber, string name, Color typeColor)
        {
            EntryNumber = entryNumber;
            Name = name;
            TypeColor = typeColor;
            ArtworkTexture = null;
        }
    }

    /// <summary>
    /// Reference to Pokémon data (without artwork)
    /// </summary>
    public class PokemonData
    {
        /// <summary>
        /// Entry number in National Pokédex
        /// </summary>
        public int EntryNumber { get; }
        /// <summary>
        /// Pokémon's name
        /// </summary>
        public string Name { get; }
        /// <summary>
        /// Pokémon's type color
        /// </summary>
        public Color TypeColor { get; }

        public PokemonData(int entryNumber, string name, Color typeColor)
        {
            EntryNumber = entryNumber;
            Name = name;
            TypeColor = typeColor;
        }
    }

    /// <summary>
    /// Gets the number of Pókemons in National Pokédex
    /// </summary>
    public int Count => _pokeCache.Count;

    private string CachePath => _globals.Get("CACHE_PATH").As<string>();
    private string PokedexPathFile => CachePath.PathJoin("pokedex.json");

    // Called when the node enters the scene tree for the first time.
    public override async void _Ready()
    {
        _globals = GetNode("/root/Globals");
        _pokeClient = new();

        if (FileAccess.FileExists(PokedexPathFile))
        {
            GodotUtils.Log(this, "Loading from cache...");
            await LoadCache();
        }
        else
        {
            GodotUtils.Log(this, "Getting cache...");
            await PreloadCache();
        }

        GodotUtils.Log(this, "Cache is done!");
        isCacheReady = true;
        CallDeferred("emit_signal", SignalName.CacheLoaded);
    }

    /// <summary>
    /// Loads Pokémon Cache using cache files
    /// </summary>
    /// <returns></returns>
    private async Task LoadCache()
    {
        using var file = FileAccess.Open(PokedexPathFile, FileAccess.ModeFlags.Read);
        var parsedJson = new Json();
        if (parsedJson.Parse(file.GetAsText()) != Error.Ok)
        {
            GodotUtils.Error(this, $"error in {PokedexPathFile}:{parsedJson.GetErrorLine}: {parsedJson.GetErrorMessage}");
            await PreloadCache(); // Try to recover info
            return;
        }

        GodotUtils.Log(this, $"Loading {PokedexPathFile} cache...");

        var pokedexData = parsedJson.Data.AsGodotArray();
        foreach (var entry in pokedexData)
        {
            var key = entry.AsGodotDictionary()["key"].As<string>();
            var entryNumber = entry.AsGodotDictionary()["entry_number"].As<int>();
            var name = entry.AsGodotDictionary()["name"].As<string>();
            var typeColor = Color.FromHtml(entry.AsGodotDictionary()["type_color"].As<string>());
            var pokeEntry = new PokedexEntry(entryNumber, name, typeColor);

            var cacheArtworkPath = GetPokemonArtworkPath(entryNumber);
            if (FileAccess.FileExists(cacheArtworkPath))
            {
                var image = new Image();
                if (image.Load(cacheArtworkPath) != Error.Ok)
                {
                    GodotUtils.Error(this, $"Cannot load {cacheArtworkPath}.");
                }

                pokeEntry.ArtworkTexture = ImageTexture.CreateFromImage(image);
            }

            _pokeCache.Add(key, pokeEntry);
        }

        GodotUtils.Log(this, "Loaded!");
    }

    /// <summary>
    /// Populates Pokémon Cache
    /// </summary>
    private async Task PreloadCache()
    {
        try
        {
            var cacheData = new Godot.Collections.Array();

            // Gets national pokedex
            GodotUtils.Log(this, "Getting national pokedex...");
            var pokedex = await _pokeClient.GetResourceAsync<Pokedex>("national");

            // Gets pokemon species
            GodotUtils.Log(this, "Loading pokemon species...");
            var pokeSpecies = await _pokeClient.GetResourceAsync(pokedex.PokemonEntries.Select(entry => entry.PokemonSpecies).ToList());

            // Adds pokemon species to cache
            foreach (var entry in pokedex.PokemonEntries)
            {
                //GodotUtils.Log(this, $"Added {entry.PokemonSpecies.Name}");
                var pokemon = pokeSpecies.FirstOrDefault(sp => sp.Name == entry.PokemonSpecies.Name);
                var pokemonName = pokemon.Names.FirstOrDefault(name => name.Language.Name.Equals("en"));
                var pokemonColor = _globals.Call("get_pokemon_color", pokemon.Color.Name).AsColor();

                _pokeCache.Add(entry.PokemonSpecies.Name, new PokedexEntry(entry.EntryNumber, pokemonName.Name, pokemonColor));
                cacheData.Add(new Godot.Collections.Dictionary()
                {
                    {"key", entry.PokemonSpecies.Name},
                    {"entry_number", entry.EntryNumber},
                    {"name", pokemonName.Name},
                    {"type_color", pokemonColor.ToHtml()}
                });
            };

            if (!DirAccess.DirExistsAbsolute(CachePath))
            {
                DirAccess.MakeDirAbsolute(CachePath);
            }

            GodotUtils.Log(this, "Saving cache");
            using var file = FileAccess.Open(PokedexPathFile, FileAccess.ModeFlags.Write);
            if (file == null)
            {
                GodotUtils.Error(this, $"Cannot open {PokedexPathFile}: {FileAccess.GetOpenError()}");
            }
            file.StoreString(Json.Stringify(cacheData));
            file.Flush();

            // Download first 8 pokemon textures
            var pokeData = _pokeCache.ToList().GetRange(0, 8);
            foreach (var entry in pokeData)
            {
                GetPokemonArtworkAsync(entry.Value.EntryNumber, entry.Key);
            }
        }
        catch (Exception ex)
        {
            GodotUtils.Error(this, ex.ToString());
        }
    }

    /// <summary>
    /// Gets cache file size in bytes
    /// </summary>
    public ulong GetCacheSize()
    {
        var size = 0ul;

        var dir = DirAccess.Open(CachePath);
        if (dir != null)
        {
            dir.ListDirBegin();
            var fileName = dir.GetNext();
            while (!fileName.Equals(string.Empty))
            {
                if (!dir.CurrentIsDir())
                {
                    using var file = FileAccess.Open(CachePath.PathJoin(fileName), FileAccess.ModeFlags.Read);
                    if (file != null)
                    {
                        size += file.GetLength();
                    }
                    else
                    {
                        GodotUtils.Error(this, $"Cannot open {CachePath.PathJoin(fileName)}: {FileAccess.GetOpenError()}");
                    }
                }
                fileName = dir.GetNext();
            }
            dir.ListDirEnd();
        }
        else
        {
            GodotUtils.Error(this, $"Cannot open {CachePath}: {DirAccess.GetOpenError()}");
        }

        return size;
    }

    /// <summary>
    /// Removes all artwork cache files
    /// </summary>
    public void RemoveUnnecesaryCache()
    {
        var dir = DirAccess.Open(CachePath);
        if (dir != null)
        {
            dir.ListDirBegin();
            var fileName = dir.GetNext();
            while (!fileName.Equals(string.Empty))
            {
                if (!dir.CurrentIsDir() && !fileName.Equals("pokedex.json"))
                {
                    var filePath = CachePath.PathJoin(fileName);
                    if (dir.Remove(filePath) == Error.Ok)
                    {
                        GodotUtils.Log(this, $"Removed {filePath}");
                    }
                    else
                    {
                        GodotUtils.Error(this, $"Cannot remove {filePath}");
                    }
                }
                fileName = dir.GetNext();
            }
            dir.ListDirEnd();
        }
        else
        {
            GodotUtils.Error(this, $"Cannot open {CachePath}: {DirAccess.GetOpenError()}");
        }

        // Invalidates all cache textures
        foreach (var key in _pokeCache.Keys)
        {
            var pokeData = _pokeCache[key];
            pokeData.ArtworkTexture = null;
        }
    }

    /// <summary>
    /// Checks if Pokémon exists in National Pokédex
    /// </summary>
    /// <returns><c>true</c> if Pokémon exists in National Pokédex, <c>false</c> otherwise</returns>
    public bool HasPokemon(string name)
    {
        var key = GetPokemonName(name);
        return _pokeCache.ContainsKey(key);
    }

    /// <summary>
    /// Gets the Pokémon entry number in National Pokédex
    /// </summary>
    public int GetPokemonEntryNumber(string name)
    {
        var key = GetPokemonName(name);
        if (_pokeCache.ContainsKey(key))
        {
            var pokeData = _pokeCache[key];
            return pokeData.EntryNumber;
        }

        return -1;
    }

    /// <summary>
    /// Gets the Pokémon name in National Pokédex
    /// </summary>
    public string GetPokemonName(int entryNumber)
    {
        if (_pokeCache.Values.Any(entry => entry.EntryNumber == entryNumber))
        {
            var pokeData = _pokeCache.Values.First(entry => entry.EntryNumber == entryNumber);
            return pokeData.Name;
        }

        return null;
    }

    /// <summary>
    /// Gets the Pókemon data using name in National Pokédex
    /// </summary>
    public PokemonData GetPokemonData(string pokemonName)
    {
        var key = GetPokemonName(pokemonName);
        if (_pokeCache.ContainsKey(key))
        {
            var pokeData = _pokeCache[key];
            return new(pokeData.EntryNumber, pokeData.Name, pokeData.TypeColor);
        }

        return null;
    }

    private string GetPokemonArtworkPath(int pokemonEntryNumber) => CachePath.PathJoin($"{pokemonEntryNumber:D4}.png");

    /// <summary>
    /// Gets the Pókemon official artwork
    /// </summary>
    public Texture GetPokemonArtwork(string pokemonName)
    {
        try
        {
            var key = GetPokemonName(pokemonName);

            if (_pokeCache.ContainsKey(key))
            {
                var pokeData = _pokeCache[key];
                if (pokeData.ArtworkTexture == null)
                {
                    var pokemonArtworkPath = GetPokemonArtworkPath(pokeData.EntryNumber);

                    if (FileAccess.FileExists(pokemonArtworkPath))
                    {
                        // Get artwork from cache file
                        var image = new Image();
                        if (image.Load(pokemonArtworkPath) != Error.Ok)
                        {
                            GodotUtils.Error(this, $"Cannot load ${pokemonArtworkPath}");
                        }

                        pokeData.ArtworkTexture = ImageTexture.CreateFromImage(image);
                    }
                    else if (!_pendingArtworks.Contains(key))
                    {
                        // Try to download artwork file
                        GetPokemonArtworkAsync(pokeData.EntryNumber, key);
                    }
                }

                return pokeData.ArtworkTexture;
            }
        }
        catch (Exception ex)
        {
            GodotUtils.Error(this, ex.ToString());
        }

        return null;
    }

    private void GetPokemonArtworkAsync(int entryNumber, string key)
    {
        GodotUtils.Log(this, $"Added {key} artwork request!");
        _pendingArtworks.Add(key);
        var request = new PokemonArtworkRequest(_pokeClient, entryNumber, key);
        AddChild(request);
    }

    private void OnPokemonArtworkRequestCompleted(string key, Texture pokemonArtwork)
    {

        GodotUtils.Log(this, $"{key} artwork downloaded");
        var pokeData = _pokeCache[key];
        pokeData.ArtworkTexture = pokemonArtwork;
        _pendingArtworks.Remove(key);
        EmitSignal("PokemonArtworkDownloaded", key, pokemonArtwork);
    }

    /// <summary>
    /// Sanitize Pókemon name to use as pokeapi.co
    /// </summary>
    private static string GetPokemonName(string unescapePokemonName)
    {
        return unescapePokemonName.Replace(" ", "-").Replace("'", "").Replace(".", "").ToLower();
    }
}
