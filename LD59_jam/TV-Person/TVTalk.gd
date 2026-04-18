extends Label

var talkingFaces : Array = [":)",":D",":o","XD",":|",":/",":("]
var mouthOpen :bool
var yapAttack :bool

func _ready() -> void:
	Global.date_is_happy.connect(on_date_is_happy)
	Global.date_is_neutral.connect(on_date_is_neutral)
	Global.date_is_unhappy.connect(on_date_is_unhappy)
	Global.date_is_talking.connect(on_date_is_talking) #Hook this up somewhere!

func _process(delta):
	if Input.is_action_pressed("ui_home"):
		yapAttack = true
	if yapAttack == true:
		set_talking()

func faceReplace(newText:String):
	text = newText
	
func set_talking(): #This is ment to loop
	if mouthOpen == false:
		await get_tree().create_timer(.1).timeout 
		text = talkingFaces[0]
		mouthOpen = true
	else:
		await get_tree().create_timer(.1).timeout 
		text = talkingFaces[1]
		mouthOpen = false

func set_happy():
	text = talkingFaces[0]
	
func set_neutral():
	text = talkingFaces[4]
	
func set_unhappy():
	text = talkingFaces[6]
	
func on_date_is_happy():
	set_happy()

func on_date_is_neutral():
	set_neutral()
	
func on_date_is_unhappy():
	set_unhappy()

func on_date_is_talking():
	set_talking()
