extends AudioStreamPlayer


@onready var bgm: AudioStreamOggVorbis = preload("res://assets/sounds/bgm/dungeon_theme.ogg")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()
	get_stream_playback().play_stream(bgm)
	Global.signal_bus.player_moved.connect(_on_player_moved)

func _on_player_moved(_position: Vector3) -> void:
	get_stream_playback().play_stream(preload("res://assets/sounds/sfx/footstep-on-stone-4.wav"), 0, 10, randf_range(0.7, 1.1))

