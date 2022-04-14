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
export var reloading = false
var horizontal_look_sensitivity = 0.004
var vertical_look_sensitivity = 0.1

var angular_acceleration = 7

var waitfootsteps = false

onready var flashlight = $Camroot/Helper/Camera/flashlightholder/SpotLight
onready var nightvision = $NightVisionGrainyAlt
onready var worldenvironment = $"../WorldEnvironment"


onready var footstepsplayer = $FootstepsPlayer
var originaldb
var original_unit_size
var original_wait_time

var tempaudioplayer = preload("res://scenes/AudioHolder.tscn")

####
#Ammo and bullet stuff
var current_ammo = 5
onready var current_ammo_label = $HUD/HBoxContainer/labelCurrentAmmo
var mag_size = 5
var remaining_mags = 10

onready var interactraycast = $"Camroot/Helper/Camera/InteractRaycast"
## accumulators
#var rot_x = 0
#var rot_y = 0
#
#var LOOKAROUND_SPEED = 0.2

var wallhug_mode = false
onready var left_cover_raycast : RayCast = $Camroot/Helper/Camera/CoverRaycasts/LeftCoverRaycast 
onready var right_cover_raycast : RayCast = $Camroot/Helper/Camera/CoverRaycasts/RightCoverRaycast 


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
	
	interact_raycast()
	
	var h_rot = $Camroot/Helper.global_transform.basis.get_euler().y
	
	if Input.is_action_pressed("ui_left"):
		if wallhug_mode and !left_cover_raycast.is_colliding():
			pass
		else:
			direction.x = -1 
			moving = true
		
	if Input.is_action_pressed("ui_right"):
		if wallhug_mode and !right_cover_raycast.is_colliding():
			pass
		else:
			direction.x = 1
			moving = true
	if Input.is_action_pressed("ui_up"):
		if !wallhug_mode:
			direction.z = -1
			moving = true
	if Input.is_action_pressed("ui_down"):
		if !wallhug_mode:
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
	if Input.is_action_just_pressed("nightvision"):
		nightvision.visible = !nightvision.visible
#		$OmniLight.visible = !$OmniLight.visible
		if nightvision.visible:
			worldenvironment.environment.ambient_light_color = Color("5a944f")
		else:
			worldenvironment.environment.ambient_light_color = Color("000000")
	if Input.is_action_just_pressed("cover"):
		if wallhug_mode:
			wallhug_mode = false
		if $Camroot/Helper/Camera/CoverRaycast.is_colliding():
			print_debug($Camroot/Helper/Camera/CoverRaycast.get_collision_normal())
			print_debug(global_transform.basis.z)
			wallhug_mode = true
			
		
		
	
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

	if Input.is_action_just_pressed("reload"):
		reload()
	
	if Input.is_action_just_pressed("shoot"):
		if not reloading and current_ammo > 0:
			$Camroot/Helper/Camera/Gun/emptysound.stop()
			$Camroot/Helper/Camera/Gun/audiobullet.play()
			
			$Camroot/Helper/Camera/Gun/AnimationPlayer.play("muzzle_flash")
			
			current_ammo -= 1
			current_ammo_label.text = str(current_ammo)
			
			if $Camroot/Helper/Camera/RayCast.is_colliding():
				var collider = $Camroot/Helper/Camera/RayCast.get_collider()
				var collisionpoint = $Camroot/Helper/Camera/RayCast.get_collision_point()
				
				var impactsound = tempaudioplayer.instance()
				impactsound.global_transform.origin = collisionpoint
				
				if collider.is_in_group("metal"):
					impactsound.stream = preload("res://audio/bullet hit sounds/Bullet Hits/Metal/MetalHit 2.wav")
				
				get_tree().get_root().add_child(impactsound)
				impactsound.play()
				
				if collider is RigidBody:
					print_debug(collisionpoint.normalized())
	#				collider.apply_central_impulse(-$Camroot/Helper/Camera/RayCast.get_collision_normal() * 5 ) # 5 would be the bullet's speed/strength, get it from a variable if needed
					collider.apply_impulse(collisionpoint.normalized(), -$Camroot/Helper/Camera/RayCast.get_collision_normal() * 50 ) # 5 would be the bullet's speed/strength, get it from a variable if needed
	#				collider.apply_impulse(collisionpoint, Vector3(-$Camroot/Helper/Camera/RayCast.get_collision_normal().x, -$Camroot/Helper/Camera/RayCast.get_collision_normal().y, -$Camroot/Helper/Camera/RayCast.get_collision_normal().z) * 5 ) # 5 would be the bullet's speed/strength, get it from a variable if needed
					
				if collider.is_in_group("rope"):
					collider.get_parent().queue_free()
				
			$Camroot/Helper.rotate_x(0.2)
			$Camroot.camrot_v += 5
		elif not reloading and current_ammo <= 0:
			$Camroot/Helper/Camera/Gun/emptysound.play()
		
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



func reload():
	if current_ammo < mag_size and remaining_mags > 0:
		$Camroot/Helper/Camera/Gun/emptysound.stop()
		$Camroot/Helper/Camera/Gun/AnimationPlayer.play("reload")
#		reload()

func reload_func():
#	var clip = min(1, remaining_mags/mag_size)
#	print
	var how_much_to_reload = mag_size - current_ammo
	current_ammo += how_much_to_reload
	remaining_mags = max(0, remaining_mags - how_much_to_reload)
	print_debug( "remaining mags: " + str(remaining_mags) )
	print_debug( "how much to reload: " + str(how_much_to_reload) )
	$HUD/HBoxContainer/labelCurrentAmmo.text = str(current_ammo)
	$HUD/HBoxContainer/labelAmmoLeft.text = str(remaining_mags)
#

func interact_raycast():
	if interactraycast.is_colliding():
		$HUD.interacttext.visible = true
		if Input.is_action_just_pressed("interact"):
			interactraycast.get_collider().get_parent().interact(self)
	else:
		if $HUD.interacttext.visible:
			$HUD.interacttext.visible = false

##	current_ammo = current
#
#	var clip
#	if remaining_mags >= mag_size:
#		clip = mag_size
#		remaining_mags -= mag_size
#	else:
#		clip = remaining_mags
#		remaining_mags -= remaining_mags
#	current_ammo += clip
#	remaining_mags -= mag_size
	

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

