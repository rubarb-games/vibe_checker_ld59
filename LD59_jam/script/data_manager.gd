extends Node3D

var all_dates:Array[Script]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_main_scene_ready.connect(on_main_scene_ready)
	
func get_refs():
	get_resources_from_folder("res://data/dates",all_dates)
	
func on_main_scene_ready():
	get_refs()

func get_entry(item_name:String,arr:Array):
	var i:int = arr.find_custom(func(i:Script): return true if i.get_global_name() == item_name else false)
	if i != -1:
		return arr[i] as Script


func get_resources_from_folder(path:String,arr_to_populate:Array):
	arr_to_populate.clear() # remove from previous run
	var dir = DirAccess.open(path)
	if (dir):
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.contains(".uid"):
					file_name = dir.get_next()
					continue
				var full_path = path + "/" + file_name.trim_suffix(".remap")
				var resource = load(full_path)
				if resource:
						arr_to_populate.append(resource)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occured while trying to access the path %s" % path)
		return false
		
	return true
	
