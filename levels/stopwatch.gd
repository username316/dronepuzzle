extends Node

var time_elapsed: float = 0.0
var started: bool = false

func _process(delta: float) -> void:
	if started:
		time_elapsed += delta

func stop():
	started = false
	
func start():
	started = true
	
func get_time_elapsed_str():
	return "%.2f" % time_elapsed
