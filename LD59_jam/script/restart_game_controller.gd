extends Node

var main_state:Global.State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_main_scene_ready.connect(on_pre_main_scene_ready)
	Global.state_changed.connect(on_state_changed)


func setup():
	main_state = Global.State.RESTART_GAME

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func activated():
	pass
	
func deactivated():
	pass

func on_state_changed(new_state:Global.State, prev_state:Global.State):
	if new_state == main_state:
		activated()
		
	if prev_state == main_state:
		deactivated()
		
func on_pre_main_scene_ready():
	setup()
