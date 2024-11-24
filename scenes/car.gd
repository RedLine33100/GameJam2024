extends Node3D

@onready var car1 = $GridContainer/SubViewportContainer/SubViewport/car as VehicleBody3D
@onready var car2 = $GridContainer/SubViewportContainer2/SubViewport/car as VehicleBody3D
@onready var game_over = preload("res://scenes/game_over_menu/game_over.tscn") as PackedScene
@onready var options_menu = $Option_Menu as OptionsMenu
@onready var mainMenu = load("res://scenes/main_menu/main_menu.tscn") as PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	options_menu.quit_options_menu.connect(on_quit_options_menu)
	options_menu.return_options_main_menu.connect(on_main_menu)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(getTouch("game_menu")):
		$GridContainer.visible = false
		options_menu.set_process(true)
		options_menu.visible = true
		get_tree().paused = true
	handle_game_over()
	
			
func getTouch(touch):
	return "ui_"+touch
	
func handle_game_over() -> void:
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
	
func on_quit_options_menu() -> void:
	get_tree().paused = false
	$GridContainer.visible = true
	options_menu.visible = false
	
func on_main_menu() -> void:
	get_tree().paused = false
	$GridContainer.visible = true
	options_menu.visible = false
	get_tree().change_scene_to_packed(mainMenu)
