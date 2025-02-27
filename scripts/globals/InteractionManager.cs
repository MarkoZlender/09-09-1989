using System.Linq;
using Godot;
using Godot.Collections;
using topdown_adventure.scripts.components;
using topdown_adventure.scripts.entities;

namespace topdown_adventure.scripts.globals;

public partial class InteractionManager : Node
{
    private Array<InteractComponent> _activeAreas;
    private bool _canInteract;
    public Player Player { get; set; }

    public override void _Ready()
    {
        Player = GetTree().GetFirstNodeInGroup("player") as Player;
        Global.InteractionManager = this;
    }

    public override void _PhysicsProcess(double delta)
    {
        if (_activeAreas.Count > 0 && _canInteract)
        {
            _activeAreas = new Array<InteractComponent>(_activeAreas.OrderBy(area => Player.GlobalPosition.DistanceTo(area.GlobalPosition)));
        }
    }

    public void RegisterArea(InteractComponent area)
    {
        _activeAreas.Add(area);
    }
    
    public void UnregisterArea(InteractComponent area)
    {
        _activeAreas.Remove(area);
    }

    private bool SortByDistanceToPlayer(InteractComponent area1, InteractComponent area2)
    {
        var area1Distance = Player.GlobalPosition.DistanceTo(area1.GlobalPosition);
        var area2Distance = Player.GlobalPosition.DistanceTo(area2.GlobalPosition);
        return area1Distance < area2Distance;

    }
}