extends Control

var arriveRadius: float = 8.0
var settleRadius: float = 3.0
var stopRadius: float = 1.0
var verticalStopRadius: float = 0.7
var holdKP: float = 10.0
var holdKD: float = 6.0
var maxHoldForce: float = 40.0
var reachedLevelSpeed: float = 12.0
var reachedStopSpeed: float = 12.0

var avoidForce: float = 18.0
var backoffForce: float = 18.0
var forwardBrakeGain: float = 22.0
var brakeDist: float = 2.2
var noForwardDist: float = 1.8
var reverseDist: float = 0.75
var avoidBank: float = 0.6
var avoidYawSpeed: float = 2.2
var sideTriggerDist: float = 1.3
var sidePushForce: float = 16.0
var rearTriggerDist: float = 1.0
var rearPushForce: float = 12.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer3/Label5.text = str($HSlider.value)
	$VBoxContainer3/Label6.text = str($HSlider2.value)
	$VBoxContainer3/Label7.text = str($HSlider3.value)
	$VBoxContainer3/Label8.text = str($HSlider4.value)
	$VBoxContainer3/Label9.text = str($HSlider5.value)
	$VBoxContainer3/Label10.text = str($HSlider6.value)
	$VBoxContainer3/Label11.text = str($HSlider7.value)
	$VBoxContainer3/Label12.text = str($HSlider8.value)
	$VBoxContainer3/Label13.text = str($HSlider9.value)
	
	$VBoxContainer4/Label5.text = str($HSlider10.value)
	$VBoxContainer4/Label6.text = str($HSlider11.value)
	$VBoxContainer4/Label7.text = str($HSlider12.value)
	$VBoxContainer4/Label8.text = str($HSlider13.value)
	$VBoxContainer4/Label9.text = str($HSlider14.value)
	$VBoxContainer4/Label10.text = str($HSlider15.value)
	$VBoxContainer4/Label11.text = str($HSlider16.value)
	$VBoxContainer4/Label12.text = str($HSlider17.value)
	$VBoxContainer4/Label13.text = str($HSlider18.value)
	$VBoxContainer4/Label14.text = str($HSlider19.value)
	$VBoxContainer4/Label15.text = str($HSlider20.value)
	$VBoxContainer4/Label16.text = str($HSlider21.value)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_arrive_radius_value_changed(value: float) -> void:
	arriveRadius = value
	$VBoxContainer3/Label5.text = str(value)

func _on_settle_radius_value_changed(value: float) -> void:
	settleRadius = value
	$VBoxContainer3/Label6.text = str(value)


func _on_stop_radius_value_changed(value: float) -> void:
	stopRadius = value
	$VBoxContainer3/Label7.text = str(value)


func _on_vertical_stop_radius_value_changed(value: float) -> void:
	verticalStopRadius = value
	$VBoxContainer3/Label8.text = str(value)


func _on_hold_KP_value_changed(value: float) -> void:
	holdKP = value
	$VBoxContainer3/Label9.text = str(value)


func _on_hold_KD_value_changed(value: float) -> void:
	holdKD = value
	$VBoxContainer3/Label10.text = str(value)


func _on_max_hold_force_value_changed(value: float) -> void:
	maxHoldForce = value
	$VBoxContainer3/Label11.text = str(value)


func _on_reached_level_speed_value_changed(value: float) -> void:
	reachedLevelSpeed = value
	$VBoxContainer3/Label12.text = str(value)


func _on_reached_stop_speed_value_changed(value: float) -> void:
	reachedStopSpeed = value
	$VBoxContainer3/Label13.text = str(value)


func _on_avoid_force_value_changed(value: float) -> void:
	avoidForce = value
	$VBoxContainer4/Label5.text = str(value)


func _on_backoff_force_value_changed(value: float) -> void:
	backoffForce = value
	$VBoxContainer4/Label6.text = str(value)


func _on_forward_brake_gain_value_changed(value: float) -> void:
	forwardBrakeGain = value
	$VBoxContainer4/Label7.text = str(value)


func _on_brake_dist_value_changed(value: float) -> void:
	brakeDist = value
	$VBoxContainer4/Label8.text = str(value)


func _on_no_forward_dist_value_changed(value: float) -> void:
	noForwardDist = value
	$VBoxContainer4/Label9.text = str(value)


func _on_reverse_dist_value_changed(value: float) -> void:
	reverseDist = value
	$VBoxContainer4/Label10.text = str(value)


func _on_avoid_bank_value_changed(value: float) -> void:
	avoidBank = value
	$VBoxContainer4/Label11.text = str(value)


func _on_avoid_yaw_speed_value_changed(value: float) -> void:
	avoidYawSpeed = value
	$VBoxContainer4/Label12.text = str(value)


