extends Control

var tiltSpeed: float = 3.0
var minThrust: float = 0.0
var maxThrust: float = 60.0
var maxForwardTilt: float = 0.25
var maxSideTilt: float = 0.25
var cruiseTilt: float = 0.12
var yawSpeed: float = 3.0
var settleYawSpeed: float = 4.5
var settlePitchScale: float = 0.45
var settleAvoidScale: float = 0.2
var brakeStrength: float = 8.0

var hoverHeight: float = 1.0
var heightStrength: float = 15.0
var heightDamping: float = 8.0
var climbRate: float = 5.0
var climbTargetOffset: float = 4.0
var maxHoverHeight: float = 8.0
var descendRate: float = 4.0
var highReturnRate: float = 6.0
var targetHeightOffset: float = -0.5
var finalVerticalReachRadius: float = 0.35

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Showing default values in the beginning
	$VBoxContainer2/Label5.text = str($HSlider.value)
	$VBoxContainer2/Label6.text = str($HSlider2.value)
	$VBoxContainer2/Label7.text = str($HSlider3.value)
	$VBoxContainer2/Label8.text = str($HSlider4.value)
	$VBoxContainer2/Label9.text = str($HSlider5.value)
	$VBoxContainer2/Label10.text = str($HSlider6.value)
	$VBoxContainer2/Label11.text = str($HSlider7.value)
	$VBoxContainer2/Label12.text = str($HSlider8.value)
	$VBoxContainer2/Label13.text = str($HSlider9.value)
	$VBoxContainer2/Label14.text = str($HSlider10.value)
	$VBoxContainer2/Label15.text = str($HSlider11.value)
	
	$VBoxContainer4/Label5.text = str($HSlider12.value)
	$VBoxContainer4/Label6.text = str($HSlider13.value)
	$VBoxContainer4/Label7.text = str($HSlider14.value)
	$VBoxContainer4/Label8.text = str($HSlider15.value)
	$VBoxContainer4/Label9.text = str($HSlider16.value)
	$VBoxContainer4/Label10.text = str($HSlider17.value)
	$VBoxContainer4/Label11.text = str($HSlider18.value)
	$VBoxContainer4/Label12.text = str($HSlider19.value)
	$VBoxContainer4/Label13.text = str($HSlider20.value)
	$VBoxContainer4/Label14.text = str($HSlider21.value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Set new value to variable and show as output
func _on_tilt_speed_value_changed(value: float) -> void:
	tiltSpeed = value
	$VBoxContainer2/Label5.text = str(value)


func _on_min_thrust_value_changed(value: float) -> void:
	minThrust = value
	$VBoxContainer2/Label6.text = str(value)


func _on_max_thrust_value_changed(value: float) -> void:
	maxThrust = value
	$VBoxContainer2/Label7.text = str(value)


func _on_max_forward_tilt_value_changed(value: float) -> void:
	maxForwardTilt = value
	$VBoxContainer2/Label8.text = str(value)


func _on_max_side_tilt_value_changed(value: float) -> void:
	maxSideTilt = value
	$VBoxContainer2/Label9.text = str(value)


func _on_cruise_tilt_value_changed(value: float) -> void:
	cruiseTilt = value
	$VBoxContainer2/Label10.text = str(value)


func _on_yaw_speed_value_changed(value: float) -> void:
	yawSpeed = value
	$VBoxContainer2/Label11.text = str(value)


func _on_settle_yaw_speed_value_changed(value: float) -> void:
	settleYawSpeed = value
	$VBoxContainer2/Label12.text = str(value)


func _on_settle_pitch_scale_value_changed(value: float) -> void:
	settlePitchScale = value
	$VBoxContainer2/Label13.text = str(value)


func _on_settle_avoid_scale_value_changed(value: float) -> void:
	settleAvoidScale = value
	$VBoxContainer2/Label14.text = str(value)


func _on_brake_strength_value_changed(value: float) -> void:
	brakeStrength = value
	$VBoxContainer2/Label15.text = str(value)


func _on_hover_height_value_changed(value: float) -> void:
	hoverHeight = value
	$VBoxContainer4/Label5.text = str(value)


func _on_height_strength_value_changed(value: float) -> void:
	heightStrength = value
	$VBoxContainer4/Label6.text = str(value)


func _on_height_damping_value_changed(value: float) -> void:
	heightDamping = value
	$VBoxContainer4/Label7.text = str(value)


func _on_climb_rate_value_changed(value: float) -> void:
	climbRate = value
	$VBoxContainer4/Label8.text = str(value)


func _on_climb_target_offset_value_changed(value: float) -> void:
	climbTargetOffset = value
	$VBoxContainer4/Label9.text = str(value)


func _on_max_hover_height_value_changed(value: float) -> void:
	maxHoverHeight = value
	$VBoxContainer4/Label10.text = str(value)


func _on_descend_rate_value_changed(value: float) -> void:
	descendRate = value
	$VBoxContainer4/Label11.text = str(value)


func _on_high_return_rate_value_changed(value: float) -> void:
	highReturnRate = value
	$VBoxContainer4/Label12.text = str(value)


func _on_target_height_offset_value_changed(value: float) -> void:
	targetHeightOffset = value
	$VBoxContainer4/Label13.text = str(value)


func _on_final_vertical_reach_radius_value_changed(value: float) -> void:
	finalVerticalReachRadius = value
	$VBoxContainer4/Label14.text = str(value)

#Exit
func _on_exit_pressed() -> void:
	get_tree().quit()

#Reset to default values
func _on_reset_pressed() -> void:
	#Set variables to default values
	tiltSpeed = 3.0
	minThrust = 0.0
	maxThrust = 60.0
	maxForwardTilt = 0.25
	maxSideTilt = 0.25
	cruiseTilt = 0.12
	yawSpeed = 3.0
	settleYawSpeed = 4.5
	settlePitchScale = 0.45
	settleAvoidScale = 0.2
	brakeStrength = 8.0
	
	hoverHeight = 1.0
	heightStrength = 15.0
	heightDamping = 8.0
	climbRate = 5.0
	climbTargetOffset = 4.0
	maxHoverHeight = 8.0
	descendRate = 4.0
	highReturnRate = 6.0
	targetHeightOffset = -0.5
	finalVerticalReachRadius = 0.35

	#Set sliders to default values
	$HSlider.value = tiltSpeed
	$HSlider2.value = minThrust
	$HSlider3.value = maxThrust
	$HSlider4.value = maxForwardTilt
	$HSlider5.value = maxSideTilt
	$HSlider6.value = cruiseTilt
	$HSlider7.value = yawSpeed
	$HSlider8.value = settleYawSpeed
	$HSlider9.value = settlePitchScale
	$HSlider10.value = settleAvoidScale
	$HSlider11.value = brakeStrength
	
	$HSlider12.value = hoverHeight
	$HSlider13.value = heightStrength
	$HSlider14.value = heightDamping
	$HSlider15.value = climbRate
	$HSlider16.value = climbTargetOffset
	$HSlider17.value = maxHoverHeight
	$HSlider18.value = descendRate
	$HSlider19.value = highReturnRate
	$HSlider20.value = targetHeightOffset
	$HSlider21.value = finalVerticalReachRadius
	
	#Output default values
	$VBoxContainer2/Label5.text = str($HSlider.value)
	$VBoxContainer2/Label6.text = str($HSlider2.value)
	$VBoxContainer2/Label7.text = str($HSlider3.value)
	$VBoxContainer2/Label8.text = str($HSlider4.value)
	$VBoxContainer2/Label9.text = str($HSlider5.value)
	$VBoxContainer2/Label10.text = str($HSlider6.value)
	$VBoxContainer2/Label11.text = str($HSlider7.value)
	$VBoxContainer2/Label12.text = str($HSlider8.value)
	$VBoxContainer2/Label13.text = str($HSlider9.value)
	$VBoxContainer2/Label14.text = str($HSlider10.value)
	$VBoxContainer2/Label15.text = str($HSlider11.value)
	
	$VBoxContainer4/Label5.text = str($HSlider12.value)
	$VBoxContainer4/Label6.text = str($HSlider13.value)
	$VBoxContainer4/Label7.text = str($HSlider14.value)
	$VBoxContainer4/Label8.text = str($HSlider15.value)
	$VBoxContainer4/Label9.text = str($HSlider16.value)
	$VBoxContainer4/Label10.text = str($HSlider17.value)
	$VBoxContainer4/Label11.text = str($HSlider18.value)
	$VBoxContainer4/Label12.text = str($HSlider19.value)
	$VBoxContainer4/Label13.text = str($HSlider20.value)
	$VBoxContainer4/Label14.text = str($HSlider21.value)

#Move to next part of the three-part advanced menu
func _on_next_pressed() -> void:
	#Set local values to global variables
	Global.tiltSpeed = tiltSpeed
	Global.minThrust = minThrust
	Global.maxThrust = maxThrust
	Global.maxForwardTilt = maxForwardTilt
	Global.maxSideTilt = maxSideTilt
	Global.cruiseTilt = cruiseTilt
	Global.yawSpeed = yawSpeed
	Global.settleYawSpeed = settleYawSpeed
	Global.settlePitchScale = settlePitchScale
	Global.settleAvoidScale = settleAvoidScale
	Global.brakeStrength = brakeStrength
	
	Global.hoverHeight = hoverHeight
	Global.heightStrength = heightStrength
	Global.heightDamping = heightDamping
	Global.climbRate = climbRate
	Global.climbTargetOffset = climbTargetOffset
	Global.maxHoverHeight = maxHoverHeight
	Global.descendRate = descendRate
	Global.highReturnRate = highReturnRate
	Global.targetHeightOffset = targetHeightOffset
	Global.finalVerticalReachRadius = finalVerticalReachRadius
	
	Global.change_scene_to_path("res://ui/AdvancedPartsMenu2.tscn")

func _on_back_pressed() -> void:
	Global.mode = 0
	Global.change_scene_to_path("res://ui/PartsMenu.tscn")
	
