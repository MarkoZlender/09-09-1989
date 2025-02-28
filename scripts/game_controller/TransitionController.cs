using Godot;

namespace Game.Globals;
public partial class TransitionController : Control
{
    private ColorRect _colorRect;
    private AnimationPlayer _animationPlayer;

    public override void _Ready()
    {
        _colorRect = GetNode<ColorRect>("ColorRect");
        _animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
    }

    public void Transition(string animation, float seconds)
    {
        _animationPlayer.Play(animation, -1, 1 / seconds);
    }
}

