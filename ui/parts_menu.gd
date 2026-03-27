extends Control

var vision: bool = false
var lidar: bool = false
var speed: float = 0.5
var handling: float = 0.5
var caution: float = 0.5
var climbBias: float = 0.5
var precision: float = 0.5

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


func _on_speed_changed(value: float) -> void:
	speed = value
	$Label5.text = str(value)


func _on_handling_changed(value: float) -> void:
	handling = value
	$Label7.text = str(value)


func _on_caution_changed(value: float) -> void:
	caution = value
	$Label9.text = str(value)


func _on_climb_bias_changed(value: float) -> void:
	climbBias = value
	$Label11.text = str(value)


func _on_precision_changed(value: float) -> void:
	precision = value
	$Label13.text = str(value)

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_next_pressed() -> void:
	Global.vision_enabled = vision
	Global.lidar_enabled = lidar
	Global.speed = speed
	Global.handling = handling
	Global.caution = caution
	Global.climbBias = climbBias
	Global.precision = precision
	
	Global.change_scene_to_path("res://ui/AdvancedPartsMenu.tscn")


func _on_reset_pressed() -> void:
	vision = false
	lidar = false
	speed = 0.5
	handling = 0.5
	caution = 0.5
	climbBias = 0.5
	precision = 0.5
	
	$CheckBox.button_pressed = vision
	$CheckBox2.button_pressed = lidar
	$HSlider.value = speed
	$HSlider2.value = handling
	$HSlider3.value = caution
	$HSlider4.value = climbBias
	$HSlider5.value = precision
	
	$Label5.text = str($HSlider.value)
	$Label7.text = str($HSlider2.value)
	$Label9.text = str($HSlider3.value)
	$Label11.text = str($HSlider4.value)
	$Label13.text = str($HSlider5.value)
