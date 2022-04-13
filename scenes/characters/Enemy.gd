extends KinematicBody

var move_speed = 5
#export (NodePath) var patrol_path
var patrol_path
var patrol_points
var patrol_index = 0
var velocity = Vector3.ZERO

onready var dummyrotation = $DummyRotation
export var patrol_rotate_speed = 0.5
export var fast_rotate_speed = 0.3
var rotate_speed = patrol_rotate_speed

#var gravity = -100
onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")

onready var tween = $Tween

func _ready():
	patrol_path = get_parent()
	if patrol_path:
		patrol_points = patrol_path.curve.get_baked_points()
		

func _physics_process(delta):
	if !patrol_path:
		return
	var target = patrol_points[patrol_index]
	if global_transform.origin.distance_to(target) < 5:
		patrol_index = wrapi(patrol_index + 1, 0, patrol_points.size())
		target = patrol_points[patrol_index]
#		target.y = 0
	var direction = target - global_transform.origin
	
	#Codigo de virar para a direção sem tween
#	look_at(global_transform.origin + velocity,Vector3.UP)
	
#	$DummyRotation.look_at(global_transform.origin + velocity,Vector3.UP)
#	transform.interpolate_with(dummyrotation.transform, 1)
	
	global_transform.basis = global_transform.basis.slerp(
		global_transform.looking_at(global_transform.origin + velocity, Vector3.UP).basis, delta * 5.0 )
	rotation_degrees.x = 0
	rotation_degrees.z = 0

#	var transform_to_rotate = self.global_transform.looking_at(global_transform.origin + velocity,Vector3.UP)
#	tween.interpolate_property(self, "transform:basis", self.transform.basis, transform_to_rotate.basis, fast_rotate_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	tween.start()
	
	velocity = direction.normalized() * move_speed
	
	if velocity != Vector3.ZERO:
		playfootsteps(true)
		
	
#	# Apply gravity.
	#velocity.y = 0
	velocity.y += delta * gravity
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	


func playfootsteps(wait: bool):
#	print_debug($FootstepsPlayer/Timer.wait_time)
	if !$FootstepsPlayer.playing:
		
#		if current_speed == run_speed:
#				$FootstepsPlayer.unit_db = 2
#				$FootstepsPlayer.unit_size = 3
#				$FootstepsPlayer/Timer.wait_time = 0.1
#		else:
#			if $FootstepsPlayer.unit_db != originaldb:
#				$FootstepsPlayer.unit_db = originaldb
#				$FootstepsPlayer.unit_size = original_unit_size
#				$FootstepsPlayer/Timer.wait_time = original_wait_time
				
		if wait: #and !waitfootsteps:
#			print_debug("here")
			$FootstepsPlayer.play()
#			waitfootsteps = true
			$FootstepsPlayer/Timer.start()
		elif !wait:
			$FootstepsPlayer.play()
		
		if $FootstepsPlayer.pitch_scale == 1:
			$FootstepsPlayer.pitch_scale = 1.2
		else:
			$FootstepsPlayer.pitch_scale = 1
