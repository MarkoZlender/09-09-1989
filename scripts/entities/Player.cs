using Godot;

namespace Game.Entities;

public partial class Player : CharacterBody3D
{
    [Export]
    public float Speed = 5.0f;
    
    public bool IsMoving;
    private Vector2 _lastFacingDirection;
    private Vector3 _lastDirection;
    private AnimationTree _animationTree;
    private AnimationPlayer _animationPlayer;

    public override void _Ready()
    {
        IsMoving = false;
        _lastFacingDirection = new Vector2(0, 1);
        _animationTree = GetNode<AnimationTree>("AnimationTree");
        _animationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
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
        GD.Print(direction);
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
        MoveAndSlide();
        AnimateMovement();

    }

    private void AnimateMovement() // fallback until they fix errors for AnimationTree
    {
        var inputDirection = Input.GetVector("left", "right", "up", "down");
        var direction = (Transform.Basis * new Vector3(inputDirection.X, 0, inputDirection.Y)).Normalized();
    
        if (direction != Vector3.Zero)
        {
            _lastDirection = direction;

            if (direction.X > 0)
                _animationPlayer.Play("run_right");
            else if (direction.X < 0)
                _animationPlayer.Play("run_left");
            else if (direction.Z > 0)
                _animationPlayer.Play("run_down");
            else if (direction.Z < 0)
                _animationPlayer.Play("run_up");
        }
        else
        {
            if (_lastDirection.X > 0)
                _animationPlayer.Play("idle_right");
            else if (_lastDirection.X < 0)
                _animationPlayer.Play("idle_left");
            else if (_lastDirection.Z > 0)
                _animationPlayer.Play("idle_down");
            else if (_lastDirection.Z < 0)
                _animationPlayer.Play("idle_up");
            else
                _animationPlayer.Play("idle_down");
        }
    }

    private void AnimateMovementAnimationTree()
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