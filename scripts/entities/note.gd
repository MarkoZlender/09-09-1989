class_name Note extends Node3D

@export var note_text: String = ""

var note_interacted: bool = false

@onready var note_text_label: Label = %NoteTextLabel
@onready var note_texture: Control = %NoteTexture
@onready var sfx_player: AudioStreamPlayer3D = $SFXPlayer


func _ready() -> void:
	note_text_label.text = note_text

func _on_interact_area_body_entered(body: Node3D) -> void:
	if body is Player:
		note_texture.visible = true
		note_interacted = true
		sfx_player.play()

func _on_destroy_area_body_exited(body: Node3D) -> void:
	if body is Player && note_interacted:
		_play_and_free()

func _on_sfx_finished() -> void:
	queue_free()

func _play_and_free() -> void:
	$SFXPlayer.play()
	$SFXPlayer.connect("finished", Callable(self, "_on_sfx_finished"))
