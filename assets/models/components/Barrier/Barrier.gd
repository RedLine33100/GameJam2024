extends Node3D

@export var lifetime = 10.0
var timer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	timer += delta
	if timer >= lifetime:
		queue_free()  # Supprime la barrière lorsque la durée de vie est atteinte
