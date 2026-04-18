extends Node

var activeTweens:Array = []
var locked_tags:Array = []

var verbose_output:bool = false

var default_tag:String = ""

enum State { PLAYING, PAUSED, IDLE, STEPPED }
enum Mode {NORMAL, PINGPONG, LOOPING, REVERSED, LOOPING_PINGPONG}
var ts:State = State.IDLE
var tt = Mode.NORMAL

#signal tweenDone
#signal tweenDoneFullChain
#signal tweenResumed
#signal tweenPaused
#signal fullChainLoopDone

var revise_tween_list: bool = false

class singleTween:

	var verbose_debug:bool = false

	var ts:State = State.IDLE
	var tt = Mode.NORMAL
	var isRelative:bool = false
	var isFullChainLooping:bool = false
	var no_object:bool = false

	var obj:Node
	var pPath:NodePath
	var rawProperty:String
	var endResult
	var time:float = 1.0
	var time_elapsed:float = 0.0
	var intCurve:Curve
	var modDValue
	var initialValue
	var loops:int = 0
	var breakLoop:bool = false
	var snap_to_value:bool = false
	var snap_to_start_value:bool = false
	var slerp_mode:bool = false

	var deltaValue:float
	var totalTweenMovement:Variant
	var sceneTreeHandle:SceneTree

	var last_tweened_property

	var indexed_property = true

	var is_tween_active = false
	var is_tween_finished = false
	var is_tween_finished_deferred = false
	var is_subsequent_tween = false
	var subsequent_tweens = []
	
	var func_to_call:Callable
	var current_value
	var value_only:bool = false

	var tween_speed:float = 1.0
	
	var tag_value:String = ""
	
	var tween_manager_handle

	signal tween_finished
	#signal tween_looped
	#signal new_subsequent_tween(tween:singleTween)

	func another():
		var a = singleTween.new()
		a.is_subsequent_tween = true
		subsequent_tweens.append(a)
		return a

	func set_relative(rel):
		isRelative = rel
		return self

	func set_start_snap(s:bool):
		snap_to_start_value = s
		return self

	func set_end_snap(s:bool):
		snap_to_value = s
		return self

	func set_loops(l):
		loops = l
		return self

	func set_callable(c:Callable):
		if c.get_argument_count() < 1:
			return false
		func_to_call = c
		return true

	func start_tween(p_tween_manager_handle, objArg:Object,propPath:String,endResultArg,timeArg,intCurveArg,typ = Mode.NORMAL,is_value_only:bool = false, start_value:Variant = null,p_tag:String = ""):
		tween_manager_handle = p_tween_manager_handle #Assign the top-level class-handle
		if objArg == null:
			no_object = true
		tag_value = p_tag
		if (time <= 0 or time > 100):
			return self

		if (!intCurveArg):
			intCurve = Curve.new()
			intCurve.add_point(Vector2(0,0),1.0,1.0,Curve.TANGENT_LINEAR,Curve.TANGENT_LINEAR)
			intCurve.add_point(Vector2(1,1),1.0,1.0,Curve.TANGENT_LINEAR,Curve.TANGENT_LINEAR)
		else:
			intCurve = intCurveArg

		tt = typ
		
		value_only = is_value_only

		obj = objArg
		rawProperty = propPath
		#pPath = NodePath(propPath)
		
		if !value_only:
			if !obj:
				print_rich("[color=RED]Invalid object. Cancelling tween...")
				return false
				
			if (typeof(get_tweened_value()) != typeof(endResultArg)):
				print_rich("[color=RED]Type mismatch in tween for "+str(obj.name)+" - Tried to match "+type_string(typeof(get_tweened_value()))+" with "+type_string(typeof(endResultArg))+". Cancelling tween...")
				return false
			
			initialValue = get_tweened_value()
			
			if (verbose_debug):
				print_rich("[color=AQUA] Testing "+str(rawProperty))
			if (rawProperty in obj):
				indexed_property = false
			else:
				pass
		else:
			initialValue = start_value

		time = timeArg
		endResult = endResultArg
		
		#Initiate
		if (!is_subsequent_tween):
			initiate_tween()

		return self

	func get_tweened_value():
		if (!is_instance_valid(obj)):
			force_finish_tween()

		if (indexed_property and !is_tween_finished):
			last_tweened_property = obj.get_indexed(rawProperty)
		elif (!is_tween_finished):
			last_tweened_property = obj.get(rawProperty)

		return last_tweened_property

	func get_value():
		if value_only:
			return current_value
		else:
			return get_tweened_value()

	func set_tweened_value(val):
		if value_only:
			current_value = val
			return
		
		if (!is_instance_valid(obj)):
			return

		if (indexed_property):
			obj.set_indexed(rawProperty,val)
		else:
			obj.set(rawProperty,val)

	func set_slerp(val):
		slerp_mode = val
		return self

	func initiate_tween():
		deltaValue = 0
		time_elapsed = 0
		is_tween_finished = false
		is_tween_active = true
		if value_only:
			current_value = initialValue
		else:
			initialValue = get_tweened_value()
			modDValue = get_tweened_value() - get_tweened_value()
		#initialValue = get_tweened_value()

	func process_tween(delta):
		#if tween is paused
		if (!is_tween_active or is_tween_finished):
			return false

		if !obj and !no_object:
			force_finish_tween()
			return false
			
		# Quit if tween tries to run a callable on a freed object
		if func_to_call and (func_to_call as Callable).get_object() == null:
			force_finish_tween()
			return false

		if (is_tween_finished_deferred):
			is_tween_finished_deferred = false
			force_finish_tween()
			return false
			
		#Cache previous frame modified delta value
		var prevMod = modDValue
		#New var to be modified with offset
		var factor = clamp(time_elapsed/time,0,1)
		if (tt == Mode.PINGPONG):
			factor = factor if factor < 1 else 2 - factor
		
		#Main delta value - assign to progress towards goal so far
		var modDMod = (intCurve.sample(factor) * endResult)
		#Caching value for retrieval next frame
		modDValue = modDMod
		
		if (verbose_debug):
			print_rich("[color=AQUA] Time: "+str(time_elapsed)+" / "+str(time)+" * "+str(endResult)+" = "+str(lerp(initialValue,endResult,(intCurve.sample(factor))))+" And the actual result is... "+str(get_tweened_value()))

		#IF: you're only tweening a value
		if value_only:
			current_value = lerp(initialValue,endResult,intCurve.sample(factor))
			if (func_to_call):
				func_to_call.call(current_value)
		else:
			#ELSE: if you're tweening properties on an object
			#Relative accounts for other transformations happening inbetween by offsetting 
			#the animation by previous frame's transform
			if (isRelative):
				var deltaMod = modDMod - prevMod
				#print(get_tweened_value())
				modDMod = get_tweened_value() + deltaMod
			else:
				if (slerp_mode):
					modDMod = lerp_angle(initialValue,endResult,intCurve.sample(factor))
				else:
					modDMod = lerp(initialValue,endResult,intCurve.sample(factor))
					
			#Send the updated value to a callable each frame instead of modifying some attribute
			set_tweened_value(modDMod)

		return check_tween_condition(delta)

	func check_tween_condition(delta):
		time_elapsed += delta * tween_speed
		match tt:
			Mode.NORMAL:
				if time_elapsed >= time or breakLoop:
					return finish_tween()
			Mode.PINGPONG:
				if time_elapsed >= (time * 2) or breakLoop:
					return finish_tween()
			Mode.LOOPING:
				if ((time_elapsed/time >= loops) and loops != -1) or breakLoop:
					return finish_tween()
		return false

	func restart_tween():
		initiate_tween()
		return self
	
	func reset_tween():
		set_start_snap(true)
		force_finish_tween()
	
	func pause():
		is_tween_active = false
		return self

	func play():
		is_tween_active = true
		return self

	func set_time(t:float):
		time_elapsed = t

	func set_end_result(endRes:Variant):
		endResult = endRes
	
	func set_tween_speed(s:float):
		tween_speed = s

	func tag(p_tag:String):
		if tween_manager_handle.is_tag_locked(p_tag):
			if (verbose_debug):
				print_rich("[color=AQUA] Tag \"%s\" is locked. Force quitting tween" % p_tag)
			force_finish_tween_deferred()
		else:
			tag_value = p_tag
		return self
		

	func apply_snap():
		if (snap_to_value):
			set_tweened_value(endResult)

		if (snap_to_start_value):
			set_tweened_value(initialValue)

	func finish_tween(_skip_all:bool = false):
		#Looping
		if (!breakLoop):
			if (loops > 0):
				loops -= 1
				restart_tween()
				return false
			elif loops == -1:
				restart_tween()
				return false

		apply_snap()

		is_tween_finished = true
		tween_finished.emit()
		
		return true

	func force_finish_tween_deferred():
			is_tween_finished_deferred = true

	func force_finish_tween():
			is_tween_finished = true
			apply_snap()
			
			tween_finished.emit()

			return true

