using Godot;
using TwitchLib.Client;

/// <summary>
/// Controls Twitch chat
/// </summary>
/// <remarks>
/// <para>Under GNU General Public License v3</para>
/// <para>Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)</para>
/// </remarks>
public partial class TwitchManager : Node
{
    private TwitchClient client;

    public override async void _Ready()
	{
        client = new();
    }
}
