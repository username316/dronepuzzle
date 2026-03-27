extends Control

var plannerProgressWeight: float = 2.8
var plannerClearanceWeight: float = 2.6
var plannerClimbWeight: float = 0.05
var plannerDirectionSmooth: float = 0.28
var plannerUpwardGain: float = 0.65
var plannerForwardGain: float = 1.6
var plannerBlockedPenaltyGain: float = 2.6
var plannerCenteringWeight: float = 2.2
var plannerMinMarginWeight: float = 2.8
var plannerVerticalBalanceWeight: float = 1.6
var plannerLateralBalanceWeight: float = 1.4
var plannerVerticalSafeDistance: float = 1.6
var plannerBodyMargin: float = 0.9
var plannerLookaheadTime: float = 0.55

var lidarTriggerDist: float = 9.0
var lidarClearDist: float = 11.0
var lidarMinAvoidTime: float = 0.45
var lidarDirDeadband: float = 0.35
var lidarSmooth: float = 0.2
var lidarTriggerHoldTime: float = 0.12

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
	$VBoxContainer2/Label16.text = str($HSlider12.value)
	$VBoxContainer2/Label17.text = str($HSlider13.value)
	$VBoxContainer2/Label18.text = str($HSlider14.value)
	
	#Show Lidar settings only if it's selected
	if Global.lidar_enabled:
		$VBoxContainer4/Label5.text = str($HSlider15.value)
		$VBoxContainer4/Label6.text = str($HSlider16.value)
		$VBoxContainer4/Label7.text = str($HSlider17.value)
		$VBoxContainer4/Label8.text = str($HSlider18.value)
		$VBoxContainer4/Label9.text = str($HSlider19.value)
		$VBoxContainer4/Label10.text = str($HSlider20.value)
	else:
		$VBoxContainer3.hide()
		$Label3.hide()
		$HSlider15.hide()
		$HSlider16.hide()
		$HSlider17.hide()
		$HSlider18.hide()
		$HSlider19.hide()
		$HSlider20.hide()
		$VBoxContainer4.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_planner_progress_weight_value_changed(value: float) -> void:
	plannerProgressWeight = value
	$VBoxContainer2/Label5.text = str(value)


func _on_planner_clearance_weight_value_changed(value: float) -> void:
	plannerClearanceWeight = value
	$VBoxContainer2/Label6.text = str(value)


func _on_planner_climb_weight_value_changed(value: float) -> void:
	plannerClimbWeight = value
	$VBoxContainer2/Label7.text = str(value)


func _on_planner_direction_smooth_value_changed(value: float) -> void:
	plannerDirectionSmooth = value
	$VBoxContainer2/Label8.text = str(value)


func _on_planner_upward_gain_value_changed(value: float) -> void:
	plannerUpwardGain = value
	$VBoxContainer2/Label9.text = str(value)


func _on_planner_forward_gain_value_changed(value: float) -> void:
	plannerForwardGain = value
	$VBoxContainer2/Label10.text = str(value)


func _on_planner_blocked_penalty_gain_value_changed(value: float) -> void:
	plannerBlockedPenaltyGain = value
	$VBoxContainer2/Label11.text = str(value)


func _on_planner_centering_weight_value_changed(value: float) -> void:
	plannerCenteringWeight = value
	$VBoxContainer2/Label12.text = str(value)


func _on_planner_min_margin_weight_value_changed(value: float) -> void:
	plannerMinMarginWeight = value
	$VBoxContainer2/Label13.text = str(value)


func _on_planner_vertical_balance_weight_value_changed(value: float) -> void:
	plannerVerticalBalanceWeight = value
	$VBoxContainer2/Label14.text = str(value)


func _on_planner_lateral_balance_weight_value_changed(value: float) -> void:
	plannerLateralBalanceWeight = value
	$VBoxContainer2/Label15.text = str(value)


func _on_planner_vertical_safe_distance_value_changed(value: float) -> void:
	plannerVerticalSafeDistance = value
	$VBoxContainer2/Label16.text = str(value)


func _on_planner_body_margin_value_changed(value: float) -> void:
	plannerBodyMargin = value
	$VBoxContainer2/Label17.text = str(value)


func _on_planner_lookahead_time_value_changed(value: float) -> void:
	plannerLookaheadTime = value
	$VBoxContainer2/Label18.text = str(value)


func _on_lidar_trigger_dist_value_changed(value: float) -> void:
	lidarTriggerDist = value
	$VBoxContainer4/Label5.text = str(value)


func _on_lidar_clear_dist_value_changed(value: float) -> void:
	lidarClearDist = value
	$VBoxContainer4/Label6.text = str(value)


func _on_lidar_min_avoid_time_value_changed(value: float) -> void:
	lidarMinAvoidTime = value
	$VBoxContainer4/Label7.text = str(value)