func _process(delta: float) -> void:
	for tween:singleTween in activeTweens:
		#If the tween is finished
		if (tween.process_tween(delta)):
			if (verbose_output):
				print_rich("[color=AQUA] tween is finished...")
			#Start next tween if there's more subsequent ones - If there are, trigger all of them
			if (tween.subsequent_tweens.size() > 0):
				for t in tween.subsequent_tweens:
					activeTweens.append(t)
					t.initiate_tween()
			revise_tween_list = true

	#Build new list consisting of only unfinished tweens.
	if revise_tween_list:
		activeTweens = activeTweens.filter(func(tw): return tw.is_tween_finished == false)
		revise_tween_list = false

func start_tween_time(timeArg,p_tag:String=default_tag):
	if (verbose_output):
		print_rich("[color=CORAL][font_size=32] Stating new timer tween! Sounds good")
		
	var tween = singleTween.new()
	activeTweens.append(tween)
	if (!tween.start_tween(self, null, "",0.0,timeArg,null,Mode.NORMAL,true,0.0,p_tag)):
		return null
	
	return tween
	
func start_tween_callable(start_value,end_value,c:Callable,timeArg,intCurveArg = null,typ = Mode.NORMAL,p_tag:String=default_tag):
	if (verbose_output):
		print_rich("[color=CORAL][font_size=32] Stating new tween to modify attribute "+str(start_value)+" to value "+str(end_value)+" ! Sounds good")
		
	if is_tag_locked(p_tag):
		return null
		
	var tween = singleTween.new()
	activeTweens.append(tween)
	if !tween.set_callable(c):
		return null
	if (!tween.start_tween(self, null, "",end_value,timeArg,intCurveArg,typ,true,start_value,p_tag)):
		return null
	
	return tween

