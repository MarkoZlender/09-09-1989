using Game.Entities;

namespace Godot.Components;

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