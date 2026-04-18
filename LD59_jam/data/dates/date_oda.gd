extends DateObject


func setup():
	texture_happy = load("res://art/oda/oda_happy.png")
	texture_neutral = load("res://art/oda/oda_neutral.png")
	texture_sad = load("res://art/oda/oda_unhappy.png")
	
	topic_A = "Green triangles are nice"
	topic_B = "Blue circles are the best"
	topic_opinion = 0.0
	
	preferred_speaking_time = 2.0
	preferred_silence_time = -1

	mouth_marker_position = Vector2(560.0,295.0)
