extends Node3D

@export var target: Node3D

var zoom_speed = 0.1
var rotate_speed = 0.1
var y_offset = 2.0

func _init() -> void:
	rotation = Vector3(deg_to_rad(-90),0,0)

func _ready() -> void:
	global_position.y = y_offset

func zoom(speed):
	y_offset += speed

func zoom_in():
	zoom(-zoom_speed)
	
func zoom_out():
	zoom(zoom_speed)

func _process(delta: float) -> void:
	global_position.x = target.global_position.x
	global_position.y = target.global_position.y + y_offset
	global_position.z = target.global_position.z
	
func rotate_around_target(mouse_dir):
	#TODO
	pass
