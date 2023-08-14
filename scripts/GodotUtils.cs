using System;
using System.Linq;
using Godot;

/// <summary>
/// Utilites to extend godot funtionalities
/// </summary>
/// <remarks>
/// <para>Under GNU General Public License v3</para>
/// <para>Copyright (C) 2023 - Rafael Alcalde Azpiazu (NEKERAFA)</para>
/// </remarks>
public static class GodotUtils
{
    /// <summary>
    /// Prints a debug message into Godot console.
    /// </summary>
    public static void Log(Node node, params object[] objs)
    {
        GD.Print($"[Info - {node.Name} - {DateTime.Now:G}]: ", objs.Select(obj => obj.ToString()).ToArray().Join());
    }

    /// <summary>
    /// Pushes a warning message into Godot console and OS terminal.
    /// </summary>
    public static void Warning(Node node, params object[] objs)
    {
        GD.PushWarning($"[Warn - {node.Name} - {DateTime.Now:G}]: ", objs.Select(obj => obj.ToString()).ToArray().Join());
    }

    /// <summary>
    /// Pushes a error message into Godot console and OS terminal.
    /// </summary>
    public static void Error(Node node, params object[] objs)
    {
        GD.PushError($"[Error - {node.Name} - {DateTime.Now:G}]: ", objs.Select(obj => obj.ToString()).ToArray().Join());
    }
}