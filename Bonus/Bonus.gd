extends Node3D

# Variables de gestion du bonus 
@export var bonus_type : String # Type de bonus (par exemple, "speed", "shield", "repair")
var is_collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotate_y(delta)
	pass

# Fonction de collecte
func _on_area_3d_body_entered(body: Node3D) -> void:
	queue_free() # a virer
	print("bonus !") #a virer
	
	# (exemple)
	if body.is_in_group("player"): # Vérifie si l'objet est un joueur
		if !is_collected:
			is_collected = true
			apply_bonus(body) # Appliquer l'effet du bonus au joueur
			queue_free() # Supprimer le bonus de l'arène après avoir été collecté
	pass # Replace with function body.

# Appliquer le bonus au joueur (exemple)
func apply_bonus(player: Node):
	match bonus_type:
		"speed":
			player.apply_speed_boost()
		"shield":
			player.apply_shield()
		"repair":
			player.apply_repair()
