using Godot;

namespace Game.Entities;

public partial class Player : CharacterBody3D
{
    [Export]
    public float Speed = 5.0f;
    
    public bool IsMoving;
    private Vector2 _lastFacingDirection;
    private AnimationTree _animationTree;

    public override void _Ready()
    {
        IsMoving = false;
        _lastFacingDirection = new Vector2(0, 1);
        _animationTree = GetNode<AnimationTree>("AnimationTree");
    }

    // public override void _PhysicsProcess(double delta)
    // {
    //     Move(delta);
    // }

    public void Move(double delta)
    {
        var velocity = Velocity;
        if (!IsOnFloor()) velocity += GetGravity() * (float)delta;
        var inputDirection = Input.GetVector("left", "right", "up", "down");
        var direction = (Transform.Basis * new Vector3(inputDirection.X, 0, inputDirection.Y)).Normalized();
        if (direction != Vector3.Zero)
        {
            IsMoving = true;
            velocity.X = direction.X * Speed;
            velocity.Z = direction.Z * Speed;
        }
        else
        {
            IsMoving = false;
            velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
            velocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);
            
        }
        Velocity = velocity;
        GD.Print(Velocity);
        MoveAndSlide();
        AnimateMovement();

    }

    private void AnimateMovement()
    {
        var idle = Velocity == Vector3.Zero;
        var blendPosition = new Vector2(Velocity.X, Velocity.Z).Normalized();

        if (!idle)
        {
            _lastFacingDirection = blendPosition;
        }

        _animationTree.Set("parameters/Run/blend_position", _lastFacingDirection);
        _animationTree.Set("parameters/Idle/blend_position", _lastFacingDirection);
    }

}