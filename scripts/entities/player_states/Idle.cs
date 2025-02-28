using Godot;
using GodotStateCharts;

namespace Game.Entities;

public partial class Idle : Node
{
    private StateChart _stateChart;
    private StateChartState _idleState;
    private Player _player;
    
    public override void _Ready()
    {
        var stateChartNode = GetNode("%StateChart");
        _stateChart = StateChart.Of(stateChartNode);
        _idleState = StateChartState.Of(GetNode("%Idle"));
        _player = Owner as Player;
        _idleState.StatePhysicsProcessing += OnIdleStatePhysicsProcessing;
    }

    private void OnIdleStatePhysicsProcessing(float delta)
    {
        _player.Move(delta);
        if (_player.IsMoving) _stateChart.SendEvent("player_moved");
        //test2
    }
}