extends Node

var main_state:Global.State
var root:Control
var status_label:Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_main_scene_ready.connect(on_pre_main_scene_ready)
	Global.state_changed.connect(on_state_changed)
	

func setup():
	get_refs()
	
	main_state = Global.State.BETWEEN_DATES
	root.visible = false
	
func get_refs():
	root = get_node("/root/main/between_dates")
	status_label = root.get_node("status_label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func activated():
	root.visible = true
	await popup_status_message("Wow! Your date liked you.. "+str(round(GameplayController.current_date_affection))+"%" )
	await popup_status_message("NEXT!")
	GameManager.set_gameplay()
	
func deactivated():
	root.visible = false

func popup_status_message(msg:String):
	status_label.text = msg
	
	SimonTween.stop_tweens_with_tag("status_message")
	await get_tree().process_frame
	
	status_label.modulate.a = 0.0
	
	await SimonTween.start_tween(status_label,"modulate:a",1.0,0.5,Global.anim_curves_A.curve_x).tag("status_message").tween_finished
	await SimonTween.start_tween_time(2.0).tag("status_message").tween_finished
	await SimonTween.start_tween(status_label,"modulate:a",0.0,0.5,Global.anim_curves_A.curve_x).tag("status_message").tween_finished
	
	return true

func on_state_changed(new_state:Global.State, prev_state:Global.State):
	if new_state == main_state:
		activated()
		
	if prev_state == main_state:
		deactivated()
		
func on_pre_main_scene_ready():
	setup()
