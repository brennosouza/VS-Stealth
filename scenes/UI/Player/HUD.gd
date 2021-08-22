extends Control


onready var interacttext = $"InteractText"

# Called when the node enters the scene tree for the first time.
func _ready():
	var text = $InteractText.text.replace("BUTTON", InputMap.get_action_list("interact")[0].as_text() )
	$InteractText.text = text
	interacttext.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
