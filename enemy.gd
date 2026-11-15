
extends CharacterBody2D
func _ready() -> void:
	add_to_group("Enemies")


@export var speed: float = 100.0

var direction: int = 1

@onready var sprite = $AnimatedSprite2D


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		get_tree().call_deferred("reload_current_scene")


func _physics_process(delta: float) -> void:

	# Apply gravity
	if not is_on_floor():
		velocity.y += 980.0 * delta

	# Move horizontally
	velocity.x = speed * direction

	# Check for ground ahead
	if is_on_floor():

		var space_state = get_world_2d().direct_space_state

		var query = PhysicsRayQueryParameters2D.create(
			global_position + Vector2(direction * 20, 0),
			global_position + Vector2(direction * 20, 50)
		)

		query.exclude = [self]

		var result = space_state.intersect_ray(query)

		# Turn around if there is no ground
		if not result:
			direction *= -1

			# Flip sprite
			sprite.flip_h = direction < 0

	move_and_slide()
	

func _on_enemy_detector_body_entered(body: Node2D) -> void:
	if body != self and body.is_in_group("Enemies"):
		direction *= -1
		sprite.flip_h = direction < 0
