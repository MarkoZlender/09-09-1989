class_name Note extends Node3D

@export var note_text: String = ""

@onready var note_text_label: Label = %NoteTextLabel
@onready var note_texture: Control = %NoteTexture

func _ready() -> void:
	note_text_label.text = note_text

func _on_interact_area_body_entered(body: Node3D) -> void:
	if body is Player:
		note_texture.visible = true

func _on_destroy_area_body_exited(body: Node3D) -> void:
	if body is Player:
		self.queue_free()
