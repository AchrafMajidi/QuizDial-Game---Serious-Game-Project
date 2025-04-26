extends Node2D

@onready var sprite = $AnimatedSprite2D
@onready var door_collision = $StaticBody2D/CollisionShape2D  # Chemin corrigé vers la collision
@onready var popup = $CanvasLayer  # Change selon ton arborescence
@onready var label_question = popup.get_node("Panel/QuestionLabel")
@onready var answer_input = popup.get_node("Panel/AnswerInput")  # LineEdit pour saisir la réponse

var is_open = false

func _ready() -> void:
	popup.visible = false  # Cacher le panneau au démarrage
	# Connecte l'événement de pression de touche "Entrée" sur le champ de réponse
	answer_input.connect("text_submitted", Callable(self, "_on_answer_entered"))

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_open:
		popup.visible = true
		label_question.text = "Combien font 7 + 5 ?"
		answer_input.text = ""  # Réinitialise la réponse
		answer_input.grab_focus()  # Donne le focus au champ de texte

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		popup.visible = false

# Cette fonction est appelée quand l'utilisateur appuie sur "Entrée" dans le champ de texte
func _on_answer_entered(answer: String) -> void:
	if is_open:
		return
		
	var reponse = answer.strip_edges()
	if reponse == "12":
		open_door()
	else:
		label_question.text = "Mauvaise réponse. Essaie encore !"

func open_door():
	is_open = true
	sprite.play("open")
	door_collision.disabled = true  # Désactive la collision pour permettre au joueur de passer
	popup.visible = false
