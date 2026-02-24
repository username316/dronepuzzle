extends Node3D

@onready var camera_top = $CameraTop

var current_camera: Camera3D

var rotating_camera = false

func _ready() -> void:
	set_current_camera(camera_top)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		current_camera.zoom_out()
	if event.is_action_pressed("scroll_down"):
		current_camera.zoom_in()
		
	if event.is_action_pressed("mouse_right"):
		rotating_camera = true
	if event.is_action_released("mouse_right"):
		rotating_camera = false
		
	if event is InputEventMouseMotion:
		if rotating_camera:
			var mouse_dir = get_mouse_dir(event.relative.x, event.relative.y)

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
