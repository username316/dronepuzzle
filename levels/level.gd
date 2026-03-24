extends Node3D
class_name Level

@onready var drone = $Drone
@onready var camera_top = $CameraTop
@onready var drone_pivot_camera = drone.get_node("CameraPivot/Camera3D")
@onready var environment = $WorldEnvironment.get_environment()
@onready var rain_particles = $Rain
@onready var pause_menu = $LevelUI/PauseMenu
@onready var level_complete_menu = $LevelUI/LevelCompleteMenu
@onready var stopwatch = $LevelUI/Stopwatch
@onready var stopwatch_text = $LevelUI/Stopwatch/Label
@onready var camera_feed_panel = $LevelUI/CameraVeiwer
@onready var message_display = $LevelUI/MessageDisplay

#environment
@export var fog_density: float = 0.0
@export var raining: bool = false

#cameras
var current_camera: Camera3D

func _ready() -> void:
	set_current_camera(drone_pivot_camera)
	
	pause_menu.visible = false
	level_complete_menu.visible = false
	
	environment.set_fog_density(fog_density)
	rain_particles.emitting = raining
	
	stopwatch.start()
	
	update_camera_feed_layout()
	get_viewport().size_changed.connect(update_camera_feed_layout)
	
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	stopwatch_text.text = str(stopwatch.get_time_elapsed_str())

func set_current_camera(cam: Camera3D):
	current_camera = cam
	current_camera.set_current(true)

func get_mouse_dir(x, y):
	#for rotating
	if (abs(x) > abs(y)):
		return Vector2(sign(x), 0)
	elif (abs(x) < abs(y)):
		return Vector2(0, sign(y))
	else:
		return Vector2(0, 0)

func _on_target_body_entered(body: Node3D) -> void:
	stopwatch.stop()
	level_complete_menu.complete_level(stopwatch.time_elapsed)
	
func update_camera_feed_layout() -> void:
	var s := get_viewport().get_visible_rect().size
	var w := s.x * 0.25
	var h := w * 9.0 / 16.0
	var m := s.x * 0.02

	camera_feed_panel.position = Vector2(s.x - w - m, s.y - h - m)
	camera_feed_panel.size = Vector2(w, h)
