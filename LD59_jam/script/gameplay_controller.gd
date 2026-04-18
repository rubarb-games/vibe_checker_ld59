extends Node

var main_state:Global.State

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.state_changed.connect(on_state_changed)
	main_state = Global.State.GAMEPLAY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_menu_activated():
	pass
	
func start_menu_deactivated():
	pass

func on_state_changed(new_state:Global.State, prev_state:Global.State):
	if new_state == main_state:
		start_menu_activated()
		
	if prev_state == main_state:
		start_menu_deactivated()
		
