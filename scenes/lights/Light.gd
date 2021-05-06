extends RigidBody


export var blinking_light = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if blinking_light:
		$Timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$OmniLight.visible = !$OmniLight.visible
