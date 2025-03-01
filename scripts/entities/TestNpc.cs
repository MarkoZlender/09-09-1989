#nullable enable
using System.Threading.Tasks;
using Godot;
using Game.Components;
using DialogueManagerRuntime;

namespace Game.Entities;
public partial class TestNpc : CsgBox3D
{
	private InteractComponent? _interactComponent;
	public override void _Ready()
	{
		_interactComponent = GetNode<InteractComponent>("InteractComponent");
		_interactComponent.InteractionStarted += async () => await OnInteract();
	}

	private async Task OnInteract()
	{
		Resource dialogue = GD.Load<Resource>("res://assets/dialogue/test_dialogue.dialogue");
		DialogueManager.ShowExampleDialogueBalloon(dialogue, "start");
		await ToSignal(DialogueManager.Instance, "dialogue_ended");
		_interactComponent?.EmitInteractionEnded();
	}
}
