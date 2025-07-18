class_name HealthUp extends Collectible

var picked_up: bool = false

@onready var interact_collision: CollisionShape3D = %InteractionCollision
@onready var audio_player: AudioStreamPlayer3D = $AudioPlayer

func _on_interaction_area_body_entered(body:Node3D) -> void:
	if body is Player:
		var player: Player = body as Player
		if player.player_data.health >= player.player_data.max_health:
			return
		player.player_data.health += 10
		Global.signal_bus.player_healed.emit(player.player_data.health)
		audio_player.play()
		picked_up = true
		visible = false
		interact_collision.disabled = true

