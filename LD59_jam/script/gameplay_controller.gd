extends Node

var main_state:Global.State

var root:Control
var status_label:Label
var timer:TextureRect
var talking_indicator:Control
var date_handle:Control

var current_date_data:DateObject
var conversation_spectrum_handle:Control

var spectrum_width:float = 660.0

var total_time:float = 16.0
var current_time:float = 0.0

var time_speaking:float = 0.0
var time_silence:float = 0.0

var date_speaker_timer:float = 0.0
var date_max_speak_timer:float = 3.0
var is_date_speaking:bool = false

var date_speak_interval_range:Vector2 = Vector2(1.0,6.0)
var next_date_speak_interval:float = 0.0

var is_speaking:bool = false
var gameplay_active:bool = false

var current_date_affection:float = 50.0

signal timer_out()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_main_scene_ready.connect(on_pre_main_scene_ready)
	Global.state_changed.connect(on_state_changed)
	
func setup():
	get_refs()
	main_state = Global.State.GAMEPLAY
	
	root.visible = false
	
	setup_speaking_tweens()
	disable_conversation_spectrum()
	stop_speaking()
	date_stop_speaking()
	
	#setup_date()
	
func get_refs():
	root = get_node("/root/main/gameplay")
	status_label = root.get_node("status_label")
	timer = root.get_node("timer")
	talking_indicator = root.get_node("talking")
	date_handle = root.get_node("date")
	conversation_spectrum_handle = root.get_node("theme_spectrum_transform/theme_spectrum")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gameplay_active:
		current_time += delta
		
		if Input.is_action_just_pressed("Speak") and !is_speaking:
			start_speaking()
		
		if Input.is_action_just_released("Speak") and is_speaking:
			stop_speaking()
			
		if is_speaking:
			time_speaking += delta
			time_silence = clamp(time_silence - (delta * 6.0),0.0,1000.0)
		else:
			time_silence += delta
			clamp(time_speaking - (delta * 6.0),0.0,1000.0)
			
		if conversation_spectrum_handle.visible:
			update_spectrum_cursor()
		
		update_timer()
		evaluate_speaking_time(delta)
		
		date_speaker_timer += delta	
		if is_date_speaking:
			#
			if date_speaker_timer > date_max_speak_timer:
				date_stop_speaking()
		else:
			if date_speaker_timer > next_date_speak_interval:
				date_start_speaking()

			#evaluate_date_mood()

func setup_date():
	var date:DateObject = DateObject.new()
	date.set_script(DataManager.all_dates.pick_random())
	
	date.setup()
	get_node("/root/main/dating_pool").add_child(date)
	
	date_handle.get_node("mouth").position = date.mouth_marker_position
	
	conversation_spectrum_handle.get_node("theme_A").text = date.topic_A
	conversation_spectrum_handle.get_node("theme_B").text = date.topic_B
	current_date_data = date
	
	date_handle.get_node("date_texture").texture = date.texture_neutral
	
func evaluate_date_mood():
	if current_date_affection < 50.0:
		date_handle.get_node("date_texture").texture = current_date_data.texture_sad
	elif current_date_affection < 75.0:
		date_handle.get_node("date_texture").texture = current_date_data.texture_neutral
	else:
		date_handle.get_node("date_texture").texture = current_date_data.texture_happy

func evaluate_speaking_time(delta:float):
	var modified_delta = delta + (delta * get_marker_factor())
	var date_topic_tolerance:float = 0.9
		
	
	if is_speaking:
		if is_date_speaking:
			#date_handle.get_node("date_texture").texture = current_date_data.texture_sad
			current_date_affection -= delta
			return
		
		if (time_speaking > current_date_data.preferred_speaking_time or (abs(current_date_data.topic_opinion - get_marker_factor()) > date_topic_tolerance)) and current_date_data.preferred_speaking_time != -1:
			#date_handle.get_node("date_texture").modulate = Color.RED
			date_handle.get_node("date_texture").texture = current_date_data.texture_sad
			current_date_affection -= delta
		else:
			date_handle.get_node("date_texture").texture = current_date_data.texture_happy
			current_date_affection += modified_delta
	else:
		if time_silence > current_date_data.preferred_silence_time and current_date_data.preferred_silence_time != -1 :
			date_handle.get_node("date_texture").texture = current_date_data.texture_sad
			current_date_affection -= delta
		else:
			date_handle.get_node("date_texture").texture = current_date_data.texture_neutral
			#current_date_affection 

func setup_speaking_tweens():
	var voice_object:Control = talking_indicator.get_node("talking_voice_lines")
	voice_object.rotation = deg_to_rad(-15.0)
	SimonTween.start_tween(voice_object,"rotation",deg_to_rad(45.0),0.2,Global.anim_curves_A.curve_y).set_start_snap(true).set_loops(-1).set_relative(true)
	SimonTween.start_tween(talking_indicator,"rotation",deg_to_rad(10.0),0.1,Global.anim_curves_A.curve_y).set_start_snap(true).set_loops(-1).set_relative(true)

func date_start_speaking():
	is_date_speaking = true
	date_handle.get_node("mouth").visible = true
	date_speaker_timer = 0.0
	Global.date_speaking_start.emit()

