extends Node3D

@onready var car1 = $GridContainer/SubViewportContainer/SubViewport/car as VehicleBody3D
@onready var car2 = $GridContainer/SubViewportContainer2/SubViewport/car as VehicleBody3D
@onready var game_over = preload("res://scenes/game_over_menu/game_over.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var life1 = car1.life
	var life2 = car2.life
	if life1 == 0 && life2 == 0:
		_game_over("Egalité")
	elif life1 == 0:
		_game_over("Joueur2")
	elif life2 == 0:
		_game_over("Joueur1")
			
			
func _game_over(winner_param: String) -> void:
	Global.winner = winner_param
	get_tree().change_scene_to_packed(game_over)
