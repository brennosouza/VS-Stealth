extends Spatial


onready var player = get_tree().get_nodes_in_group("player")[0]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
#	if Input.is_action_just_pressed("interact"):
#
#		var direction = self.global_transform.origin.direction_to(player.global_transform.origin)
#		print_debug(direction)
#
#		if direction.z < 0:
#			rotate_y(-90)
#		else:
#			rotate_y(90)
		

func interact(player):
	var direction = self.global_transform.origin.direction_to(player.global_transform.origin)
	print_debug(direction)
	
	if direction.z < 0:
		rotate_y(-90)
	else:
		rotate_y(90)
	
