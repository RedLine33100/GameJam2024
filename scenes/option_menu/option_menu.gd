class_name OptionsMenu
extends Control

@onready var return_button = $MarginContainer/VBoxContainer/HBoxContainer/Return_Button as Button
@onready var mainmenu_button = $MarginContainer/VBoxContainer/HBoxContainer/MainMenu_Button as Button
@onready var quit_button = $MarginContainer/VBoxContainer/HBoxContainer/Quit_Button as Button
@onready var mainMenu = preload("res://scenes/main_menu/main_menu.tscn") as PackedScene

signal quit_options_menu
signal return_options_main_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return_button.button_down.connect(on_return_pressed)
	set_process(false)
	mainmenu_button.button_down.connect(on_mainmenu_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_return_pressed() -> void:
	quit_options_menu.emit()
	set_process(false)
	
func on_mainmenu_pressed() -> void:
	return_options_main_menu.emit()
	set_process(false)
	#get_tree().change_scene_to_packed(mainMenu)
	
func on_quit_pressed() -> void:
	get_tree().quit()
