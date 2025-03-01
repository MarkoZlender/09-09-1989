using Godot;
using System;
using System.Threading.Tasks;
using Godot.Collections;
using Array = Godot.Collections.Array;


namespace Game.Globals;

public partial class GameController : Node
{
    [Signal]
    public delegate void SceneLoadedEventHandler();
    [Signal]
    public delegate void LoadProgressEventHandler(string percentage);

    [Export(PropertyHint.File, "*.tscn")] 
    public string StartScene { get; private set; } = "res://scenes/ui/main_menu.tscn";
    
    private Node3D _world3D;
    private Node2D _world2D;
    private Control _gui;
    private TransitionController _transitionController;
    private Node3D _current3DScene;
    private Node2D _current2DScene;
    private Control _currentGuiScene;
    

    public async override void _Ready()
    {
        _world3D = GetNode<Node3D>("World3D");
        _world2D = GetNode<Node2D>("World2D");
        _gui = GetNode<Control>("GUI");
        _transitionController = GetNode<TransitionController>("%TransitionController");
        Global.GameController = this;

        if (StartScene.Find("res://scenes/ui") == -1)
        {
            await Change3DScene(StartScene);
        }
        else
        {
            await ChangeGuiScene(StartScene, false, false, false);
        }
    }

    public async Task ChangeGuiScene(
            string newScene,
            bool delete = true,
            bool keepRunning = false,
            bool transition = true,
            string transitionIn = "fade_in",
            string transitionOut = "fade_out",
            float seconds = 1.0f
        )
    {
        _transitionController.Show();
        if (transition)
        {
            _transitionController.Transition(transitionOut, seconds);
        }


        if (IsInstanceValid(_currentGuiScene))
        {
            if (delete)
                _currentGuiScene?.QueueFree();
            else if (keepRunning)
                _currentGuiScene.Visible = false;
            else
                _gui.RemoveChild(_currentGuiScene);
        }
        
        
        if (!string.IsNullOrEmpty(newScene))
        {
            var newInstance = GD.Load<PackedScene>(newScene).Instantiate();
            _gui.AddChild(newInstance);
            _gui.MoveChild(newInstance, 0);
            _currentGuiScene = (Control)newInstance;

            if (transition)
            {
                _transitionController.Transition(transitionIn, seconds);
                await ToSignal(_transitionController.GetNode<AnimationPlayer>("AnimationPlayer"), "animation_finished");
            }
        }

        _transitionController.Hide();
    }
    
    public async Task Change3DScene(
            string newScene,
            bool delete = true,
            bool keepRunning = false,
            bool transition = true,
            string transitionIn = "fade_in",
            string transitionOut = "fade_out",
            float seconds = 1.0f
        )
    {
        await ChangeGuiScene(Global.LoadingScreen);

        if (transition)
        {
            _transitionController.Transition(transitionOut, seconds);
            await ToSignal(_transitionController.GetNode<AnimationPlayer>("AnimationPlayer"), "animation_finished");
        }

        if (_current3DScene != null)
        {
            if (delete)
                _current3DScene.QueueFree();
            else if (keepRunning)
                _current3DScene.Visible = false;
            else
                _world3D.RemoveChild(_current3DScene);
        }

        //LoadSceneThreaded(newScene);
        CallDeferred(nameof(DeferredLoadSceneThreaded), newScene);
        await ToSignal(this, "SceneLoaded");

        Resource newResource = ResourceLoader.LoadThreadedGet(newScene);
        Node newInstance = ((PackedScene)newResource).Instantiate();
        _world3D.AddChild(newInstance);
        _current3DScene = (Node3D)newInstance;

        _transitionController.Transition(transitionIn, seconds);
        await ToSignal(_transitionController.GetNode<AnimationPlayer>("AnimationPlayer"), "animation_finished");

        await ChangeGuiScene("", true, false, true);
    }

    // private void LoadSceneThreaded(string scenePath)
    // {
    //     
    // }

    private async void DeferredLoadSceneThreaded(string scenePath)
    {
        Array progress = [];
        ResourceLoader.LoadThreadedRequest(scenePath);

        while (true)
        {
            ResourceLoader.ThreadLoadStatus status = ResourceLoader.LoadThreadedGetStatus(scenePath, progress);
            var loadProgress = (float)progress[0] * 100f;
            GD.Print($"{Mathf.Floor(loadProgress)}%");
            EmitSignal(SignalName.LoadProgress, $"{Mathf.Floor(loadProgress)}%");

            if (status == ResourceLoader.ThreadLoadStatus.Loaded)
                break;

            await ToSignal(GetTree().CreateTimer(0.001f), "timeout");
        }

        EmitSignal(SignalName.SceneLoaded);
    }
}
