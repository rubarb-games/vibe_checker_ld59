class_name  AudioManager extends Node

@onready var man_talking_neutral:AudioStreamPlayer2D = %man_talking_neutral

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.started_speaking.connect(on_talking.bind("start"))
	Global.stopped_speaking.connect(on_talking.bind("stop"))
	
func on_talking(action:String):
	match action:
		"start":
			man_talking_neutral.play()
		"stop":
			man_talking_neutral.stop()