func date_stop_speaking():
	next_date_speak_interval = randf_range(date_speak_interval_range.x,date_speak_interval_range.y)
	is_date_speaking = false
	date_handle.get_node("mouth").visible = false
	Global.date_speaking_stop.emit()

func start_speaking():
	is_speaking = true
	time_speaking = 0.0
	talking_indicator.visible = true
	Global.started_speaking.emit()
	#popup_conversation_spectrum()
	await SimonTween.start_tween(talking_indicator,"scale",Vector2.ONE,0.1,Global.anim_curves_A.curve_x).set_end_snap(true).tween_finished

func stop_speaking():
	is_speaking = false
	time_silence = 0.0
	Global.stopped_speaking.emit()
	#disable_conversation_spectrum()
	await SimonTween.start_tween(talking_indicator,"scale",Vector2.ONE * 0.6,0.1,Global.anim_curves_A.curve_x).set_end_snap(true).tween_finished
	talking_indicator.visible = false

func activated():
	root.visible = true
	update_timer()
	setup_date()
	await popup_status_message("Start dating!")
	gameplay_active = true
	current_time = 0.0
	
func update_timer():
	var old_time = timer.get_node("timer_label").text
	var new_time = ceil(total_time - current_time)
	if float(old_time) != new_time:
		SimonTween.start_tween(timer.get_node("timer_label"),"scale",Vector2.ONE*1.2,0.25,Global.anim_curves_A.curve_z)
		timer.get_node("timer_label").text = "%d" % new_time
		
		if current_time > total_time:
			time_run_out()
	
func time_run_out():
	timer_out.emit()
	gameplay_active = false
	stop_speaking()
	date_stop_speaking()
	await popup_status_message("STOP!")
	GameManager.set_between_dates()
	
func popup_conversation_spectrum():
	conversation_spectrum_handle.visible = true
	conversation_spectrum_handle.size.x = 0.0
	conversation_spectrum_handle.position.x = spectrum_width / 2.0
	SimonTween.stop_tweens_with_tag("spectrum_fade")
	await get_tree().process_frame
	
	SimonTween.start_tween(conversation_spectrum_handle,"size:x",spectrum_width,0.35,Global.anim_curves_A.curve_x).tag("spectrum_fade").set_end_snap(true)
	SimonTween.start_tween(conversation_spectrum_handle,"position:x",0.0,0.35,Global.anim_curves_A.curve_x).tag("spectrum_fade").set_end_snap(true)
	var theme_A = conversation_spectrum_handle.get_node("theme_A")
	popup_theme_text(theme_A)
	var theme_B = conversation_spectrum_handle.get_node("theme_B")
	popup_theme_text(theme_B)

func disable_conversation_spectrum():
	SimonTween.stop_tweens_with_tag("spectrum_fade")
	await get_tree().process_frame
	
	SimonTween.start_tween(conversation_spectrum_handle,"size:x",0.0,0.35,Global.anim_curves_A.curve_x).set_end_snap(true).tag("spectrum_fade").tween_finished
	await SimonTween.start_tween(conversation_spectrum_handle,"position:x",spectrum_width / 2.0,0.35,Global.anim_curves_A.curve_x).tag("spectrum_fade").set_end_snap(true).tween_finished
	conversation_spectrum_handle.visible = false
	conversation_spectrum_handle.get_node("theme_A").modulate.a = 0.0
	conversation_spectrum_handle.get_node("theme_B").modulate.a = 0.0
	
func update_spectrum_cursor():
	var marker_x_position:float = (get_viewport().get_mouse_position().x / get_viewport().get_visible_rect().size.x) * conversation_spectrum_handle.size.x
	
	#if !is_speaking:
		#marker_x_position = conversation_spectrum_handle.size.x / 2.0
		
	conversation_spectrum_handle.get_node("marker").position.x = marker_x_position
	

func get_marker_factor():
	var factor = clamp(conversation_spectrum_handle.get_node("marker").position.x / conversation_spectrum_handle.size.x,0.0,1.0)
	return factor
	
func popup_theme_text(obj:Label):
	obj.modulate.a = 0.0
	obj.position.y = 0.0
	SimonTween.start_tween(obj,"modulate:a",1.0,0.25)
	SimonTween.start_tween(obj,"position:y",-40.0,0.25)
	#obj.text = theme
	
func popup_status_message(msg:String):
	status_label.text = msg
	
	SimonTween.stop_tweens_with_tag("status_message")
	await get_tree().process_frame
	
	status_label.modulate.a = 0.0
	
	await SimonTween.start_tween(status_label,"modulate:a",1.0,0.5,Global.anim_curves_A.curve_x).tag("status_message").tween_finished
	await SimonTween.start_tween_time(0.5).tag("status_message").tween_finished
	await SimonTween.start_tween(status_label,"modulate:a",0.0,0.5,Global.anim_curves_A.curve_x).tag("status_message").tween_finished
	
	return true
	
func deactivated():
	root.visible = false

func on_state_changed(new_state:Global.State, prev_state:Global.State):
	if new_state == main_state:
		activated()
		
	if prev_state == main_state:
		deactivated()
		
func on_pre_main_scene_ready():
	setup()
