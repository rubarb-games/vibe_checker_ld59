extends Node

enum State { INITIALIZE, START_MENU, GAMEPLAY, BETWEEN_DATES, SCORE_SCREEN, END_SCREEN, RESTART_GAME}
var state:State 

signal pre_main_scene_ready()
signal main_scene_ready()
signal post_main_scene_ready()

signal state_changed(state:State)
