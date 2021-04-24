extends KinematicBody


var speed = 20

# accumulators
var rot_x = 0
var rot_y = 0

var LOOKAROUND_SPEED = 0.2

func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var direction = Vector3()
	
	var h_rot = $Camroot/Helper.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("ui_left"):
		direction.x = -1 
		
	if Input.is_action_pressed("ui_right"):
		direction.x = 1
		
	if Input.is_action_pressed("ui_up"):
		direction.z = -1
		
	if Input.is_action_pressed("ui_down"):
		direction.z = 1
		
	
	direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	var movement = move_and_slide(direction * speed) 
	


	
func _input(event):
	if event is InputEventMouseMotion:


		$Camroot.rotate_y( -event.relative.x /100 )
		
		print_debug(clamp($Camroot/Helper.rotation_degrees.x, -50, 50))

		$Camroot/Helper.rotation_degrees.x = clamp($Camroot/Helper.rotation_degrees.x + (event.relative.y ), -50,50)
#		clamp($Camroot/Helper.rotation_degrees.x, -50, 50)
#		$Camroot/Helper.rotate_x( clamp (event.relative.y / 100, -1, 20) )

#		$Camroot.transform.basis
#
		
		
		



#		$Camroot.orthonormalize()
		




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

