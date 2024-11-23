extends VehicleBody3D


@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
var steer_target = 0
@export var engine_force_value = 40
@export var player_number = 1

func getTouch(touch):
	if player_number == 1:
		return "ui_"+touch
	return "ui_"+touch+"_p"+str(player_number)

func _physics_process(delta):
	var speed = linear_velocity.length()*Engine.get_frames_per_second()*delta
	traction(speed)
	$Hud/speed.text=str(round(speed*3.8))+"  KMPH"

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

func test():
	print("Je suis un test: "+str(player_number))

# Function to calculate damage based on collision velocity
func calculate_damage(collision_velocity: float) -> int:
	var max_damage = 100  # Maximum possible damage
	var damage = collision_velocity * 0.5  # Base damage proportional to collision velocity
	return int(min(damage, max_damage))

func _on_body_entered(testBody: Node) -> void:
	if not testBody is VehicleBody3D:
		return;
	var body : VehicleBody3D = testBody
	# Calculate relative velocity at the point of collision
	var collision_velocity = (linear_velocity - body.linear_velocity).length()
	# Apply damage based on the collision velocity
	var damage = calculate_damage(collision_velocity)
	# Reduce health by the calculated damage
	var health = damage
	# Print out the damage and health status
	print("P "+str(player_number)+" f Collision Damage: ", damage)
	print("P "+str(player_number)+" fRemaining Health: ", health)
