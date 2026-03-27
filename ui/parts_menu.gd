extends Control

var vision: bool = false
var lidar: bool = false
var minThrust: float = 0.0
var maxThrust: float = 60.0
var brakeStrength: float = 8.0
var lidarStopRange: float = 9.0
var tiltSpeed: float = 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label5.text = str($HSlider.value)
	$Label7.text = str($HSlider2.value)
	$Label9.text = str($HSlider3.value)
	$Label11.text = str($HSlider4.value)
	$Label13.text = str($HSlider5.value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_vision_toggled(toggled_on: bool) -> void:
	vision = toggled_on


func _on_lidar_toggled(toggled_on: bool) -> void:
	lidar = toggled_on


func _on_min_thrust_changed(value: float) -> void:
	minThrust = value
	$Label5.text = str(value)


func _on_max_thrust_value_changed(value: float) -> void:
	maxThrust = value
	$Label7.text = str(value)


func _on_brake_strength_changed(value: float) -> void:
	brakeStrength = value
	$Label9.text = str(value)


func _on_lidar_stop_range_changed(value: float) -> void:
	lidarStopRange = value
	$Label11.text = str(value)


func _on_tilt_speed_changed(value: float) -> void:
	tiltSpeed = value
	$Label13.text = str(value)

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_next_pressed() -> void:
	Global.vision_enabled = vision
	Global.lidar_enabled = lidar
	Global.minThrust = minThrust
	Global.maxThrust = maxThrust
	Global.brakeStrength = brakeStrength
	Global.lidarStopRange = lidarStopRange
	Global.tiltSpeed = tiltSpeed
	
	Global.change_scene_to_path("res://ui/AdvancedPartsMenu.tscn")


func _on_reset_pressed() -> void:
	vision = false
	lidar = false
	minThrust = 0.0
	maxThrust = 60.0
	brakeStrength = 8.0
	lidarStopRange = 9.0
	tiltSpeed = 3.0
	
	$CheckBox.button_pressed = vision
	$CheckBox2.button_pressed = lidar
	$HSlider.value = minThrust
	$HSlider2.value = maxThrust
	$HSlider3.value = brakeStrength
	$HSlider4.value = lidarStopRange
	$HSlider5.value = tiltSpeed
	
	$Label5.text = str($HSlider.value)
	$Label7.text = str($HSlider2.value)
	$Label9.text = str($HSlider3.value)
	$Label11.text = str($HSlider4.value)
	$Label13.text = str($HSlider5.value)
