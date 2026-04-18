class_name DateObject extends Node

var date_name:String
var topic_A:String = ""
var topic_B:String = ""

var topic_opinion:float = 1.0

var texture_happy:Texture
var texture_sad:Texture
var texture_neutral:Texture
var texture_speaking:Texture

var preferred_speaking_time:float = 1.0
var preferred_silence_time:float = 1.0

var mouth_marker_position:Vector2

var date_scene:PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup()
	
func setup():
	pass
