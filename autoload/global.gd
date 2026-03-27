extends Node

var start_menu_path = "res://ui/StartMenu.tscn"
var levels_folder_path = "res://levels/"

var current_scene = start_menu_path

var level_paths: Array[String]

func _ready() -> void:
	current_scene =  get_tree().root.get_child(-1)
	load_levels_from_dir(levels_folder_path)
	#print(level_paths)

func change_scene_to_path(path: String):
	current_scene.queue_free()
	current_scene = ResourceLoader.load(path).instantiate()
	get_tree().root.add_child(current_scene)
	
	SoundManager.connect_sounds()

func load_levels_from_dir(path: String):
	var dir = DirAccess.open(path)
	if dir:
		for f: String in dir.get_files():
			if f.begins_with("Level") and f.ends_with(".tscn"):
				level_paths.append(f)


var selected_level: int = 0

var vision_enabled: bool = true
var lidar_enabled: bool = true

var speed: float = 0.5
var handling: float = 0.5
var caution: float = 0.5
var climbBias: float = 0.5
var precision: float = 0.5

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
