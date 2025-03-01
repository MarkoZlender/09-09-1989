using Game.Entities;
using Game.Globals;
using Godot;

namespace Game.Components;

public partial class InteractComponent : Area3D
{
    //public virtual async void Interact() {}
    [Signal]
    public delegate void InteractionStartedEventHandler();
    [Signal]
    public delegate void InteractionEndedEventHandler();

    public override void _Ready()
    {
        BodyEntered += OnBodyEntered;
        BodyExited += OnBodyExited;
    }

    public void EmitInteractionStarted()
    {
        EmitSignal(nameof(InteractionStarted));
    }
    public void EmitInteractionEnded()
    {
        EmitSignal(nameof(InteractionEnded));
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
