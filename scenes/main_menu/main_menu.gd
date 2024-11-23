class_name MainMenu
extends Control

@onready var start_button = $MarginContainer/GridContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var option_button = $MarginContainer/GridContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Option_Button as Button
@onready var quit_button = $MarginContainer/GridContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Quit_Button as Button
@export var start_level : PackedScene
@onready var options_menu = $Option_Menu as OptionsMenu
@onready var margin_container = $MarginContainer as MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bind_buttons()

func bind_buttons() -> void:
	start_button.button_down.connect(on_start_pressed)
	option_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	options_menu.quit_options_menu.connect(on_quit_options_menu)
	
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
	
func on_options_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

func on_quit_pressed() -> void:
	get_tree().quit()
	
func on_quit_options_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false
	
