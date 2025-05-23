extends CharacterBody2D

const SPEED = 150.0

func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO

	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	input_vector = input_vector.normalized()  # Pour éviter de dépasser la vitesse max en diagonale

	velocity = input_vector * SPEED
	move_and_slide()
