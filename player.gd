extends CharacterBody3D

@onready var head_obj = $Head
@onready var camera_obj = $Head/Camera

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var lastfb = 0
var lastlr = 0
var lastrlr = 0
var camera = false
# quickStep as in Step in the quickCamera change like 0,1,2,3 ecc.. and maxStep is the ceiling value for it
var quickStep = 0
var maxStep = 2

func quick_camera_rotation(quick_step):
	if quick_step == 0:
		return Vector3(-30,0,0)
	if quick_step == 1:
		return Vector3(-90,0,0)
	if quick_step == 2:
		return Vector3(0,0,0)

func quick_camera_distance(quick_step):
	if quick_step == 0:
		return 2
	if quick_step == 1:
		return 5
	if quick_step == 2:
		return 0

func _physics_process(delta: float) -> void:

	# Check if player quits (temporary (probably))
	if Input.is_action_pressed("quit"):
		get_tree().quit()

	# Check if player reloads with "r" (temporary (probably))
	if Input.is_action_pressed("reload"):
		position = Vector3(0,1,0)

	# Toggle camera mode
	if Input.is_action_just_pressed("camera mode"):
		if camera:
			camera = false
			head_obj.rotation_degrees = quick_camera_rotation(quickStep)
			camera_obj.position.z = quick_camera_distance(quickStep)
		else:
			camera = true

	if Input.is_action_just_pressed("quick_camera"):
		quickStep += 1
		if quickStep > maxStep: quickStep = 0
		head_obj.rotation_degrees = quick_camera_rotation(quickStep)
		camera_obj.position.z = quick_camera_distance(quickStep)

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# if in camera mode
	if camera:
		var amount = 0
		if Input.is_action_pressed("a") or Input.is_action_pressed(";"):
			amount = 5
		elif Input.is_action_pressed("s") or Input.is_action_pressed("l"):
			amount = 3
		else:
			amount = 1

		if Input.is_action_pressed("forwards"):
			head_obj.rotation_degrees.x -= 3
		if Input.is_action_pressed("backwards"):
			head_obj.rotation_degrees.x += 3
		if Input.is_action_pressed("left"):
			head_obj.rotation_degrees.y -= amount
		if Input.is_action_pressed("right"):
			head_obj.rotation_degrees.y += amount
		if Input.is_action_pressed("rel_left"):
			camera_obj.position.z += 0.1
		if Input.is_action_pressed("rel_right"):
			camera_obj.position.z -= 0.1
		camera_obj.position.z = clamp(camera_obj.position.z, 0, 5)

	else:
		# Handle jump.
		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Forwards and Backwards movement
		var input_dir = Vector2.ZERO
		if Input.is_action_just_pressed("forwards"): lastfb = 1
		if Input.is_action_just_pressed("backwards"): lastfb = 2
		if Input.is_action_pressed("forwards") and lastfb == 1: input_dir = Vector2(0,-1)
		if Input.is_action_pressed("backwards") and lastfb == 2: input_dir = Vector2(0,1)

		# Left and Right movement
		if Input.is_action_just_pressed("rel_left"): lastrlr = 1
		if Input.is_action_just_pressed("rel_right"): lastrlr = 2
		if Input.is_action_pressed("rel_left") and lastrlr == 1: input_dir += Vector2(-1,0)
		if Input.is_action_pressed("rel_right") and lastrlr == 2: input_dir += Vector2(1,0)
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		# Left and Right rotation
		var rot = 0
		if Input.is_action_pressed("a") or Input.is_action_pressed(";"): rot = 10
		elif Input.is_action_pressed("s") or Input.is_action_pressed("l"): rot = 5
		else: rot = 2

		if Input.is_action_just_pressed("left"): lastlr = 1
		if Input.is_action_just_pressed("right"): lastlr = 2
		if Input.is_action_pressed("left") and lastlr == 1: rotation_degrees.y += rot
		if Input.is_action_pressed("right") and lastlr == 2: rotation_degrees.y += -rot

	move_and_slide()
