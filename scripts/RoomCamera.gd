extends Camera2D

@export var transition_speed: float = 0.5

var current_room: Area2D = null
var target_position: Vector2 = Vector2.ZERO
var is_transitioning: bool = false

func _ready() -> void:
	make_current()
	var rooms = get_tree().get_nodes_in_group("rooms")
	for room in rooms:
		room.connect("body_entered", Callable(self, "_on_room_entered").bind(room))
	call_deferred("_find_initial_room", get_parent().global_position)

func _find_initial_room(player_pos: Vector2) -> void:
	var rooms = get_tree().get_nodes_in_group("rooms")
	for room in rooms:
		if _is_position_in_room(player_pos, room):
			_set_camera_to_room(room)
			current_room = room
			break

func _is_position_in_room(pos: Vector2, room: Area2D) -> bool:
	var collision_shape = room.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is RectangleShape2D:
		var shape = collision_shape.shape as RectangleShape2D
		var room_rect = Rect2(
			room.global_position - shape.extents,
			shape.extents * 2
		)
		return room_rect.has_point(pos)
	return false

func _on_room_entered(body: Node2D, room: Area2D) -> void:
	if body == get_parent() and room != current_room:
		_transition_to_room(room)
		current_room = room

func _transition_to_room(room: Area2D) -> void:
	var collision_shape = room.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is RectangleShape2D:
		target_position = room.global_position
		is_transitioning = true
		var tween = create_tween()
		tween.tween_property(self, "global_position", target_position, transition_speed)
		tween.tween_callback(Callable(self, "_finished_transition"))

func _finished_transition() -> void:
	is_transitioning = false
	_set_camera_to_room(current_room)

func _set_camera_to_room(room: Area2D) -> void:
	var collision_shape = room.get_node("CollisionShape2D")
	if not collision_shape or not (collision_shape.shape is RectangleShape2D):
		return
	var shape = collision_shape.shape as RectangleShape2D
	var extents = shape.extents

	limit_left = int(room.global_position.x - extents.x)
	limit_right = int(room.global_position.x + extents.x)
	limit_top = int(room.global_position.y - extents.y)
	limit_bottom = int(room.global_position.y + extents.y)

	position_smoothing_enabled = false
