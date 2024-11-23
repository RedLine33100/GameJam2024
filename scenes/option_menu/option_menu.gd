class_name OptionsMenu
extends Control

@onready var quit_button = $MarginContainer/VBoxContainer/Quit_Button as Button

@onready var mainMenu = preload("res://scenes/main_menu/main_menu.tscn") as PackedScene

signal quit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quit_button.button_down.connect(on_quit_pressed)
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func on_quit_pressed() -> void:
	quit_options_menu.emit()
	set_process(false)
