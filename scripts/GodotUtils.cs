using System;
using System.Linq;
using Godot;

public static class GodotUtils
{
    public static void Log(Node node, params object[] objs)
    {
        GD.Print($"[{node.Name} - {DateTime.Now:G}]: ", objs.Select(obj => obj.ToString()).ToArray().Join());
    }
}