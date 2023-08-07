using System;
using Godot;
using TwitchLib.Client;
using TwitchLib.Client.Events;
using TwitchLib.Client.Models;

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

    public override void _Ready()
	{
        var gameSettings = GetNode("/root/GameSettings");
        int number = (int)(DateTimeOffset.Now.ToUnixTimeMilliseconds() % 100000);
        GD.Print($"justinfan{number}");
        GD.Print($"{gameSettings.Get("twitch_channel").AsString()}");
        ConnectionCredentials credentials = new($"justinfan{number}", "123456");
        client = new();
        client.Initialize(credentials, gameSettings.Get("twitch_channel").AsString());
        client.OnConnected += Client_OnConnected;
        client.OnMessageReceived += Client_OnMessageReceived;

        client.Connect();
    }

    private void Client_OnConnected(object sender, OnConnectedArgs e)
    {
        GD.Print($"Connected to '{e.AutoJoinChannel}'");
    }

    private void Client_OnMessageReceived(object sender, OnMessageReceivedArgs e)
    {
        GD.Print(e.ChatMessage.Username, e.ChatMessage.ColorHex, e.ChatMessage.Message);
    }
}
