
extends CharacterBody2D

const MIN_FALL_SPEED: float = 0
var BOUNCE_MULTIPLIER: float = 1

@onready var jumpsound: AudioStreamPlayer2D = $Jumpsound
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0

var can_bounce: bool = true
var max_fall_speed: float = 0.0
var dead: bool = false

# Cancels the next bounce
var cancel_next_bounce: bool = false


func _physics_process(delta: float) -> void:
	if dead:
		return

	# Apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

		# Track maximum falling speed
		if velocity.y > max_fall_speed:
			max_fall_speed = velocity.y

	# Handle jumping
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		max_fall_speed = 0.0
		BOUNCE_MULTIPLIER = 2

		jumpsound.play()

		await get_tree().create_timer(0.5).timeout
		BOUNCE_MULTIPLIER = 1

	# Cancel next bounce when pressing Space in midair
	if Input.is_action_just_pressed("Jump") and not is_on_floor():
		cancel_next_bounce = true

	# Handle horizontal movement
	var direction := Input.get_axis("Left", "Right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Handle bouncing when landing
	if is_on_floor():
		if can_bounce and max_fall_speed > MIN_FALL_SPEED:

			if cancel_next_bounce:
				cancel_next_bounce = false
			else:
				velocity.y = -max_fall_speed * BOUNCE_MULTIPLIER

		max_fall_speed = 0.0

	# Move the character
	move_and_slide()
