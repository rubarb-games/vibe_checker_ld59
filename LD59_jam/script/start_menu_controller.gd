extends Node

var main_state:Global.State
var root:Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_main_scene_ready.connect(on_pre_main_scene_ready)
	Global.state_changed.connect(on_state_changed)
	
func setup():
	get_refs()
	
	root.get_node("start_game_button").pressed.connect(on_start_game_button_pressed)
	main_state = Global.State.START_MENU
	root.visible = false
	
func get_refs():
	root = get_node("/root/main/start_menu")

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
		
func on_start_game_button_pressed():
	GameManager.set_gameplay()

func on_pre_main_scene_ready():
	setup()
