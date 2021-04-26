extends KinematicBody

#(items para tacar para destrair)
#objeto/gadget que faz som de pegadas quando ativado
#arma tem muzzle flash

var gravity_speed = 20
var walking_speed = 20
var current_speed = 0
var run_speed = 40
var crouching = false
var crouch_speed = 5
var horizontal_look_sensitivity = 0.004
var vertical_look_sensitivity = 0.1

var angular_acceleration = 7

var waitfootsteps = false

onready var flashlight = $Camroot/Helper/Camera/flashlightholder/SpotLight


onready var footstepsplayer = $FootstepsPlayer
var originaldb
var original_unit_size
var original_wait_time


## accumulators
#var rot_x = 0
#var rot_y = 0
#
#var LOOKAROUND_SPEED = 0.2


func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called when the node enters the scene tree for the first time.
func _ready():
	originaldb = $FootstepsPlayer.unit_db
	original_unit_size = $FootstepsPlayer.unit_size
	original_wait_time = $FootstepsPlayer/Timer.wait_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var direction = Vector3()
	var velocity = Vector3()
	var gravity = Vector3()
	var moving = false
#	crouching = false
	current_speed = walking_speed
	
	var h_rot = $Camroot/Helper.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("ui_left"):
		direction.x = -1 
		moving = true
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
		moving = true
	if Input.is_action_pressed("ui_up"):
		direction.z = -1
		moving = true
	if Input.is_action_pressed("ui_down"):
		direction.z = 1
		moving = true
	if Input.is_action_pressed("sprint"):
		current_speed = run_speed
		crouching = false
#		sprinting = true
	if Input.is_action_just_pressed("crouch"):
		crouching = !crouching
#		print_debug(crouching)
	if crouching:
		current_speed = crouch_speed
#	if Input.is_action_pressed("crouch"):
#		current_speed = crouch_speed
	
	#Gravity
	if !is_on_floor():
		gravity.y = -1
#		direction.y = -1
		
	
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
#	velocity = direction 
	
	var movement = move_and_slide(direction * current_speed + gravity * gravity_speed) 
	
	
	if moving and current_speed != crouch_speed:
		
#		if is_on_wall() and velocity == Vector2.ZERO:
#				pass
#				audioplayer.play()
		if is_on_floor():
			playfootsteps(true)
		else:
			playfootsteps(false)
	
	#Rotação de mesh/player, usar se necessário
	$MeshInstance.rotation.y = lerp_angle($MeshInstance.rotation.y, atan2(direction.x, direction.z) - $MeshInstance.rotation.y, delta * angular_acceleration)
#	print_debug($MeshInstance.rotation.y)
	
	if Input.is_action_just_pressed("shoot"):
		$Camroot/Helper/Camera/Gun/audiobullet.play()
		
		$Camroot/Helper/Camera/Gun/AnimationPlayer.play("muzzle_flash")
		$Camroot/Helper.rotate_x(0.2)
		$Camroot.camrot_v += 5
		
#		$Camroot/Helper.rotation_degrees.x = lerp($Camroot/Helper.rotation_degrees.x, $Camroot/Helper.rotation_degrees.x-5.05, delta )
		
#	if movement.x != 0 || movement.x != 0:
#		footstepsplayer.play()
	
#	if Input.is_action_just_pressed("flashlight"):
#		flashlight.visible = !flashlight.visible
	


	
#func _input(event):
#	if event is InputEventMouseMotion:
#
#		$Camroot.rotate_y( -event.relative.x * horizontal_look_sensitivity )
#		$Camroot/Helper.rotation_degrees.x = clamp($Camroot/Helper.rotation_degrees.x - (event.relative.y * vertical_look_sensitivity ), -50,50)
		
		
#		print_debug(clamp($Camroot/Helper.rotation_degrees.x, -50, 50))

#		clamp($Camroot/Helper.rotation_degrees.x, -50, 50)
#		$Camroot/Helper.rotate_x( clamp (event.relative.y / 100, -1, 20) )

#		$Camroot.transform.basis
#

func _unhandled_input(event):
	if event.is_action_pressed("flashlight"):
		flashlight.visible = !flashlight.visible
			
		
		


func playfootsteps(wait):
#	print_debug($FootstepsPlayer/Timer.wait_time)
	if !$FootstepsPlayer.playing:
		
		if current_speed == run_speed:
				$FootstepsPlayer.unit_db = 2
				$FootstepsPlayer.unit_size = 3
				$FootstepsPlayer/Timer.wait_time = 0.1
		else:
			if $FootstepsPlayer.unit_db != originaldb:
				$FootstepsPlayer.unit_db = originaldb
				$FootstepsPlayer.unit_size = original_unit_size
				$FootstepsPlayer/Timer.wait_time = original_wait_time
				
		if wait and !waitfootsteps:
			print_debug("here")
			$FootstepsPlayer.play()
			waitfootsteps = true
			$FootstepsPlayer/Timer.start()
		elif !wait:
			$FootstepsPlayer.play()
		
		if $FootstepsPlayer.pitch_scale == 1:
			$FootstepsPlayer.pitch_scale = 1.2
		else:
			$FootstepsPlayer.pitch_scale = 1






#func _input(event):
#	if event is InputEventMouseMotion:
#		# modify accumulated mouse rotation
#		rot_x += event.relative.x * LOOKAROUND_SPEED
#		rot_y += event.relative.y * LOOKAROUND_SPEED
##		$Camroot.transform.basis = Basis() # reset rotation
#		$Camroot.rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
#		$Camroot.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X
#

		
		
#		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
#		if aiming:
#			camera_speed_this_frame *= 0.75
#		rotate_camera(event.relative * camera_speed_this_frame)
#
#
#
#func rotate_camera(move):
#	camera_base.rotate_y(-move.x)
#	# After relative transforms, camera needs to be renormalized.
#	camera_base.orthonormalize()
#	camera_x_rot += move.y
#	camera_x_rot = clamp(camera_x_rot, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
#	camera_rot.rotation.x = camera_x_rot

