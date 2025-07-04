extends VehicleBody3D

@export var player_number = 1

# Référence au nœud AudioStreamPlayer
@onready var audio_player = $AudioStreamPlayer

var STEER_SPEED = 1.5
var STEER_LIMIT = 0.4
var engine_force_value = 50
var steer_target = 0

var projectile_scene = load("res://assets/models/components/Projectile/Projectile.tscn")
var spawnBarrier = false
var shootActivate = false
var barrier_scene = load("res://assets/models/components/Barrier/Barrier.tscn")
var barrier_spacing = 1.0  # Distance minimale entre deux barrières
var last_barrier_position = Vector3.ZERO

# Damage multiplier for frontal collisions
var frontal_damage_multiplier: float = 1.5
var base_damage: float = 10.0
var max_repulsion_force: float = 100.0  # Maximum repulsion force

var default_life : int = 100
var life : int = 0

	
@onready var engine_sound = $EngineSound as AudioStreamPlayer

var bonusLabel = null
var countTimeBonus : float = -1.0
var random = RandomNumberGenerator.new()

func _ready() -> void:
	$SubViewport/HealthBar.max_value = default_life
	$SubViewport/HealthBar.value = default_life
	$SubViewport/Explosion.visible = false
	life = default_life
	bonusLabel = $Hud/Label2
	
	var str = "res://assets/models/cars/car1/car_1.tscn"
	if player_number != 1:
		str = "res://assets/models/cars/car2/car_2.tscn"
	var node = load(str)
	var instance = node.instantiate()
	add_child(instance)
	instance.scale = Vector3(2, 2, 2)
	instance.position = Vector3(0,1.5,0)
	
	$Hud/Label.text = "Joueur "+str(player_number)

func shoot():
	if shootActivate:
		var projectile = projectile_scene.instantiate()
		projectile.transform = Transform3D(transform.basis, transform.origin)
		get_parent().add_child(projectile)

func _process(delta):
	if (Global.paused):
		return
	if Input.is_action_just_pressed(getTouch("croix")):
		shoot()
	
	# 10 secondes
	if(countTimeBonus < 0.0):
		bonusLabel.text = "Aucun bonus"
		return
	countTimeBonus += delta
	
	bonusLabel.text = "Bonus: "+str(10-int(countTimeBonus))
	if spawnBarrier:
		bonusLabel.text += " Barrier"
	else:
		bonusLabel.text += " Shoot"
	
	if(countTimeBonus < 10):
		return
	spawnBarrier = false
	shootActivate = false
	
	countTimeBonus = -1
	

func spawn_barrier():
	if spawnBarrier:
		var barrier = barrier_scene.instantiate()
		barrier.transform = Transform3D(transform.basis, transform.origin)
		get_parent().add_child(barrier)

func getTouch(touch):
	if player_number == 1:
		return "ui_"+touch
	return "ui_"+touch+"_p"+str(player_number)

func _physics_process(delta):
	if (Global.paused):
		return
	var speed = linear_velocity.length()*Engine.get_frames_per_second()*delta
	traction(speed)
	$Hud/speed.text=str(round(speed*3.8))+"  KMPH"
	
	if spawnBarrier:
		# Ajouter une barrière si assez de distance a été parcourue
		if (transform.origin - last_barrier_position).length() > barrier_spacing:
			spawn_barrier()
			last_barrier_position = transform.origin

	var fwd_mps = transform.basis.x.x
	steer_target = Input.get_action_strength(getTouch("left")) - Input.get_action_strength(getTouch("right"))
	steer_target *= STEER_LIMIT
	if Input.is_action_pressed(getTouch("down")):
	# Increase engine force at low speeds to make the initial acceleration faster.
		
		if speed < 20 and speed != 0:
			engine_force = clamp(engine_force_value * 3 / speed, 0, 300)
		else:
			engine_force = engine_force_value
			
	else:
		engine_force = 0
		
			
	if Input.is_action_pressed(getTouch("up")):
		# Increase engine force at low speeds to make the initial acceleration faster.
		if fwd_mps >= -1:
			if speed < 30 and speed != 0:
				engine_force = -clamp(engine_force_value * 10 / speed, 0, 300)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1
	else:
		brake = 0.0
		
	var max_speed = 200
	# Ou utilisez volume linéaire
	engine_sound.volume_db = min(30, speed*3.8*30 / max_speed)
		
	if Input.is_action_pressed(getTouch("select")):
		brake=3
		$wheal2.wheel_friction_slip=0.8
		$wheal3.wheel_friction_slip=0.8
	else:
		$wheal2.wheel_friction_slip=3
		$wheal3.wheel_friction_slip=3
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

func heal(amount: int):
	life += amount;
	if life > default_life:
		life = default_life;
	$SubViewport/HealthBar.value = life

func damage(damage: int):
	life -= damage
	if(life<0):
		set_life(0)
	$SubViewport/HealthBar.value = life
	

func set_life(value: int):
	if (value == 0):
		$SubViewport/HealthBar.value = value
		$SubViewport/Explosion.visible = true
		$SubViewport/Explosion/AnimationPlayer.play("explosion")
		_play_sound_and_remove()
		await get_tree().create_timer(1.3).timeout
	$SubViewport/HealthBar.value = value
	life = value
	
		
	

func traction(speed):
	apply_central_force(Vector3.DOWN*speed)
	
# Function to calculate damage on collision
func _on_body_entered(body: Node):
	if body is not VehicleBody3D:
		return
	if not body or not body.global_transform:
		return
	# Get the car's front direction (Z-axis in 3D is typically "forward")
	var front_vector = -global_transform.basis.z.normalized()
	
	# Get collision normal (approximate using the colliding object's position)
	var collision_normal = (body.global_position - global_position).normalized()
	
	# Check if the collision is from the front
	var frontal_hit = collision_normal.dot(front_vector) > 0.7  # Adjust threshold as needed
	if frontal_hit:
		# Calculate relative velocity magnitude
		var relative_velocity = (linear_velocity - (body.linear_velocity if body.has_method("get_linear_velocity") else Vector3.ZERO)).length()
		
		# Calculate damage
		var dmgValue = base_damage + frontal_damage_multiplier * relative_velocity
		body.damage(dmgValue)
		# Apply repulsion based on the collided object's "life"
		var resLife = body.life  # Get the life value of the collided object
		var repulsion_force = max_repulsion_force * (1.0 - (resLife / 100.0))  # Scale force by life percentage
		
		# Apply repulsion impulse
		if body is RigidBody3D:
			var nf = (collision_normal * repulsion_force) * 5
			body.apply_central_impulse(nf)


func applyRandomBonus():
	if countTimeBonus >= 0:
		return
	countTimeBonus = 0.0
	var result = random.randi_range(0,1)
	match result:
		0: spawnBarrier = true
		1: shootActivate = true

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
