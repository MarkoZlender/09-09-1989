using Godot;
using Godot.Collections;

public partial class Global : Node
{
    public const string SlotButtonScene = "res://scenes/ui/save_system/slot_button.tscn";
    public const string MainMenuScene = "res://scenes/ui/main_menu.tscn";
    public const string StartingLevel = "res://scenes/levels/test_level.tscn";
    public const string LoadingScreen = "res://scenes/ui/save_system/loading_screen.tscn";

    [Export] public Array<Node> SavableGlobals = [];

    public static topdown_adventure.scripts.globals.InteractionManager InteractionManager { get; set; }
}
