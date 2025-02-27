using Godot;
using GodotStateCharts;

namespace topdown_adventure.scripts.entities.player_states;

public partial class Idle : Node
{
    private StateChart _stateChart;
    private Player _player;
    public override void _Ready()
    {
        var stateChartNode = GetNode<Node>("StateChart");
        _stateChart = StateChart.Of(stateChartNode);
        _player = Owner as Player;
    }

    private void OnIdleStatePhysicsProcessing(float delta)
    {
        _player.Move(delta);
        if (_player.IsMoving) _stateChart.SendEvent("player_moved");
    }
}