extends VehicleBody3D

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
var steer_target = 0
@export var engine_force_value = 40
@export var player_number = 1

@export var projectile_scene = load("res://Projectile/Projectile.tscn")
func shoot():
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		# Positionner le projectile à l'avant de la voiture
		projectile.transform = Transform3D(transform.basis, transform.origin)
		# Ajouter le projectile à la scène
		get_parent().add_child(projectile)

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		shoot()

@export var spawnBarrier = false
@export var barrier_scene = load("res://Barrier/Barrier.tscn")
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
