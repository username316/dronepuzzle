extends Control

@export var drone_path: NodePath
@export var camera_rect_path: NodePath

@export var hud_radius_scale: float = 0.22
@export var vision_radius_scale: float = 0.80
@export var avoid_radius_scale: float = 0.65
@export var edge_margin_scale: float = 0.03
@export var font_size_scale: float = 0.08
@export var line_width_scale: float = 0.012
@export var marker_size_scale: float = 0.018
@export var reticle_size_scale: float = 0.03
@export var confidence_bar_width_scale: float = 0.28
@export var confidence_bar_height_scale: float = 0.03

var drone: Node = null
var camera_rect: TextureRect = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	if drone_path != NodePath():
		drone = get_node(drone_path)

	if camera_rect_path != NodePath():
		camera_rect = get_node(camera_rect_path)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if drone == null or not drone.vision_enabled:
		return

	var draw_rect: Rect2 = _get_camera_draw_rect()
	var center: Vector2 = draw_rect.position + draw_rect.size * 0.5
	var min_dim: float = min(draw_rect.size.x, draw_rect.size.y)

	var hud_radius: float = min_dim * hud_radius_scale
	var vision_radius: float = hud_radius * vision_radius_scale
	var avoid_radius: float = hud_radius * avoid_radius_scale
	var edge_margin: float = max(6.0, min_dim * edge_margin_scale)
	var font_size: int = int(max(12.0, min_dim * font_size_scale))
	var line_width: float = max(1.5, min_dim * line_width_scale)
	var marker_size: float = max(3.0, min_dim * marker_size_scale)
	var reticle_size: float = max(6.0, min_dim * reticle_size_scale)

	var font := get_theme_default_font()

	# Center reticle
	draw_circle(center, marker_size * 0.7, Color.WHITE)
	draw_line(center + Vector2(-reticle_size, 0), center + Vector2(reticle_size, 0), Color(1, 1, 1, 0.7), 1.0)
	draw_line(center + Vector2(0, -reticle_size), center + Vector2(0, reticle_size), Color(1, 1, 1, 0.7), 1.0)

	# Path box
	var path_rect_px := Rect2()
	var has_path_rect := false
	if drone.has_vision_corridor_rect():
		path_rect_px = _viewport_rect_to_hud(drone.get_vision_corridor_rect_px())

		if path_rect_px.size.x > 2.0 and path_rect_px.size.y > 2.0:
			has_path_rect = true
			draw_rect(path_rect_px, Color.YELLOW, false, line_width)

			var path_label_pos := path_rect_px.position + Vector2(6.0, 18.0)
			if path_label_pos.y < draw_rect.position.y + 28.0:
				path_label_pos.y = path_rect_px.end.y + 18.0

			_draw_label(font, path_label_pos, "PATH", font_size, Color.YELLOW)

	# Goal marker
	if drone.is_target_visible():
		var cam: Camera3D = drone.get_vision_camera()
		if cam != null:
			var goal_vp: Vector2 = cam.unproject_position(drone.target_position)
			var goal_2d: Vector2 = _viewport_to_hud(goal_vp)
			goal_2d = _clamp_to_camera_rect(goal_2d, edge_margin)

			var allow_goal: bool = true
			if has_path_rect:
				allow_goal = path_rect_px.has_point(goal_2d) or goal_2d.distance_to(center) < min_dim * 0.22

			if allow_goal:
				var goal_box_size := marker_size * 2.4
				draw_rect(
					Rect2(goal_2d - Vector2(goal_box_size, goal_box_size) * 0.5, Vector2.ONE * goal_box_size),
					Color.GREEN,
					false,
					line_width
				)
				_draw_label(font, goal_2d + Vector2(marker_size * 2.0, -marker_size * 1.5), "GOAL", font_size, Color.GREEN)

	# Planned motion cue
	var plan_local: Vector3 = drone.planned_motion_local.normalized()
	var plan_pos: Vector2 = center + Vector2(plan_local.x, -plan_local.y) * hud_radius
	plan_pos = _clamp_to_camera_rect(plan_pos, edge_margin)

	draw_line(center, plan_pos, Color.CYAN, line_width)
	draw_circle(plan_pos, marker_size, Color.CYAN)
	_draw_label(font, plan_pos + Vector2(marker_size * 2.0, -marker_size * 1.5), "PLAN", font_size, Color.CYAN)

	# Vision cue
	var vision_local: Vector3 = drone.vision_corridor_local.normalized()
	var vision_pos: Vector2 = center + Vector2(vision_local.x, -vision_local.y) * vision_radius
	vision_pos = _clamp_to_camera_rect(vision_pos, edge_margin)

	draw_line(center, vision_pos, Color.YELLOW, max(1.0, line_width * 0.8))
	draw_circle(vision_pos, marker_size * 0.85, Color.YELLOW)
	_draw_label(font, vision_pos + Vector2(marker_size * 2.0, -marker_size * 1.5), "VISION", font_size, Color.YELLOW)

	# Avoid cue
	if drone.avoid_active:
		var avoid_pos: Vector2 = center + Vector2(drone.avoid_yaw_dir, 0.0) * avoid_radius
		avoid_pos = _clamp_to_camera_rect(avoid_pos, edge_margin)

		draw_line(center, avoid_pos, Color.RED, line_width * 1.2)
		draw_circle(avoid_pos, marker_size * 0.9, Color.RED)
		_draw_label(font, avoid_pos + Vector2(marker_size * 2.0, -marker_size * 1.5), "AVOID", font_size, Color.RED)

	# Vision confidence
	var text_pos := draw_rect.position + Vector2(edge_margin, edge_margin + font_size)
	_draw_label(font, text_pos, "VISION %.2f" % drone.vision_corridor_confidence, font_size, Color.YELLOW)

	var bar_w: float = draw_rect.size.x * confidence_bar_width_scale
	var bar_h: float = max(6.0, draw_rect.size.y * confidence_bar_height_scale)
	var bar_pos := Vector2(draw_rect.position.x + edge_margin, text_pos.y + 8.0)

	draw_rect(Rect2(bar_pos, Vector2(bar_w, bar_h)), Color(0, 0, 0, 0.4), true)
	draw_rect(
		Rect2(bar_pos, Vector2(bar_w * clamp(drone.vision_corridor_confidence, 0.0, 1.0), bar_h)),
		Color.YELLOW,
		true
	)

	if drone.avoid_active:
		_draw_label(font, Vector2(draw_rect.position.x + edge_margin, bar_pos.y + bar_h + font_size + 6.0), "AVOIDING", font_size, Color.RED)