func start_tween(objArg:Node, propPath:String, endResultArg, timeArg:float = 1, intCurveArg:Curve = null, typ = Mode.NORMAL,p_tag:String=default_tag):
	if (verbose_output):
		print_rich("[color=CORAL][font_size=32] Stating new tween on object: "+str(objArg.name)+" to modify attribute "+str(propPath)+" to value "+str(endResultArg)+" ! Sounds good")
		
	var tween = singleTween.new()
	if is_tag_locked(p_tag):
		return tween
		
	activeTweens.append(tween)
	if (!tween.start_tween(self, objArg,propPath,endResultArg,timeArg,intCurveArg,typ,false,null,p_tag)):
		return null
	
	activeTweens.append(tween)	
	return tween

func get_tweens_with_tag(tag:String) -> Array:
	var tweens_with_tag:Array = []
	if tag == "all":
		tweens_with_tag = activeTweens.duplicate()
	else:
		tweens_with_tag = activeTweens.filter(func(v:singleTween): return true if v.tag_value == tag else false)
	return tweens_with_tag

func get_tweens_from_object(object:Node) -> Array:
	var tweens_from_object:Array = []
	tweens_from_object = activeTweens.filter(func(v:singleTween): return true if v.obj == object else false)
	return tweens_from_object
	
func object_has_tweens(object:Node):
	if get_tweens_from_object(object).size() > 0:
		return true
	else:
		return false

func tag_has_tweens(tag:String):
	return true if get_tweens_with_tag(tag).size() > 0 else false 

func object_has_active_tag(obj:Node,tag:String):
	var tags:Array = get_tweens_with_tag(tag)
	for tw:singleTween in tags:
		if tw.obj == obj:
			return true
	return false

func stop_tweens_with_tag(tag:String):
	var tweens:Array = get_tweens_with_tag(tag)
	for t:singleTween in tweens:
		t.force_finish_tween_deferred()

func set_default_tween_tag(tag:String):
	default_tag = tag

func is_tag_locked(tag:String):
	return true if locked_tags.has(tag) else false

func lock_tag(tag:String):
	if !locked_tags.has(tag):
		locked_tags.append(tag)

func unlock_tag(tag:String):
	if locked_tags.has(tag):
		locked_tags.erase(tag)
