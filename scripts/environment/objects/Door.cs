using System.Threading.Tasks;
using Godot;
using Game.Components;
using Game.Globals;

namespace Game.Entities;

public partial class Door : StaticBody3D
{
    [Export(PropertyHint.File, "*.tscn")] 
    public string NextScene { get; private set; }
    
    private InteractComponent _interactComponent;

    public override void _Ready()
    {
        _interactComponent = GetNode<InteractComponent>("InteractComponent");
        //_interactComponent.Interact = Callable.From(() => OnInteract());
    }

    async void OnInteract()
    {
        GD.Print("Interact");
        if (NextScene != "")
        {
            await Global.GameController.Change3DScene(NextScene);
        }
        else
        {
            GD.PrintErr("No next scene set for door");
        }
    }
}
