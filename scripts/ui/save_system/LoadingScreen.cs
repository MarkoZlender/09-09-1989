using Game.Globals;
using Godot;

namespace Game.UI;

public partial class LoadingScreen : Control
{
    private Label _progressLabel;

    public override void _Ready()
    {
        _progressLabel = GetNode<Label>("ProgressLabel");
        Global.GameController.LoadProgress += OnSceneLoadUpdate;
    }

    private void OnSceneLoadUpdate(string percent)
    {
        _progressLabel.Text = percent;
    }
}