func _get_camera_draw_rect() -> Rect2:
	if camera_rect == null:
		return Rect2(Vector2.ZERO, size)

	var global_rect := camera_rect.get_global_rect()
	var local_pos := global_position
	return Rect2(global_rect.position - local_pos, global_rect.size)

func _viewport_to_hud(p: Vector2) -> Vector2:
	var draw_rect := _get_camera_draw_rect()
	var vp_size: Vector2 = drone.get_vision_viewport_size()

	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return draw_rect.position

	return draw_rect.position + Vector2(
		(p.x / vp_size.x) * draw_rect.size.x,
		(p.y / vp_size.y) * draw_rect.size.y
	)

func _viewport_rect_to_hud(r: Rect2) -> Rect2:
	var p0 := _viewport_to_hud(r.position)
	var p1 := _viewport_to_hud(r.position + r.size)
	return Rect2(p0, p1 - p0)

func _clamp_to_camera_rect(p: Vector2, margin: float) -> Vector2:
	var r := _get_camera_draw_rect()
	return Vector2(
		clamp(p.x, r.position.x + margin, r.position.x + r.size.x - margin),
		clamp(p.y, r.position.y + margin, r.position.y + r.size.y - margin)
	)

func _draw_label(font: Font, pos: Vector2, text: String, font_size: int, color: Color) -> void:
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
