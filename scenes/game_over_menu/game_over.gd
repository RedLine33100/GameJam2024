extends Control

@onready var quit_button = $MarginContainer/VBoxContainer2/Quit_Button as Button
@onready var mainmenu_button = $MarginContainer/VBoxContainer2/MainMenu_Button as Button
@onready var winner_label = $MarginContainer/VBoxContainer/WinnerLabel as Label
@onready var mainMenu = load("res://scenes/main_menu/main_menu.tscn") as PackedScene
@onready var game_scene = load("res://scenes/car.tscn") as PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainmenu_button.button_down.connect(on_mainmenu_pressed)
	quit_button.button_down.connect(on_quit_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_on_game_won(Global.winner)
	
func on_mainmenu_pressed() -> void:
	get_tree().change_scene_to_packed(mainMenu)

func on_quit_pressed() -> void:
	get_tree().quit()
	

func _on_game_won(winner: String):
	if winner == "Egalité":
		winner_label.text = "Egalité !"
		# Mettre à jour l'UI ou afficher un message d'égalité
	elif winner == "Joueur1":
		winner_label.text = "Le Joueur 1 a gagné !!"
		# Mettre à jour l'UI ou afficher que le Joueur 1 a gagné
	elif winner == "Joueur2":
		winner_label.text = "Le Joueur 2 a gagné !!"
		# Mettre à jour l'UI ou afficher que le Joueur 2 a gagné
