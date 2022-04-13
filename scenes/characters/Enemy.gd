extends KinematicBody

var move_speed = 10
#export (NodePath) var patrol_path
var patrol_path
var patrol_points
var patrol_index = 0
var velocity = Vector3.ZERO

#var gravity = -100
onready var gravity = -ProjectSettings.get_setting("physics/3d/default_gravity")

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
	look_at(global_transform.origin + velocity,Vector3.UP)
	velocity = direction.normalized() * move_speed
	
#	# Apply gravity.
	#velocity.y = 0
	velocity.y += delta * gravity
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	
