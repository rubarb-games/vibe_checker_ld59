extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func setup():
	get_refs()
	
	set_start_menu()
	
func get_refs():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_start_menu():
	change_state(Global.State.START_MENU)
	
func set_gameplay():
	change_state(Global.State.GAMEPLAY)
	
func set_score_menu():
	change_state(Global.State.SCORE_SCREEN)
	
func set_date_transition():
	change_state(Global.State.BETWEEN_DATES)
	
func change_state(state:Global.State):
	var prev_state:Global.State = Global.state
	
	if state == Global.state:
		return
	
	Global.state = state
	Global.state_changed.emit(state, prev_state)
