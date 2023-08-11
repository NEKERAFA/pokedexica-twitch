using System;
using System.Threading.Tasks;
using Godot;
using PokeApiNet;

/// <summary>
/// Create a HttpRequest for download a Pókemon artwork
/// </summary>
/// <remarks>
/// <para>Under GNU General Public License v3</para>
/// <para>Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)</para>
/// </remarks>
public partial class PokemonArtworkRequest : Node
{
	/// <summary>
	/// Emited when a request is completed
	/// </summary>
	[Signal]
	public delegate void RequestCompletedEventHandler(string key, Texture artwork);

	private PokeApiClient _pokeClient;

	private Node _globals;

	private HttpRequest _request;
	private int _entryNumber;
	private string _key;

	private string CachePath => _globals.Get("CACHE_PATH").As<string>();

	private string GetPokemonArtworkPath(int entryNumber) => CachePath.PathJoin($"{entryNumber:D4}.png");

	/// <summary>
	/// Creates request on the underlying <see cref="HttpRequest"/>. See <seealso cref="HttpRequest.Request(string, string[], HttpClient.Method, string)"/> for return value.
	/// </summary>
	public PokemonArtworkRequest(PokeApiClient pokeClient, int entryNumber, string key)
	{
		_pokeClient = pokeClient;
		_entryNumber = entryNumber;
		_key = key;

	}

    // Called when the node enters the scene tree for the first time.
    public override async void _Ready()
	{
		try
		{
			_globals = GetNode("/root/Globals");
		
			GD.Print($"{Name}: Trying to download {_key} artwork");
			var pokemon = await _pokeClient.GetResourceAsync<Pokemon>(_key);
			var artworkUrl = pokemon.Sprites.Other.OfficialArtwork.FrontDefault;

			var httpRequest = new HttpRequest();
			AddChild(httpRequest);

			httpRequest.RequestCompleted += OnRequestCompleted;
			if (httpRequest.Request(artworkUrl) != Error.Ok)
			{
				GD.PushError($"{Name}: Cannot download {artworkUrl}");
			}
		}
		catch (Exception ex)
		{
			GD.PushError(ex.ToString());
		}
	}

	private void OnRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
	{
		if (result != (long)HttpRequest.Result.Success)
		{
			GD.PushError("Image couldn't be downloaded. Try a different image.");
		}

		if (!DirAccess.DirExistsAbsolute(CachePath))
		{
			DirAccess.MakeDirAbsolute(CachePath);
		}

		var filePathCache = GetPokemonArtworkPath(_entryNumber);
		if (!FileAccess.FileExists(filePathCache))
		{
			using var file = FileAccess.Open(filePathCache, FileAccess.ModeFlags.Write);
			file.StoreBuffer(body);
			file.Flush();
		}

		var image = new Image();
		if (image.LoadPngFromBuffer(body) != Error.Ok)
		{
			GD.PushError("Couldn't load the image.");
		}

		var artworkTexture = ImageTexture.CreateFromImage(image);

		EmitSignal("RequestCompleted", _key, artworkTexture);
	}
}
