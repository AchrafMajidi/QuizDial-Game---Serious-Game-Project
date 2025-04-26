extends Camera2D

# Système de caméra par salle pour jeu top-down
class_name RoomCamera

# Délai de transition (en secondes)
@export var transition_speed: float = 0.5
# Salle actuelle
var current_room: Area2D = null
# Cible de la caméra lors d'une transition
var target_position: Vector2 = Vector2.ZERO
# En transition ou pas
var is_transitioning: bool = false

func _ready() -> void:
	# Activer la caméra
	make_current()
	
	# Connecter les signaux pour toutes les salles
	var rooms = get_tree().get_nodes_in_group("rooms")
	for room in rooms:
		room.connect("body_entered", Callable(self, "_on_room_entered").bind(room))
		print("Connecté à la salle:", room.name)
	
	# Trouver la salle initiale du joueur
	var player = get_parent()
	call_deferred("_find_initial_room", player.global_position)

func _find_initial_room(player_pos: Vector2) -> void:
	var rooms = get_tree().get_nodes_in_group("rooms")
	for room in rooms:
		if _is_position_in_room(player_pos, room):
			_set_camera_to_room(room)
			current_room = room
			print("Salle initiale trouvée:", room.name)
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
	# Vérifier que c'est le joueur qui est entré
	if body == get_parent() and room != current_room:
		print("Entrée dans la salle:", room.name)
		_transition_to_room(room)
		current_room = room

func _transition_to_room(room: Area2D) -> void:
	# Calculer le centre de la salle
	var collision_shape = room.get_node("CollisionShape2D")
	if collision_shape and collision_shape.shape is RectangleShape2D:
		# Définir la position cible (centre de la salle)
		target_position = room.global_position
		is_transitioning = true
		
		# Option 1: Transition douce avec Tween
		var tween = create_tween()
		tween.tween_property(self, "global_position", target_position, transition_speed)
		tween.tween_callback(Callable(self, "_finished_transition"))
		
		# Option 2: Transition instantanée (décommentez pour utiliser)
		# global_position = target_position
		# _set_camera_to_room(room)

func _finished_transition() -> void:
	is_transitioning = false
	_set_camera_to_room(current_room)

func _set_camera_to_room(room: Area2D) -> void:
	var collision_shape = room.get_node("CollisionShape2D")
	if not collision_shape or not (collision_shape.shape is RectangleShape2D):
		print("ERREUR: Forme de collision invalide pour", room.name)
		return
	
	var shape = collision_shape.shape as RectangleShape2D
	var extents = shape.extents
	
	# Définir les limites de la caméra aux dimensions de la salle
	limit_left = int(room.global_position.x - extents.x)
	limit_right = int(room.global_position.x + extents.x)
	limit_top = int(room.global_position.y - extents.y)
	limit_bottom = int(room.global_position.y + extents.y)
	
	# Désactiver le défilement pour que la caméra reste centrée sur la salle
	position_smoothing_enabled = false
	
	print("Caméra configurée pour la salle:", room.name, 
		  "L:", limit_left, "R:", limit_right, 
		  "T:", limit_top, "B:", limit_bottom)
