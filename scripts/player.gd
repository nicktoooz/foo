extends RigidBody3D

@onready var ground_checker = $GroundChecker
var MAX_SPEED = 25.0
var friction = 8.0
var jump_force = 1.0
var is_on_floor = false
var rotation_speed = 2.0

var current_speed = Vector3.ZERO
var target_rotation = 0.0

@onready var raycasts = [
	$Centre,
	$ForwardCentre,
	$FrontLeft,
	$FrontRight,
	$FrontLeft2,
	$FrontRight2,
	$FrontLeft3,
	$FrontRight3,
	$FrontLeft4,
	$FrontRight4,
	$FrontLeft5,
	$FrontRight5,
	$FrontLeft6,
	$FrontRight6,
	$FrontLeft7,
	$FrontRight7,
	$RearCentre,
	$RearLeft,
	$RearRight,
	$RearLeft2,
	$RearRight2,
	$RearLeft3,
	$RearRight3,
	$RearLeft4,
	$RearRight4,
	$RearLeft5,
	$RearRight5,
	$RearLeft6,
	$RearRight6,
	$RearLeft7,
	$RearRight7
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called during the physics processing step.
func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	
	# Check if the player is on the floor
	is_on_floor = is_on_floor_function()  # Replace with your floor check logic
	
	if Input.is_action_pressed("ui_left") or $"../Left".is_pressed():
		global_rotate(transform.basis.z.normalized(), 3 * delta)
		target_rotation += rotation_speed * delta
	elif Input.is_action_pressed("ui_right") or $"../Right".is_pressed():
		global_rotate(transform.basis.z.normalized(), -3 * delta)
		target_rotation -= rotation_speed * delta

	# Update player rotation
	var current_rotation = rotation.y
	var new_rotation = lerp_angle(current_rotation, target_rotation, 0.1)  # Increase the lerp factor for quicker rotation
	rotation.y = new_rotation

	# Get input directions
	var direction = Vector3.ZERO
	#if Input.is_action_pressed("ui_up"):  # Commenting out the input check for 'ui_up'
	#	direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1

	# Auto-acceleration forward
	direction.z -= 1

	if is_on_floor:
		var normal = get_average_normal()
		snap_to_surface(normal, delta, 5.0)
		
	# Normalize direction to avoid faster diagonal movement
	direction = direction.normalized()

	# Transform direction to be relative to the player's current rotation
	direction = global_transform.basis * direction

	# Apply the speed directly based on direction and MAX_SPEED
	if direction != Vector3.ZERO:
		current_speed = direction * MAX_SPEED
	else:
		# Apply friction to gradually slow down
		if current_speed.length() > 0:
			var friction_force = -current_speed.normalized() * friction * delta
			if friction_force.length() > current_speed.length():
				current_speed = Vector3.ZERO
			else:
				current_speed += friction_force

	# Apply the calculated speed to the RigidBody3D
	linear_velocity = Vector3(current_speed.x, linear_velocity.y, current_speed.z)

	

	# Jumping
	if (Input.is_action_just_pressed("ui_accept") or $"../FWD".is_pressed()) and is_on_floor:
		apply_central_impulse(Vector3(0, jump_force, 0))

func is_on_floor_function() -> bool:
	return $Centre.is_colliding()

func snap_to_surface(n: Vector3, delta: float, weight: float):
	var target_transform = align_with_y(global_transform, n)
	global_transform.basis.x = global_transform.basis.x.lerp(target_transform.basis.x, weight * delta)
	global_transform.basis.y = global_transform.basis.y.lerp(target_transform.basis.y, weight * delta)
	global_transform.basis.z = global_transform.basis.z.lerp(target_transform.basis.z, weight * delta)
	global_transform.basis = global_transform.basis.orthonormalized()

func get_average_normal() -> Vector3:
	var total_normal = Vector3.ZERO
	for raycast in raycasts:
		total_normal += raycast.get_collision_normal()
	return total_normal / raycasts.size()

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
