extends Node3D
@onready var player = $".."
@onready var mount = $Mount
@onready var camera = $Mount/Camera3D
@onready var label = $"../../Label"
var target_rotation = 0.0
const MIN_FOV = 70.0  
const MAX_FOV = 90.0 
const FOV_CHANGE_RATE = 5.0  
const ROTATION_SPEED = 2.0

func _ready():
	pass

func _process(delta):
	if Input.is_action_pressed("ui_left") or $"../../Left".is_pressed():
		target_rotation += ROTATION_SPEED * delta
	elif Input.is_action_pressed("ui_right") or $"../../Right".is_pressed():
		target_rotation -= ROTATION_SPEED * delta
		
	var current_rotation = rotation.y
	var new_rotation = lerp_angle(current_rotation, target_rotation, 0.05)
	rotation.y = new_rotation
	position = lerp(position, player.position, 0.5)
	
	label.set_text("Camera Rotation: {str}".format({"str":rotation.y}))
	
	adjust_camera_fov(delta)
	
	var tilt_degree = get_tilt_degree()
	if tilt_degree > 1:  
		tilt_camera(-tilt_degree - 8, delta)
	elif tilt_degree < -1:  
		reset_camera(delta)
	else:
		reset_camera(delta)
	
func get_tilt_degree() -> float:
	var forward_vector = player.transform.basis.z
	var up_vector = player.transform.basis.y

	var horizontal_forward = Vector3(forward_vector.x, 0, forward_vector.z).normalized()
	var tilt_radians = forward_vector.angle_to(horizontal_forward)

	if forward_vector.y < 0:
		tilt_radians = -tilt_radians

	var tilt_degrees = rad_to_deg(tilt_radians)
	return tilt_degrees

func tilt_camera(tilt_degree: float, delta: float):
	var target_rotation = deg_to_rad(tilt_degree)
	rotation.x = lerp(rotation.x, target_rotation, 1.0 * delta)

func reset_camera(delta: float):
	rotation.x = lerp(rotation.x, 0.0, 1.0 * delta)

func adjust_camera_fov(delta: float):
	var horizontal_speed = sqrt(player.linear_velocity.x * player.linear_velocity.x + player.linear_velocity.z * player.linear_velocity.z)
	var target_fov = lerp(MIN_FOV, MAX_FOV, horizontal_speed / player.MAX_SPEED)
	camera.fov = lerp(camera.fov, target_fov, FOV_CHANGE_RATE * delta)