func _on_lidar_dir_deadband_value_changed(value: float) -> void:
	lidarDirDeadband = value
	$VBoxContainer4/Label8.text = str(value)


func _on_lidar_smooth_value_changed(value: float) -> void:
	lidarSmooth = value
	$VBoxContainer4/Label9.text = str(value)


func _on_lidar_trigger_hold_time_value_changed(value: float) -> void:
	lidarTriggerHoldTime = value
	$VBoxContainer4/Label10.text = str(value)


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_reset_pressed() -> void:
	plannerProgressWeight = 2.8
	plannerClearanceWeight = 2.6
	plannerClimbWeight = 0.05
	plannerDirectionSmooth = 0.28
	plannerUpwardGain = 0.65
	plannerForwardGain = 1.6
	plannerBlockedPenaltyGain = 2.6
	plannerCenteringWeight = 2.2
	plannerMinMarginWeight = 2.8
	plannerVerticalBalanceWeight = 1.6
	plannerLateralBalanceWeight = 1.4
	plannerVerticalSafeDistance = 1.6
	plannerBodyMargin = 0.9
	plannerLookaheadTime = 0.55

	lidarTriggerDist = 9.0
	lidarClearDist = 11.0
	lidarMinAvoidTime = 0.45
	lidarDirDeadband = 0.35
	lidarSmooth = 0.2
	lidarTriggerHoldTime = 0.12
	
	$HSlider.value = plannerProgressWeight
	$HSlider2.value = plannerClearanceWeight
	$HSlider3.value = plannerClimbWeight
	$HSlider4.value = plannerDirectionSmooth
	$HSlider5.value = plannerUpwardGain
	$HSlider6.value = plannerForwardGain
	$HSlider7.value = plannerBlockedPenaltyGain
	$HSlider8.value = plannerCenteringWeight
	$HSlider9.value = plannerMinMarginWeight
	$HSlider10.value = plannerVerticalBalanceWeight
	$HSlider11.value = plannerLateralBalanceWeight
	$HSlider12.value = plannerVerticalSafeDistance
	$HSlider13.value = plannerBodyMargin
	$HSlider14.value = plannerLookaheadTime

	$HSlider15.value = lidarTriggerDist
	$HSlider16.value = lidarClearDist
	$HSlider17.value = lidarMinAvoidTime
	$HSlider18.value = lidarDirDeadband
	$HSlider19.value = lidarSmooth
	$HSlider20.value = lidarTriggerHoldTime
	
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
	$VBoxContainer2/Label16.text = str($HSlider12.value)
	$VBoxContainer2/Label17.text = str($HSlider13.value)
	$VBoxContainer2/Label18.text = str($HSlider14.value)
	
	$VBoxContainer4/Label5.text = str($HSlider15.value)
	$VBoxContainer4/Label6.text = str($HSlider16.value)
	$VBoxContainer4/Label7.text = str($HSlider17.value)
	$VBoxContainer4/Label8.text = str($HSlider18.value)
	$VBoxContainer4/Label9.text = str($HSlider19.value)
	$VBoxContainer4/Label10.text = str($HSlider20.value)


func _on_next_pressed() -> void:
	Global.plannerProgressWeight = plannerProgressWeight
	Global.plannerClearanceWeight = plannerClearanceWeight
	Global.plannerClimbWeight = plannerClimbWeight
	Global.plannerDirectionSmooth = plannerDirectionSmooth
	Global.plannerUpwardGain = plannerUpwardGain
	Global.plannerForwardGain = plannerForwardGain
	Global.plannerBlockedPenaltyGain = plannerBlockedPenaltyGain
	Global.plannerCenteringWeight = plannerCenteringWeight
	Global.plannerMinMarginWeight = plannerMinMarginWeight
	Global.plannerVerticalBalanceWeight = plannerVerticalBalanceWeight
	Global.plannerLateralBalanceWeight = plannerLateralBalanceWeight
	Global.plannerVerticalSafeDistance = plannerVerticalSafeDistance
	Global.plannerBodyMargin = plannerBodyMargin
	Global.plannerLookaheadTime = plannerLookaheadTime

	Global.lidarTriggerDist = lidarTriggerDist
	Global.lidarClearDist = lidarClearDist
	Global.lidarMinAvoidTime = lidarMinAvoidTime
	Global.lidarDirDeadband = lidarDirDeadband
	Global.lidarSmooth = lidarSmooth
	Global.lidarTriggerHoldTime = lidarTriggerHoldTime
	
	#Proceed to selected level
	if Global.selected_level == 1:
		Global.change_scene_to_path("res://levels/Level1.tscn")

	elif Global.selected_level == 2:
		Global.change_scene_to_path("res://levels/Level2.tscn")

	elif Global.selected_level == 3:
		Global.change_scene_to_path("res://levels/Level3.tscn")