func _on_side_trigger_dist_value_changed(value: float) -> void:
	sideTriggerDist = value
	$VBoxContainer4/Label13.text = str(value)


func _on_side_push_force_value_changed(value: float) -> void:
	sidePushForce = value
	$VBoxContainer4/Label14.text = str(value)


func _on_rear_trigger_dist_value_changed(value: float) -> void:
	rearTriggerDist = value
	$VBoxContainer4/Label15.text = str(value)


func _on_rear_push_force_value_changed(value: float) -> void:
	rearPushForce = value
	$VBoxContainer4/Label16.text = str(value)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_reset_pressed() -> void:
	arriveRadius = 8.0
	settleRadius = 3.0
	stopRadius = 1.0
	verticalStopRadius = 0.7
	holdKP = 10.0
	holdKD = 6.0
	maxHoldForce = 40.0
	reachedLevelSpeed = 12.0
	reachedStopSpeed = 12.0

	avoidForce = 18.0
	backoffForce = 18.0
	forwardBrakeGain = 22.0
	brakeDist = 2.2
	noForwardDist = 1.8
	reverseDist = 0.75
	avoidBank = 0.6
	avoidYawSpeed = 2.2
	sideTriggerDist = 1.3
	sidePushForce = 16.0
	rearTriggerDist = 1.0
	rearPushForce = 12.0
	
	$HSlider.value = arriveRadius
	$HSlider2.value = settleRadius
	$HSlider3.value = stopRadius
	$HSlider4.value = verticalStopRadius
	$HSlider5.value = holdKP
	$HSlider6.value = holdKD
	$HSlider7.value = maxHoldForce
	$HSlider8.value = reachedLevelSpeed
	$HSlider9.value = reachedStopSpeed

	$HSlider10.value = avoidForce
	$HSlider11.value = backoffForce
	$HSlider12.value = forwardBrakeGain
	$HSlider13.value = brakeDist
	$HSlider14.value = noForwardDist
	$HSlider15.value = reverseDist
	$HSlider16.value = avoidBank
	$HSlider17.value = avoidYawSpeed
	$HSlider18.value = sideTriggerDist
	$HSlider19.value = sidePushForce
	$HSlider20.value = rearTriggerDist
	$HSlider21.value = rearPushForce
	
	$VBoxContainer3/Label5.text = str($HSlider.value)
	$VBoxContainer3/Label6.text = str($HSlider2.value)
	$VBoxContainer3/Label7.text = str($HSlider3.value)
	$VBoxContainer3/Label8.text = str($HSlider4.value)
	$VBoxContainer3/Label9.text = str($HSlider5.value)
	$VBoxContainer3/Label10.text = str($HSlider6.value)
	$VBoxContainer3/Label11.text = str($HSlider7.value)
	$VBoxContainer3/Label12.text = str($HSlider8.value)
	$VBoxContainer3/Label13.text = str($HSlider9.value)
	
	$VBoxContainer4/Label5.text = str($HSlider10.value)
	$VBoxContainer4/Label6.text = str($HSlider11.value)
	$VBoxContainer4/Label7.text = str($HSlider12.value)
	$VBoxContainer4/Label8.text = str($HSlider13.value)
	$VBoxContainer4/Label9.text = str($HSlider14.value)
	$VBoxContainer4/Label10.text = str($HSlider15.value)
	$VBoxContainer4/Label11.text = str($HSlider16.value)
	$VBoxContainer4/Label12.text = str($HSlider17.value)
	$VBoxContainer4/Label13.text = str($HSlider18.value)
	$VBoxContainer4/Label14.text = str($HSlider19.value)
	$VBoxContainer4/Label15.text = str($HSlider20.value)
	$VBoxContainer4/Label16.text = str($HSlider21.value)


func _on_next_pressed() -> void:
	Global.arriveRadius = arriveRadius
	Global.settleRadius = settleRadius
	Global.stopRadius = stopRadius
	Global.verticalStopRadius = verticalStopRadius
	Global.holdKP = holdKP
	Global.holdKD = holdKD
	Global.maxHoldForce = maxHoldForce
	Global.reachedLevelSpeed = reachedLevelSpeed
	Global.reachedStopSpeed = reachedStopSpeed

	Global.avoidForce = avoidForce
	Global.backoffForce = backoffForce
	Global.forwardBrakeGain = forwardBrakeGain
	Global.brakeDist = brakeDist
	Global.noForwardDist = noForwardDist
	Global.reverseDist = reverseDist
	Global.avoidBank = avoidBank
	Global.avoidYawSpeed = avoidYawSpeed
	Global.sideTriggerDist = sideTriggerDist
	Global.sidePushForce = sidePushForce
	Global.rearTriggerDist = rearTriggerDist
	Global.rearPushForce = rearPushForce

	Global.change_scene_to_path("res://ui/AdvancedPartsMenu3.tscn")
