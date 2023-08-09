using Godot;

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
	public delegate void RequestCompletedEventHandler(string pokemonName, Texture pokemonArtwork);

	private Node _globals;

	private HttpRequest _request;
	private int _pokemonEntryNumber;
	private string _pokemonName;

	private string CachePath => _globals.Get("CACHE_PATH").As<string>();

    private string GetPokemonArtworkPath(int pokemonEntryNumber) => CachePath.PathJoin($"{pokemonEntryNumber:D4}.png");

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
	{
		_globals = GetNode("/root/Globals");
	}

	/// <summary>
	/// Creates request on the underlying <see cref="HttpRequest"/>. See <seealso cref="HttpRequest.Request(string, string[], HttpClient.Method, string)"/> for return value.
	/// </summary>
	public Error RequestArtwort(string artworkUrl, int pokemonEntryNumber, string pokemonName)
	{
		_pokemonEntryNumber = pokemonEntryNumber;
		_pokemonName = pokemonName;

		var httpRequest = new HttpRequest();
		AddChild(httpRequest);

		httpRequest.RequestCompleted += OnRequestCompleted;
		return httpRequest.Request(artworkUrl);
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

		var filePathCache = GetPokemonArtworkPath(_pokemonEntryNumber);
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

		EmitSignal("RequestCompleted", _pokemonName, artworkTexture);
		QueueFree();
	}
}
