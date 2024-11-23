extends Camera3D


@export var target_distance = 5
@export var target_height = 2
@export var speed:=20.0
var follow_this = null
var last_lookat
var cameraOrientation = 0


func _ready():
	follow_this = get_parent()
	last_lookat = follow_this.global_transform.origin

func _physics_process(delta):
	var delta_v = global_transform.origin - follow_this.global_transform.origin
	var target_pos = global_transform.origin
	
	# ignore y
	delta_v.y = 0.0
	
	if (delta_v.length() > target_distance):
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_pos = follow_this.global_transform.origin + delta_v
	else:
		target_pos.y = follow_this.global_transform.origin.y + target_height
	
	global_transform.origin = global_transform.origin.lerp(target_pos, delta * speed)
	
	last_lookat = last_lookat.lerp(follow_this.global_transform.origin, delta * speed)
	
	# Car player number from car object
	var cameraTurn = Input.get_action_strength(get_parent().get_parent().getTouch("cright")) - Input.get_action_strength(get_parent().get_parent().getTouch("cleft"))
	
	var angleDefault = atan2(global_transform.origin.z - follow_this.global_transform.origin.z, global_transform.origin.x - follow_this.global_transform.origin.x)
	
	angleDefault += 0.1*cameraTurn
	
	global_transform.origin.x = follow_this.global_transform.origin.x+(target_distance*cos(angleDefault))
	global_transform.origin.z = follow_this.global_transform.origin.z+(target_distance*sin(angleDefault))

	
	look_at(last_lookat, Vector3.UP)
