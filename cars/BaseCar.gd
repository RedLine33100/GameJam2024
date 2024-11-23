extends VehicleBody3D

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
@export var engine_force_value = 40
@export var player_number = 1
@export var default_life : int = 100
@export var spawnBarrier = false
@export var barrier_scene : Resource
@export var barrier_spacing = 1.0  # Distance minimale entre deux barrières
# Damage multiplier for frontal collisions
@export var frontal_damage_multiplier: float = 1.5
@export var base_damage: float = 10.0
@export var max_repulsion_force: float = 100.0  # Maximum repulsion force
@export var projectile_scene : Resource
var last_barrier_position = Vector3.ZERO
var steer_target = 0
var life : int = 0


	
@onready var engine_sound = $EngineSound as AudioStreamPlayer

func _ready() -> void:
	$SubViewport/HealthBar.max_value = default_life
	$SubViewport/HealthBar.value = default_life
	#engine_sound.play()
	
	life = default_life

func shoot():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		# Positionner le projectile à l'avant de la voiture
		projectile.transform = Transform3D(transform.basis, transform.origin)
		# Ajouter le projectile à la scène
		get_parent().add_child(projectile)

func _process(delta):
	if Input.is_action_just_pressed(getTouch("croix")):
		shoot()

func spawn_barrier():
	if barrier_scene:
		var barrier = barrier_scene.instantiate()
		barrier.transform = Transform3D(transform.basis, transform.origin)  # Positionner la barrière
		get_parent().add_child(barrier)

func getTouch(touch):
	if player_number == 1:
		return "ui_"+touch
	return "ui_"+touch+"_p"+str(player_number)

func _physics_process(delta):
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
	$SubViewport/HealthBar.value = life
	if(life>0):
		return
	self.visible = false
	var layer = 2
	self.collision_layer &= ~(1 << layer)
	self.collision_mask &= ~(1 << layer)

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
			var nf = (collision_normal * repulsion_force) * 10
			body.apply_central_impulse(nf)
