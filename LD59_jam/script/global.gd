extends Node

enum State { INITIALIZE, START_MENU, GAMEPLAY, BETWEEN_DATES, SCORE_SCREEN, END_SCREEN, RESTART_GAME}
var state:State 

@onready var anim_curves_A:CurveXYZTexture = preload("res://art/misc/anim_curves_A.tres")

signal pre_main_scene_ready()
signal main_scene_ready()
signal post_main_scene_ready()

signal state_changed(state:State)

# :::::: GAMEPLAY

signal started_speaking()
signal stopped_speaking()

signal date_speaking_start()
signal date_speaking_stop()

signal date_is_happy()
signal date_is_neutral()
signal date_is_unhappy()
