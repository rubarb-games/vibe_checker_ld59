extends Label

signal tvFaceTalk
signal tvFaceListen

var talkingFaces : Array = [":D",":)",":o","XD"]

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
