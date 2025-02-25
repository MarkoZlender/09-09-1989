extends AudioStreamPlayer

var _level_audio: LevelAudio
var bgm_stream: int
var footsteps_stream: int

func _ready() -> void:
	play()
	Global.signal_bus.level_audio_loaded.connect(_on_level_audio_loaded)
	Global.signal_bus.player_moved.connect(_on_player_moved)

func _on_level_audio_loaded(level_audio: LevelAudio) -> void:
	if level_audio == null:
		return
	_level_audio = level_audio
	bgm_stream = get_stream_playback().play_stream(_level_audio.bgm, 0, 0, 1.0, 0, "BGM")
	update_volume()

func _on_player_moved(_position: Vector3) -> void:
	footsteps_stream = get_stream_playback().play_stream(_level_audio.footstep_sfx, 0, 10, randf_range(0.7, 1.1), 0, "SFX")
	update_volume()

func update_volume() -> void:
	get_stream_playback().set_stream_volume(bgm_stream, AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM")))
	get_stream_playback().set_stream_volume(footsteps_stream, AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
