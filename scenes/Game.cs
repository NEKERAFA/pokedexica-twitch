using Godot;
using PokeApiNet;

public partial class Game : Control
{
    private PokeApiClient pokeClient;

	public override async void _Ready()
	{
		pokeClient = new();
		Pokemon poke = await pokeClient.GetResourceAsync<Pokemon>(1);
		GD.Print(poke.Sprites.Other.OfficialArtwork.FrontDefault);

		HttpRequest httpRequest = new();
		AddChild(httpRequest);

		httpRequest.RequestCompleted += HttpRequestCompleted;

		// Perform the HTTP request. The URL below returns a PNG image as of writing.
		Error error = httpRequest.Request(poke.Sprites.Other.OfficialArtwork.FrontDefault);
		if (error != Error.Ok)
		{
			GD.PushError("An error occurred in the HTTP request.");
		}
	}

	private void HttpRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
	{
		if (result != (long)HttpRequest.Result.Success)
		{
			GD.PushError("Image couldn't be downloaded. Try a different image.");
		}

		GD.Print(responseCode);
		GD.Print(body.Length);

		var image = new Image();
		if (image.LoadPngFromBuffer(body) == Error.Ok)
		{
			var texture = ImageTexture.CreateFromImage(image);

			// Display the image in a TextureRect node.
			var textureRect = GetNode<TextureRect>("PokemonPanel/PokemonTexture");
			textureRect.Texture = texture;
		}
		else
		{
			GD.PushError("Couldn't load the image.");
		}
	}
}
