class_name  AudioManager extends Node

@onready var man_talking_neutral:AudioStreamPlayer2D = %man_talking_neutral
@onready var date_talking_neutral:AudioStreamPlayer2D = %date_talking_neutral

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.started_speaking.connect(on_talking.bind("start"))
	Global.stopped_speaking.connect(on_talking.bind("stop"))
	
	Global.date_speaking_start.connect(on_date_talking.bind("start"))
	Global.date_speaking_stop.connect(on_date_talking.bind("stop"))
	
func on_talking(action:String):
	match action:
		"start":
			man_talking_neutral.play()
		"stop":
			man_talking_neutral.stop()

func on_date_talking(action:String):
	match action:
		"start":
			date_talking_neutral.play()
		"stop":
			date_talking_neutral.stop()
