extends Label

signal tvFaceTalk
signal tvFaceListen

var talkingFaces : Array = [":D",":)",":o","XD"]

func _ready() -> void:
	Global.date_is_happy.connect(on_date_is_happy)
	Global.date_is_neutral.connect(on_date_is_neutral)
	Global.date_is_unhappy.connect(on_date_is_unhappy)

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		faceReplace(":)")
	else:
		faceTalking()
func faceReplace(newText:String):
	text = newText
	
func faceTalking():
	for i in talkingFaces.size():
		await get_tree().create_timer(.2).timeout 
		text = talkingFaces[i]

func set_happy():
	text = talkingFaces[0]
	
func set_neutral():
	text = talkingFaces[1]
	
func set_unhappy():
	text = talkingFaces[2]
	
func on_date_is_happy():
	set_happy()

func on_date_is_neutral():
	set_neutral()
	
func on_date_is_unhappy():
	set_unhappy()
