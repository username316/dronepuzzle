extends Panel

@onready var drone = $"../../Drone"
@onready var camera_feed_panel: Control = self
@onready var camera_feed_rect: TextureRect = $TextureRect

func _ready() -> void:
	_update_viewer_state()

func _process(_delta: float) -> void:
	_update_viewer_state()

func _update_viewer_state() -> void:
	var show: bool = drone != null and drone.is_camera_enabled()

	visible = show
	camera_feed_panel.visible = show
	camera_feed_rect.visible = show

	if show:
		camera_feed_rect.texture = drone.get_camera_feed()
	else:
		camera_feed_rect.texture = null
