class_name Tooth extends CollectibleRigidBody3D

var picked_up: bool = false

@onready var interact_collision: CollisionShape3D = %InteractionCollision
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer	

func _on_interaction_area_body_entered(body:Node3D) -> void:
	if body is Player:
		Global.signal_bus.item_rigid_body_collected.emit(self)
		audio_player.play()
		picked_up = true
		visible = false
		interact_collision.disabled = true