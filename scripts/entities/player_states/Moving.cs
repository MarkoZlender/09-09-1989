using Godot;
using GodotStateCharts;

namespace Game.Entities;

public partial class Moving : Node
{
    private StateChart _stateChart;
    private StateChartState _movingState;
    private Player _player;
    
    public override void _Ready()
    {
        var stateChartNode = GetNode("%StateChart");
        _stateChart = StateChart.Of(stateChartNode);
        _movingState = StateChartState.Of(GetNode("%Moving"));
        _player = Owner as Player;
        _movingState.StatePhysicsProcessing += OnMovingStatePhysicsProcessing;
    }

    private void OnMovingStatePhysicsProcessing(float delta)
    {
        _player.Move(delta);
        if (!_player.IsMoving) _stateChart.SendEvent("player_stopped");
    }
}
