using Game.Entities;
using Game.Globals;

namespace Godot.Components;

public partial class InteractComponent : Area3D
{
    //public virtual async void Interact() {}
    public Callable Interact;

    public override void _Ready()
    {
        BodyEntered += OnBodyEntered;
        BodyExited += OnBodyExited;
    }
    private void OnBodyEntered(Node3D body)
    {
        if (body is Player) Global.InteractionManager.RegisterArea(this);
    }
    
    private void OnBodyExited(Node3D body)
    {
        if (body is Player) Global.InteractionManager.UnregisterArea(this);
    }
}
