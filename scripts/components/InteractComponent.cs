using Godot;
using topdown_adventure.scripts.entities;

namespace topdown_adventure.scripts.components;

public partial class InteractComponent : Area3D
{
    public Callable Interact;

    private void OnBodyEntered(Node3D body)
    {
        if (body is Player) Global.InteractionManager.RegisterArea(this);
    }
    
    private void OnBodyExited(Node3D body)
    {
        if (body is Player) Global.InteractionManager.UnregisterArea(this);
    }
}