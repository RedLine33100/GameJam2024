extends Node3D

# Chemin vers la scène de l'item à faire apparaître
var item_scene: PackedScene = load("res://assets/models/components/Bonus/Bonus.tscn")
# Intervalle de temps entre chaque tentative de spawn (en secondes)
@export var spawn_interval: float = 10.0

# Timer pour gérer l’apparition
var spawn_timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Crée et configure un Timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", Callable(self, "_on_spawn_timer_timeout"))
	add_child(spawn_timer)
	spawn_timer.start()
	_on_spawn_timer_timeout()
	pass # Replace with function body.

# Fonction appelée à chaque intervalle
func _on_spawn_timer_timeout():
	# Vérifie s'il y a des enfants
	if get_child_count() == 1:
		spawn_item()

# Fonction pour faire apparaître un objet
func spawn_item():
	if item_scene:  # Vérifie que la scène est définie
		var new_item = item_scene.instantiate()
		add_child(new_item)  # Ajoute l’item comme enfant du SpawnPoint
		new_item.global_transform = global_transform  # Positionne l'item au SpawnPoint
	else:
		print("La scène de l'item n'est pas définie.")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
