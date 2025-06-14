extends Node3D

# Variables de gestion du bonus
@export var bonus_type : String = "health"

# Référence au nœud AudioStreamPlayer
@onready var audio_player = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate_y(delta)
	pass

# Fonction de collecte
func _on_area_3d_body_entered(body: Node3D) -> void:
	print("bonus !")
	# (exemple)
	if body is VehicleBody3D:
		
		# Désactiver toutes les interactions
		self.visible = false
		$Area3D/CollisionShape3D.queue_free()
		
		var car : VehicleBody3D = body
		car.applyRandomBonus()
		# Appeler une fonction async pour gérer le son et la suppression
		_play_sound_and_remove()
	pass # Replace with function body.

# Fonction async qui gère le son et la suppression
func _play_sound_and_remove():
	var temp_audio_player = AudioStreamPlayer.new() # Créer un AudioStreamPlayer temporaire
	temp_audio_player.stream = audio_player.stream # Utiliser le même son
	add_child(temp_audio_player) # Ajouter au parent
	temp_audio_player.play() # Jouer le son
	
	# Attendre que le son soit terminé
	while temp_audio_player.is_playing():
		await get_tree().process_frame
	
	temp_audio_player.queue_free() # Supprimer le player temporaire après la fin du son
	queue_free() # Supprimer immédiatement l'objet
