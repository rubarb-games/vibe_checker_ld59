extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_main_scene_ready.emit()
	await get_tree().process_frame
	Global.main_scene_ready.emit()
	await get_tree().process_frame
	Global.post_main_scene_ready.emit()
