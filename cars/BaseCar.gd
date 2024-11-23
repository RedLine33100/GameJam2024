extends VehicleBody3D

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
var steer_target = 0
@export var engine_force_value = 40
@export var player_number = 1
@export var default_life : int = 10
var life : int = 0


	
@onready var engine_sound = $EngineSound as AudioStreamPlayer

func _ready() -> void:
	$SubViewport/HealthBar.max_value = default_life
	$SubViewport/HealthBar.value = default_life
	engine_sound.play()
	
	life = default_life

@export var projectile_scene = load("res://assets/models/components/Projectile/Projectile.tscn")
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

@export var spawnBarrier = false
@export var barrier_scene = load("res://assets/models/components/Barrier/Barrier.tscn")
var last_barrier_position = Vector3.ZERO
@export var barrier_spacing = 1.0  # Distance minimale entre deux barrières
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



func traction(speed):
	apply_central_force(Vector3.DOWN*speed)
	
func damage(damage: int):
	life-=damage
	$SubViewport/HealthBar.value = life
	if(life>0):
		return
	self.visible = false
	var layer = 2
	self.collision_layer &= ~(1 << layer)
	self.collision_mask &= ~(1 << layer)

# Function to calculate the angle between the two cars' orientation vectors
func calculate_impact_angle(other_car: VehicleBody3D) -> float:
	# Get the forward direction of the current car and the other car
	var car_forward = transform.basis.z.normalized()  # Direction car is facing
	var other_car_forward = other_car.transform.basis.z.normalized()  # Direction other car is facing
	
	# Calculate the dot product between the two direction vectors
	var dot_product = car_forward.dot(other_car_forward)
	
	# The angle is the arccosine of the dot product
	var angle = rad_to_deg(acos(dot_product))  # Convert radians to degrees
	return angle

# Function to calculate damage based on collision velocity and angle
func calculate_damage(collision_velocity: float, angle_of_impact: float) -> int:
	var max_damage = 100  # Maximum possible damage
	var base_damage = collision_velocity * 0.5  # Base damage proportional to collision velocity
	
	# Adjust damage based on the angle of impact (0 degrees is head-on)
	var angle_factor = 1.0 - (angle_of_impact / 180.0)  # Scale damage between 0 (side impact) to 1 (head-on)
	
	# Final damage is base damage multiplied by the angle factor
	var damage = base_damage * angle_factor
	
	# Ensure damage doesn't exceed max_damage
	return int(min(damage, max_damage))

func _on_body_entered(testBody: Node) -> void:
	if not testBody is VehicleBody3D:
		return;
	var body : VehicleBody3D = testBody
	# Calculate relative velocity at the point of collision
	var collision_velocity = (linear_velocity - body.linear_velocity).length()
	# Apply damage based on the collision velocity
	var damage = calculate_damage(collision_velocity, calculate_impact_angle(body))
	# Reduce health by the calculated damage
	var health = damage
	# Print out the damage and health status
	print("P "+str(player_number)+" f Collision Damage: ", damage)
	print("P "+str(player_number)+" fRemaining Health: ", health)
	body.damage(damage)
