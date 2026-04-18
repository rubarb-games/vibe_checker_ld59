extends Node

var main_state:Global.State

var root:Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.state_changed.connect(on_state_changed)
	Global.pre_main_scene_ready.connect(on_pre_main_scene_ready)
	
func setup():
	get_refs()
	main_state = Global.State.END_SCREEN
	root.visible = false
	
func get_refs():
	root = get_node("/root/main/end_screen")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func activated():
	root.visible = true
	
func deactivated():
	root.visible = false

func on_state_changed(new_state:Global.State, prev_state:Global.State):
	if new_state == main_state:
		activated()
		
	if prev_state == main_state:
		deactivated()
		
func on_pre_main_scene_ready():
	setup()
