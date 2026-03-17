extends Node3D

@onready var camera = $Camera3D

@export var initial_y: float = 2.0
@export var initial_z: float = 2.0

@export var rotate_speed: float = 0.002

@export var zoom_speed: float = 0.1
@export var min_zoom: float = 0.8
@export var max_zoom: float = 10.0

var rotating: bool = false

func _ready() -> void:
	camera.position.y = initial_y
	camera.position.z = initial_z
	camera.rotation.x = deg_to_rad(-30)

func zoom(speed):
	camera.translate(Vector3.FORWARD * speed)
	
	camera.position.y = clamp(camera.position.y, min_zoom, max_zoom)
	camera.position.z = clamp(camera.position.z, min_zoom, max_zoom)

func zoom_in():
	zoom(-zoom_speed)
	
func zoom_out():
	zoom(zoom_speed)
	
func _input(event: InputEvent) -> void:
	if !$Camera3D.is_current():
		return
		
	if event.is_action_pressed("zoom_in"):
		zoom_out()
	if event.is_action_pressed("zoom_out"):
		zoom_in()
		
	if event.is_action_pressed("mouse_right"):
		rotating = true
	if event.is_action_released("mouse_right"):
		rotating = false	
	
	if rotating and event is InputEventMouseMotion:
		pivot(event.relative)
	
func pivot(mouse_dir: Vector2):
	rotate(Vector3.UP, mouse_dir.x * rotate_speed)
	camera.rotate(Vector3.RIGHT, mouse_dir.y * rotate_speed)
	
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(5))
