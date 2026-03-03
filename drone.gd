extends Node3D

@export var speed : float = 5.0
@export var target_area : Area3D

func _process(delta):
	if target_area:
		global_position = global_position.move_toward(target_area.global_position,speed * delta)
	
