extends Node3D
class_name Level

@onready var camera_top = $CameraTop
@onready var environment = $WorldEnvironment.get_environment()
@onready var rain_particles = $Rain
@onready var pause_menu = $PauseMenu

#environment
@export var fog_density: float = 0.0
@export var raining: bool = false
#@export var gps_available: bool = true

#cameras
var current_camera: Camera3D

func _ready() -> void:
	set_current_camera(camera_top)
	
	pause_menu.visible = false
	
	environment.set_fog_density(fog_density)
	rain_particles.emitting = raining

func _input(event: InputEvent) -> void:
	'if event.is_action_pressed("zoom_in"):
		current_camera.zoom_out()
	if event.is_action_pressed("zoom_out"):
		current_camera.zoom_in()'
		
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
	pass # Replace with function body.

func pause():
	pause_menu.visible = true
	get_tree().paused = true
