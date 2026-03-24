extends Node

var start_menu_path = "res://ui/StartMenu.tscn"
var levels_folder_path = "res://levels/"

var current_scene = start_menu_path

var level_paths: Array[String]

func _ready() -> void:
	current_scene =  get_tree().root.get_child(-1)
	load_levels_from_dir(levels_folder_path)
	#print(level_paths)

func change_scene_to_path(path: String):
	current_scene.queue_free()
	current_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(current_scene)
	
	SoundManager.connect_sounds()

func load_levels_from_dir(path: String):
	var dir = DirAccess.open(path)
	if dir:
		for f: String in dir.get_files():
			if f.begins_with("Level") and f.ends_with(".tscn"):
				level_paths.append(f)


var vision_enabled: bool = true
var lidar_enabled: bool = true
var minThrust: float = 0.00
var maxThrust: float = 60.0
var brakeStrength: float = 8.0
var lidarStopRange: float = 9.0
var tiltSpeed: float = 3.0
