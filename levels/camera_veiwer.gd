extends Panel

@onready var drone = $"../../Drone"
@onready var camera_feed_panel: Control = $"." 
@onready var camera_feed_rect: TextureRect = $TextureRect

func _ready() -> void:
	if drone != null:
		camera_feed_rect.texture = drone.get_camera_feed()
		camera_feed_panel.visible = drone.is_camera_enabled()
	else:
		camera_feed_panel.visible = false

func _process(_delta: float) -> void:
	if drone != null:
		camera_feed_rect.texture = drone.get_camera_feed()
		camera_feed_panel.visible = drone.is_camera_enabled()
