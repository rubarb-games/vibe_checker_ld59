extends DateObject


func setup():
	texture_happy = load("res://art/date_default_happy.png")
	texture_neutral = load("res://art/date_default_neutral.png")
	texture_sad = load("res://art/date_default_unhappy.png")
	
	preferred_speaking_time = 6.0
	preferred_silence_time = -1.0

	topic_A = "Cola is good"
	topic_B = "Pepsi.. MMmm"
	topic_opinion = 1.0

	mouth_marker_position = Vector2(560.0,225.0)
	
	date_scene = load("res://TV-Person/TV-Face.tscn")
