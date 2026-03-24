extends RigidBody3D

# -----------------------
# Flight / movement tuning
# -----------------------
@export var tilt_speed: float = 3.0
@export var min_thrust: float = 0.0
@export var max_thrust: float = 60.0

@export var hover_height: float = 3.0
@export var height_strength: float = 15.0
@export var height_damping: float = 8.0

@export var target: Area3D
@export var arrive_radius: float = 8.0
@export var settle_radius: float = 5.0
@export var stop_radius: float = 2.8
@export var vertical_stop_radius: float = 1.5

@export var max_forward_tilt: float = 0.25
@export var max_side_tilt: float = 0.25
@export var cruise_tilt: float = 0.12
@export var yaw_speed: float = 3.0
@export var settle_yaw_speed: float = 4.5
@export var settle_pitch_scale: float = 0.45
@export var settle_avoid_scale: float = 0.2

# Braking near goal
@export var brake_strength: float = 8.0

# Position hold (inside stop bubble)
@export var hold_kp: float = 10.0
@export var hold_kd: float = 6.0
@export var max_hold_force: float = 40.0
@export var reached_level_speed: float = 12.0
@export var reached_stop_speed: float = 12.0

# -----------------------
# Sensors toggles + fusion
# -----------------------
@export var vision_enabled: bool = true
@export var lidar_enabled: bool = true
@export var fusion_mode: String = "min" # "min" | "vision" | "lidar"

# -----------------------
# Vision (camera-only) params
# -----------------------
@export var vision_interval: float = 0.03
@export var avoid_yaw_speed: float = 2.2

@export var avoid_trigger_flow: float = 0.10
@export var avoid_clear_flow: float = 0.05
@export var avoid_trigger_edge: float = 0.15
@export var avoid_clear_edge: float = 0.08
@export var edge_step: int = 2
@export var flow_step: int = 3

# -----------------------
# LiDAR params
# -----------------------
@export var lidar_trigger_dist: float = 9.0
@export var lidar_clear_dist: float = 11.0
@export var lidar_min_avoid_time: float = 0.45
@export var lidar_dir_deadband: float = 0.35
@export var lidar_smooth: float = 0.20
@export var lidar_trigger_hold_time: float = 0.12
@export var planner_fov_deg: float = 160.0
@export var planner_step_deg: float = 5.0
@export var planner_goal_weight: float = 2.0
@export var planner_turn_weight: float = 0.4
@export var planner_obstacle_weight: float = 3.0
@export var planner_safe_distance: float = 4.0

# -----------------------
# Avoidance behavior tuning
# -----------------------
@export var avoid_creep: float = 0.55
@export var avoid_stop_strength: float = 2.0
@export var avoid_bank: float = 0.6
@export var avoid_force: float = 18.0
@export var backoff_force: float = 18.0
@export var no_forward_dist: float = 1.8
@export var brake_dist: float = 2.2
@export var reverse_dist: float = 0.75
@export var forward_brake_gain: float = 22.0

# Vertical motion shaping
@export var climb_trigger_dist: float = 3.0
@export var climb_clear_dist: float = 5.0
@export var climb_rate: float = 5.0
@export var climb_target_offset: float = 3.0
@export var max_hover_height: float = 8.0
@export var return_rate: float = 1.2

# -----------------------
# 3D motion planner tuning
# -----------------------
@export var planner_climb_weight: float = 0.05
@export var planner_progress_weight: float = 2.8
@export var planner_clearance_weight: float = 2.6
@export var planner_vertical_safe_distance: float = 1.6
@export var planner_direction_smooth: float = 0.28
@export var planner_upward_gain: float = 0.65
@export var planner_forward_gain: float = 1.6
@export var planner_blocked_penalty_gain: float = 2.6
@export var planner_centering_weight: float = 2.2
@export var planner_min_margin_weight: float = 2.8
@export var planner_vertical_balance_weight: float = 1.6
@export var planner_lateral_balance_weight: float = 1.4
@export var planner_body_margin: float = 0.9
@export var planner_lookahead_time: float = 0.55
@export var vision_corridor_weight: float = 0.22
@export var vision_corridor_near_goal_scale: float = 0.45
@export var vision_conf_decay: float = 0.8
@export var planner_vertical_center_bias: float = 0.35
@export var planner_vertical_margin_bias: float = 0.8

# Corridor memory
@export var corridor_lock_time: float = 0.65
@export var corridor_lock_retain_dist: float = 2.5
@export var corridor_lock_min_up: float = 0.18
@export var corridor_lock_goal_align: float = 0.55
@export var corridor_emergency_clearance: float = 1.0

@onready var vision_pivot: Node3D = $VisionPivot
@onready var vision_viewport: SubViewport = $VisionViewport
@onready var vision_camera: Camera3D = $VisionViewport/VisionCamera
@onready var lidar: LidarSensor3D = $Lidar
@onready var lidar_up: LidarSensor3D = $LidarUp
@onready var lidar_down: LidarSensor3D = $LidarDown


# Target
var target_position: Vector3 = Vector3.ZERO

# Hover
var desired_hover_height: float = 3.0

# Timers
var vision_timer: float = 0.0
var prev_img: Image = null

# Controller outputs
var target_pitch: float = 0.0
var target_roll: float = 0.0
var target_thrust: float = 0.0

# Final fused avoidance output
var avoid_active: bool = false
var avoid_yaw_dir: float = 0.0
var avoid_strength: float = 0.0

# Vision output
var vision_avoid_latch: bool = false
var avoid_active_vision: bool = false
var avoid_dir_vision: float = 0.0
var avoid_strength_vision: float = 0.0

# Vision corridor output
var vision_corridor_local: Vector3 = Vector3(0.0, 0.0, -1.0)
var vision_corridor_confidence: float = 0.0

# LiDAR output
var avoid_active_lidar: bool = false
var avoid_dir_lidar: float = 0.0
var avoid_strength_lidar: float = 0.0
var lidar_center_latest: float = 20.0
var lidar_trigger_timer: float = 0.0

# LiDAR smoothing + timer
var lidar_left_f: float = 0.0
var lidar_center_f: float = 0.0
var lidar_right_f: float = 0.0
var lidar_avoid_timer: float = 0.0

# 3D motion planner output
var planned_motion_local: Vector3 = Vector3(0.0, 0.0, -1.0)
var planned_motion_world: Vector3 = Vector3(0.0, 0.0, -1.0)

# Corridor lock
var corridor_lock_timer: float = 0.0
var corridor_locked: bool = false
var corridor_locked_motion_local: Vector3 = Vector3(0.0, 0.0, -1.0)

func _ready() -> void:
	vision_enabled = Global.vision_enabled
	lidar_enabled = Global.lidar_enabled
	min_thrust = Global.minThrust
	max_thrust = Global.maxThrust
	brake_strength = Global.brakeStrength
	lidar_trigger_dist = Global.lidarStopRange
	tilt_speed = Global.tiltSpeed

	if target != null:
		target_position = target.global_position
	else:
		target_position = global_position

	

	desired_hover_height = hover_height
	planned_motion_world = -transform.basis.z


func _physics_process(delta: float) -> void:
	vision_camera.global_transform = vision_pivot.global_transform
	
	if target != null:
		target_position = target.global_position

	if lidar != null:
		lidar.global_rotation.y = global_rotation.y
	if lidar_up != null:
		lidar_up.global_rotation.y = global_rotation.y
	if lidar_down != null:
		lidar_down.global_rotation.y = global_rotation.y

	_update_vision(delta)

	# Let old visual corridor opinions fade unless they keep being re-observed.
	vision_corridor_confidence = move_toward(vision_corridor_confidence, 0.0, delta * vision_conf_decay)

	_update_lidar(delta)
	plan_visible_motion()

	var to_target_full: Vector3 = target_position - global_position
	var to_target_flat: Vector3 = to_target_full
	to_target_flat.y = 0.0

	var dist: float = to_target_flat.length()
	var vertical_dist: float = abs(to_target_full.y)
	var reached: bool = dist <= stop_radius and vertical_dist <= vertical_stop_radius
	var settling: bool = dist <= settle_radius

	if not settling:
		update_corridor_lock(delta, planned_motion_local)
	else:
		corridor_locked = false
		corridor_lock_timer = 0.0

	if corridor_locked:
		planned_motion_local = corridor_locked_motion_local
		planned_motion_world = (transform.basis * planned_motion_local).normalized()

	vertical_avoidance_update(delta)

	var height_error: float = desired_hover_height - global_position.y
	var vertical_velocity: float = linear_velocity.y
	var height_correction: float = height_error * height_strength - vertical_velocity * height_damping
	target_thrust = clamp(9.8 * mass + height_correction, min_thrust, max_thrust)

	if reached:
		_do_reached_hold(delta)
	else:
		var use_vision_active: bool = avoid_active_vision
		var use_vision_dir: float = avoid_dir_vision
		var use_vision_strength: float = avoid_strength_vision

		if settling:
			use_vision_active = false
			use_vision_dir = 0.0
			use_vision_strength = 0.0
			vision_avoid_latch = false

		fuse_avoidance(
			use_vision_active, use_vision_dir, use_vision_strength,
			avoid_active_lidar, avoid_dir_lidar, avoid_strength_lidar
		)

		steer_toward_goal(dist, delta, settling)

		if avoid_active and not settling:
			apply_avoidance_physics()

		apply_braking(dist)

		rotation.x = lerpf(rotation.x, target_pitch, delta * tilt_speed)
		rotation.z = lerpf(rotation.z, target_roll, delta * tilt_speed)

	var lift: Vector3 = transform.basis.y * target_thrust
	apply_central_force(lift)
	
	

func apply_avoidance_physics() -> void:
	var right: Vector3 = transform.basis.x
	var forward: Vector3 = -transform.basis.z

	var s: float = clamp(avoid_strength, 0.0, 1.0)
	var c: float = lidar_center_latest

	var lateral_scale: float = s
	if c > brake_dist:
		lateral_scale *= 0.55

	var lateral: Vector3 = (right * avoid_yaw_dir) * (avoid_force * lateral_scale) * mass
	lateral.y = 0.0

	var v: Vector3 = linear_velocity
	v.y = 0.0
	var fwd_speed: float = v.dot(forward)

	var brake: Vector3 = Vector3.ZERO
	if lidar_enabled and c < brake_dist and fwd_speed > 0.0:
		var closeness: float = clamp((brake_dist - c) / max(brake_dist, 0.001), 0.0, 1.0)
		closeness = pow(closeness, 1.8)
		brake = -forward * fwd_speed * (forward_brake_gain * closeness) * mass

	var reverse: Vector3 = Vector3.ZERO
	if lidar_enabled and c < reverse_dist:
		var closeness2: float = clamp((reverse_dist - c) / max(reverse_dist, 0.001), 0.0, 1.0)
		closeness2 = pow(closeness2, 1.5)
		reverse = -forward * (backoff_force * 0.45 * closeness2) * mass

	brake.y = 0.0
	reverse.y = 0.0

	apply_central_force(lateral + brake + reverse)

func _do_reached_hold(delta: float) -> void:
	target_pitch = 0.0
	target_roll = 0.0

	rotation.x = lerpf(rotation.x, 0.0, delta * reached_level_speed)
	rotation.z = lerpf(rotation.z, 0.0, delta * reached_level_speed)

	linear_velocity.x = move_toward(linear_velocity.x, 0.0, reached_stop_speed * delta)
	linear_velocity.z = move_toward(linear_velocity.z, 0.0, reached_stop_speed * delta)
	angular_velocity = angular_velocity.lerp(Vector3.ZERO, delta * 8.0)

	var err: Vector3 = target_position - global_position
	err.y = 0.0
	var vel: Vector3 = linear_velocity
	vel.y = 0.0

	var hold_force: Vector3 = err * hold_kp - vel * hold_kd
	if hold_force.length() > max_hold_force:
		hold_force = hold_force.normalized() * max_hold_force

	apply_central_force(hold_force * mass)

func _update_vision(delta: float) -> void:
	if not vision_enabled:
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0
		vision_corridor_local = Vector3(0.0, 0.0, -1.0)
		vision_corridor_confidence = 0.0
		return

	vision_timer += delta
	if vision_timer >= vision_interval:
		vision_timer = 0.0
		process_vision()

func _update_lidar(_delta: float) -> void:
	if not lidar_enabled or lidar == null:
		avoid_active_lidar = false
		avoid_dir_lidar = 0.0
		avoid_strength_lidar = 0.0
		lidar_avoid_timer = 0.0
		return

	lidar_avoidance_update()

func process_vision() -> void:
	var img: Image = vision_viewport.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)

	if prev_img == null:
		prev_img = img.duplicate()
		vision_avoid_latch = false
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0
		vision_corridor_local = Vector3(0.0, 0.0, -1.0)
		vision_corridor_confidence = 0.0
		return

	var w: int = img.get_width()
	var h: int = img.get_height()

	var left_flow: float = flow_band(img, prev_img, int(w * 0.10), int(w * 0.35), int(h * 0.35), int(h * 0.65), flow_step)
	var center_flow: float = flow_band(img, prev_img, int(w * 0.40), int(w * 0.60), int(h * 0.35), int(h * 0.65), flow_step)
	var right_flow: float = flow_band(img, prev_img, int(w * 0.65), int(w * 0.90), int(h * 0.35), int(h * 0.65), flow_step)

	var edge_c: float = edge_density(img, int(w * 0.40), int(w * 0.60), int(h * 0.35), int(h * 0.65), edge_step)

	update_vision_corridor(img)

	prev_img = img.duplicate()

	var trigger: bool = (center_flow > avoid_trigger_flow) or (edge_c > avoid_trigger_edge)
	var clear: bool = (center_flow < avoid_clear_flow) and (edge_c < avoid_clear_edge)

	if vision_avoid_latch:
		if clear:
			vision_avoid_latch = false
	else:
		if trigger:
			vision_avoid_latch = true

	if vision_avoid_latch:
		var dir: float = -1.0 if left_flow < right_flow else 1.0

		var s_flow: float = clamp((center_flow - avoid_trigger_flow) / max(avoid_trigger_flow, 0.001), 0.0, 1.0)
		var s_edge: float = clamp((edge_c - avoid_trigger_edge) / max(avoid_trigger_edge, 0.001), 0.0, 1.0)
		var s: float = clamp(max(s_flow, s_edge), 0.0, 1.0)

		avoid_active_vision = true
		avoid_dir_vision = dir
		avoid_strength_vision = s
	else:
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0

func update_vision_corridor(img: Image) -> void:
	var w: int = img.get_width()
	var h: int = img.get_height()

	var cols: int = 7
	var rows: int = 5

	var total_weight: float = 0.0
	var sum_x: float = 0.0
	var sum_y: float = 0.0
	var best_weight: float = 0.0

	for row in range(rows):
		for col in range(cols):
			var x0: int = int(float(col) / float(cols) * float(w))
			var x1: int = int(float(col + 1) / float(cols) * float(w))
			var y0: int = int(float(row) / float(rows) * float(h))
			var y1: int = int(float(row + 1) / float(rows) * float(h))

			var edges: float = edge_density(img, x0, x1, y0, y1, edge_step)

			var flow: float = 0.0
			if prev_img != null:
				flow = flow_band(img, prev_img, x0, x1, y0, y1, flow_step)

			# openness estimate
			var openness: float = 1.0 / (0.001 + edges * 2.2 + flow * 1.6)

			# prefer center-ish columns
			var col_center_dist: float = abs(float(col) - float(cols - 1) * 0.5) / max(float(cols - 1) * 0.5, 0.001)
			var center_bonus: float = 1.0 - col_center_dist

			# prefer upper-middle a bit, but not too strongly
			var row_norm: float = float(row) / max(float(rows - 1), 1.0)
			var vertical_pref: float = 1.0 - abs(row_norm - 0.28) / 0.72
			vertical_pref = clamp(vertical_pref, 0.0, 1.0)

			var weight: float = openness * 2.4 + center_bonus * 0.35 + vertical_pref * 0.35

			if weight > 0.0:
				var cx: float = (float(col) + 0.5) / float(cols)
				var cy: float = (float(row) + 0.5) / float(rows)

				sum_x += cx * weight
				sum_y += cy * weight
				total_weight += weight
				best_weight = max(best_weight, weight)

	if total_weight <= 0.0001:
		vision_corridor_local = vision_corridor_local.lerp(Vector3(0.0, 0.0, -1.0), 0.10).normalized()
		vision_corridor_confidence = lerpf(vision_corridor_confidence, 0.0, 0.10)
		return

	var mean_x: float = sum_x / total_weight
	var mean_y: float = sum_y / total_weight

	var x_norm: float = mean_x * 2.0 - 1.0
	var y_norm: float = 1.0 - mean_y * 2.0

	# softer lateral command, moderate upward bias
	var lateral: float = x_norm * 0.28
	var climb: float = max(y_norm, 0.0) * 0.36

	var candidate: Vector3 = Vector3(lateral, climb, -1.0).normalized()

	# confidence from overall support, not just one cell
	var confidence: float = clamp((total_weight / float(cols * rows)) / max(best_weight, 0.001) * 1.8, 0.0, 0.75)

	vision_corridor_local = vision_corridor_local.lerp(candidate, 0.18).normalized()
	vision_corridor_confidence = lerpf(vision_corridor_confidence, confidence, 0.18)

func flow_band(img: Image, prev: Image, x0: int, x1: int, y0: int, y1: int, step: int) -> float:
	var sum: float = 0.0
	var count: int = 0

	for y in range(y0, y1, step):
		for x in range(x0, x1, step):
			var a: Color = img.get_pixel(x, y)
			var b: Color = prev.get_pixel(x, y)

			var la: float = a.r * 0.299 + a.g * 0.587 + a.b * 0.114
			var lb: float = b.r * 0.299 + b.g * 0.587 + b.b * 0.114
			sum += abs(la - lb)
			count += 1

	return sum / float(max(1, count))

func edge_density(img: Image, x0: int, x1: int, y0: int, y1: int, step: int) -> float:
	var sum: float = 0.0
	var count: int = 0

	for y in range(y0, y1 - step, step):
		for x in range(x0, x1 - step, step):
			var c: Color = img.get_pixel(x, y)
			var cx: Color = img.get_pixel(x + step, y)
			var cy: Color = img.get_pixel(x, y + step)

			var l: float = c.r * 0.299 + c.g * 0.587 + c.b * 0.114
			var lx: float = cx.r * 0.299 + cx.g * 0.587 + cx.b * 0.114
			var ly: float = cy.r * 0.299 + cy.g * 0.587 + cy.b * 0.114

			sum += abs(l - lx) + abs(l - ly)
			count += 1

	return sum / float(max(1, count))

func lidar_avoidance_update() -> void:

	var left: float = lidar.get_sector_percentile(-60.0, -20.0, 0.25)
	var center: float = lidar.get_sector_percentile(-8.0, 8.0, 0.25)
	var right: float = lidar.get_sector_percentile(20.0, 60.0, 0.25)

	if is_zero_approx(lidar_left_f):
		lidar_left_f = left
		lidar_center_f = center
		lidar_right_f = right
	else:
		lidar_left_f = lerpf(lidar_left_f, left, lidar_smooth)
		lidar_center_f = lerpf(lidar_center_f, center, lidar_smooth)
		lidar_right_f = lerpf(lidar_right_f, right, lidar_smooth)

	left = lidar_left_f
	center = lidar_center_f
	right = lidar_right_f

	lidar_center_latest = center

	if center < lidar_trigger_dist:
		lidar_trigger_timer += get_physics_process_delta_time()
	else:
		lidar_trigger_timer = 0.0

	if not avoid_active_lidar and lidar_trigger_timer >= lidar_trigger_hold_time:
		avoid_active_lidar = true
		lidar_avoid_timer = lidar_min_avoid_time

	if lidar_avoid_timer > 0.0:
		lidar_avoid_timer -= get_physics_process_delta_time()

	if avoid_active_lidar and lidar_avoid_timer <= 0.0 and center > lidar_clear_dist:
		avoid_active_lidar = false
		lidar_trigger_timer = 0.0

	if avoid_active_lidar:
		avoid_strength_lidar = clamp((lidar_trigger_dist - center) / max(lidar_trigger_dist, 0.001), 0.0, 1.0)

		if not (left < 1.5 and right < 1.5):
			var diff: float = left - right
			if abs(diff) > lidar_dir_deadband:
				avoid_dir_lidar = -1.0 if diff > 0.0 else 1.0
	else:
		avoid_strength_lidar = 0.0
		avoid_dir_lidar = 0.0
		
func _candidate_future_origin(dir_local: Vector3) -> Vector3:
	var vel_flat: Vector3 = linear_velocity
	vel_flat.y = 0.0

	var speed: float = vel_flat.length()
	var lookahead_dist: float = max(speed * planner_lookahead_time, 1.25)

	var dir_world: Vector3 = (transform.basis * dir_local).normalized()
	var future_origin: Vector3 = global_position + dir_world * lookahead_dist
	return future_origin


func _sample_margin_score(angle: float, lidar_node: LidarSensor3D, shoulder_deg: float, percentile: float) -> Dictionary:
	var center: float = lidar_node.get_sector_percentile(angle - 4.0, angle + 4.0, percentile)
	var left_shoulder: float = lidar_node.get_sector_percentile(angle - shoulder_deg, angle - 5.0, percentile)
	var right_shoulder: float = lidar_node.get_sector_percentile(angle + 5.0, angle + shoulder_deg, percentile)

	var min_margin: float = min(center, min(left_shoulder, right_shoulder))
	var lateral_balance: float = 1.0 - clamp(abs(left_shoulder - right_shoulder) / 4.0, 0.0, 1.0)

	return {
		"center": center,
		"left": left_shoulder,
		"right": right_shoulder,
		"min_margin": min_margin,
		"lateral_balance": lateral_balance
	}

func plan_visible_motion() -> void:
	var to_target: Vector3 = target_position - global_position
	var to_target_flat: Vector3 = to_target
	to_target_flat.y = 0.0
	var near_goal: bool = to_target_flat.length() <= settle_radius

	if to_target.length() < 0.001:
		planned_motion_local = planned_motion_local.lerp(Vector3(0.0, 0.0, -1.0), planner_direction_smooth).normalized()
		planned_motion_world = (transform.basis * planned_motion_local).normalized()
		return

	var goal_world: Vector3 = to_target.normalized()
	var goal_local: Vector3 = (transform.basis.inverse() * goal_world).normalized()

	if not lidar_enabled or lidar == null:
		var fallback_local: Vector3 = goal_local

		if vision_enabled and vision_corridor_confidence > 0.10:
			var v_mix: float = vision_corridor_weight * vision_corridor_confidence
			if near_goal:
				v_mix *= vision_corridor_near_goal_scale
			fallback_local = goal_local.lerp(vision_corridor_local, v_mix).normalized()

		planned_motion_local = planned_motion_local.lerp(fallback_local, planner_direction_smooth).normalized()
		planned_motion_world = (transform.basis * planned_motion_local).normalized()
		return

	var goal_angle_deg: float = rad_to_deg(atan2(goal_local.x, -goal_local.z))

	var best_score: float = -1e20
	var best_dir_local: Vector3 = Vector3(0.0, 0.0, -1.0)

	var half_fov: float = planner_fov_deg * 0.5
	var angle: float = -half_fov
	var climb_samples: Array[float] = [0.0, 0.14, 0.26, 0.40, 0.56, 0.72]

	while angle <= half_fov:
		var yaw_rad: float = deg_to_rad(angle)

		for climb_bias in climb_samples:
			var dir_local: Vector3 = Vector3(
				sin(yaw_rad),
				climb_bias,
				-cos(yaw_rad)
			).normalized()

			var goal_align: float = dir_local.dot(goal_local)
			var forwardness: float = max(-dir_local.z, 0.0)
			var turn_penalty: float = abs(angle) / max(half_fov, 0.001)

			var base_sample: Dictionary = _sample_margin_score(angle, lidar, 12.0, 0.25)
			var clear_mid: float = base_sample["center"]
			var lateral_balance: float = base_sample["lateral_balance"]
			var lateral_min_margin: float = base_sample["min_margin"]

			var clear_up: float = clear_mid
			if lidar_up != null:
				var up_sample: Dictionary = _sample_margin_score(angle, lidar_up, 12.0, 0.25)
				clear_up = up_sample["center"]

			var clear_down: float = clear_mid
			if lidar_down != null:
				var down_sample: Dictionary = _sample_margin_score(angle, lidar_down, 12.0, 0.25)
				clear_down = down_sample["center"]

			var vertical_min_margin: float = min(clear_up, clear_down)
			var vertical_balance: float = 1.0 - clamp(abs(clear_up - clear_down) / 4.0, 0.0, 1.0)

			# If there is much more room above than below, the current line is too low.
			# Convert that into a desired climb amount for this yaw direction.
			var vertical_offset: float = clamp((clear_up - clear_down) / 4.0, -1.0, 1.0)

			# Bias toward slightly above true center in constrained spaces.
			var desired_climb_bias: float = clamp(
				0.18 + vertical_offset * 0.55 + planner_vertical_center_bias * 0.18,
				0.0,
				0.85
			)

			# Reward climb samples that match the safer vertical line.
			var climb_alignment: float = 1.0 - abs(climb_bias - desired_climb_bias) / 0.85
			climb_alignment = clamp(climb_alignment, 0.0, 1.0)

			# Stronger when the passage is tight.
			var constrained_vertical: float = 1.0 - clamp(vertical_min_margin / max(planner_vertical_safe_distance, 0.001), 0.0, 1.0)
			var vertical_center_bias_score: float = climb_alignment * (0.35 + constrained_vertical * 0.65)

			var combined_min_margin: float = min(lateral_min_margin, vertical_min_margin)
			var min_margin_score: float = clamp((combined_min_margin - planner_body_margin) / max(planner_safe_distance, 0.001), 0.0, 1.5)

			var clearance_score: float = clamp(clear_mid / max(planner_safe_distance, 0.001), 0.0, 1.5)
			var centering_score: float = (
				lateral_balance * planner_lateral_balance_weight +
				vertical_balance * planner_vertical_balance_weight
			)

			var blocked_penalty: float = 0.0
			if combined_min_margin < planner_body_margin:
				blocked_penalty = (planner_body_margin - combined_min_margin) * planner_blocked_penalty_gain * 2.2
			elif clear_mid < 1.6:
				blocked_penalty = (1.6 - clear_mid) * planner_blocked_penalty_gain

			var climb_penalty: float = climb_bias * planner_climb_weight

			# If the route is vertically constrained and we're below center,
			# reduce the penalty for climbing.
			if vertical_offset > 0.08 and vertical_min_margin < planner_vertical_safe_distance * 1.4:
				climb_penalty *= 0.35

			# Extra reward when front is tight but up/down balance implies a centered corridor
			var corridor_reward: float = 0.0
			if clear_mid < climb_trigger_dist and combined_min_margin > planner_body_margin:
				corridor_reward = 1.0 + vertical_balance * 0.7 + lateral_balance * 0.5

			var score: float = (
				goal_align * planner_progress_weight +
				forwardness * planner_forward_gain +
				clearance_score * planner_clearance_weight +
				min_margin_score * planner_min_margin_weight +
				centering_score * planner_centering_weight +
				vertical_center_bias_score * planner_vertical_margin_bias +
				corridor_reward -
				turn_penalty * planner_turn_weight -
				blocked_penalty -
				climb_penalty
			)

			if climb_bias > 0.08:
				score += clamp(clear_up / max(planner_vertical_safe_distance, 0.001), 0.0, 1.5) * 0.8

				if abs(angle - goal_angle_deg) < 16.0 and vertical_min_margin > planner_body_margin:
					score += 0.6

			if vision_enabled and vision_corridor_confidence > 0.10:
				var vision_align: float = clamp(dir_local.dot(vision_corridor_local), -1.0, 1.0)

				var v_mix: float = vision_corridor_weight * vision_corridor_confidence
				if near_goal:
					v_mix *= vision_corridor_near_goal_scale

				var vision_factor: float = lerp(
					1.0 - v_mix,
					1.0 + v_mix,
					vision_align * 0.5 + 0.5
				)

				score *= vision_factor

			if score > best_score:
				best_score = score
				best_dir_local = dir_local

		angle += planner_step_deg

	planned_motion_local = planned_motion_local.lerp(best_dir_local, planner_direction_smooth).normalized()
	planned_motion_world = (transform.basis * planned_motion_local).normalized()

func vertical_avoidance_update(delta: float) -> void:
	var to_target: Vector3 = target_position - global_position
	var flat_dist: float = Vector2(to_target.x, to_target.z).length()

	if flat_dist <= settle_radius:
		var target_h_goal: float = clamp(target_position.y, hover_height - 1.0, max_hover_height)
		desired_hover_height = move_toward(desired_hover_height, target_h_goal, climb_rate * delta)
		return

	var up_intent: float = max(planned_motion_local.y, 0.0)
	var target_h: float = hover_height

	if up_intent > 0.02:
		var climb_amount: float = pow(up_intent, 0.42)
		target_h = hover_height + climb_amount * climb_target_offset
		target_h = min(target_h, max_hover_height)
		desired_hover_height = move_toward(desired_hover_height, target_h, climb_rate * delta)
	else:
		desired_hover_height = move_toward(desired_hover_height, hover_height, return_rate * delta)

func update_corridor_lock(delta: float, candidate_motion_local: Vector3) -> void:
	var to_target: Vector3 = target_position - global_position
	if to_target.length() < 0.001:
		corridor_locked = false
		corridor_lock_timer = 0.0
		return

	var center_clear: float = lidar_center_latest
	var goal_local: Vector3 = (transform.basis.inverse() * to_target.normalized()).normalized()
	var goal_align: float = candidate_motion_local.dot(goal_local)

	var geometry_support: bool = center_clear < climb_trigger_dist

	var vision_support: bool = false
	if vision_enabled and vision_corridor_confidence > 0.18:
		vision_support = candidate_motion_local.dot(vision_corridor_local) > 0.45

	var candidate_is_gap_route: bool = (
		candidate_motion_local.y > corridor_lock_min_up and
		goal_align > corridor_lock_goal_align and
		geometry_support and vision_support
	)

	if not corridor_locked:
		if candidate_is_gap_route:
			corridor_locked = true
			corridor_lock_timer = corridor_lock_time
			corridor_locked_motion_local = candidate_motion_local
	else:
		corridor_lock_timer = max(corridor_lock_timer - delta, 0.0)

		if candidate_is_gap_route:
			corridor_lock_timer = corridor_lock_time
			corridor_locked_motion_local = corridor_locked_motion_local.lerp(candidate_motion_local, 0.18).normalized()

		var emergency_blocked: bool = center_clear < corridor_emergency_clearance
		if corridor_lock_timer <= 0.0 or emergency_blocked:
			corridor_locked = false

func fuse_avoidance(
	vision_a: bool,
	vision_dir: float,
	vision_s: float,
	lidar_a: bool,
	lidar_dir: float,
	lidar_s: float)-> void:
	if fusion_mode == "vision":
		avoid_active = vision_a
		avoid_yaw_dir = vision_dir
		avoid_strength = vision_s
		return

	if fusion_mode == "lidar":
		avoid_active = lidar_a
		avoid_yaw_dir = lidar_dir
		avoid_strength = lidar_s
		return

	if vision_a or lidar_a:
		avoid_active = true
		if lidar_s >= vision_s:
			avoid_yaw_dir = lidar_dir
			avoid_strength = lidar_s
		else:
			avoid_yaw_dir = vision_dir
			avoid_strength = vision_s
	else:
		avoid_active = false
		avoid_yaw_dir = 0.0
		avoid_strength = 0.0

func yaw_toward_goal(goal_dir: Vector3, delta: float) -> void:
	var desired_yaw: float = atan2(-goal_dir.x, -goal_dir.z)
	rotation.y = lerp_angle(rotation.y, desired_yaw, delta * yaw_speed)

func steer_toward_goal(dist: float, delta: float, settling: bool) -> void:
	if dist <= stop_radius:
		target_pitch = 0.0
		target_roll = 0.0
		return

	var to_target: Vector3 = target_position - global_position
	var to_target_flat: Vector3 = to_target
	to_target_flat.y = 0.0

	if settling:
		if to_target_flat.length() > 0.001:
			var settle_dir: Vector3 = to_target_flat.normalized()
			var desired_yaw: float = atan2(-settle_dir.x, -settle_dir.z)
			rotation.y = lerp_angle(rotation.y, desired_yaw, delta * settle_yaw_speed)

		var speed_scale_settle: float = clamp(dist / max(settle_radius, 0.001), 0.0, 1.0)
		speed_scale_settle = pow(speed_scale_settle, 0.7)

		var commanded_settle: float = lerp(0.02, cruise_tilt, speed_scale_settle)
		target_pitch = -commanded_settle * settle_pitch_scale
		target_roll = lerpf(target_roll, 0.0, delta * 4.0)

		if avoid_active:
			var c_settle: float = lidar_center_latest
			if lidar_enabled and c_settle < no_forward_dist:
				var soften_settle: float = clamp(c_settle / max(no_forward_dist, 0.001), 0.55, 1.0)
				target_pitch *= soften_settle

		return

	var move_world: Vector3 = planned_motion_world.normalized()
	var flat_move: Vector3 = move_world
	flat_move.y = 0.0

	if flat_move.length() > 0.001:
		flat_move = flat_move.normalized()
		yaw_toward_goal(flat_move, delta)

	var speed_scale: float = clamp(dist / arrive_radius, 0.0, 1.0)
	speed_scale = pow(speed_scale, 0.35)
	var commanded: float = lerp(cruise_tilt, max_forward_tilt, speed_scale)

	var forward_keep: float = clamp(-planned_motion_local.z, 0.35, 1.0)
	var side_amount: float = clamp(planned_motion_local.x, -1.0, 1.0)
	var up_amount: float = clamp(planned_motion_local.y, 0.0, 1.0)

	target_pitch = -commanded * forward_keep
	target_roll = side_amount * max_side_tilt * 0.8

	if up_amount > 0.12:
		target_roll *= lerp(1.0, 0.55, up_amount)

	if avoid_active:
		var c: float = lidar_center_latest
		var a_strength: float = clamp(avoid_strength, 0.0, 1.0)

		var yaw_scale: float = 1.0
		if lidar_enabled:
			yaw_scale = clamp((c - 0.8) / 2.2, 0.15, 1.0)

		var corridor_blend: float = 1.0 if corridor_locked else 0.0
		var yaw_override_scale: float = lerp(1.0, 0.25, corridor_blend)
		var roll_override_scale: float = lerp(1.0, 0.30, corridor_blend)

		rotation.y += avoid_yaw_dir * avoid_yaw_speed * yaw_scale * delta * 0.55 * yaw_override_scale

		if lidar_enabled and c < no_forward_dist:
			var soften: float = clamp(c / max(no_forward_dist, 0.001), 0.35, 1.0)
			if corridor_locked:
				soften = clamp(soften, 0.55, 1.0)
			target_pitch *= soften
		else:
			var slow: float = lerp(1.0, 0.72, a_strength)
			target_pitch *= slow

		target_roll = lerp(
			target_roll,
			avoid_yaw_dir * max_side_tilt * roll_override_scale,
			avoid_bank * 0.45
		)

func apply_braking(dist: float) -> void:
	if dist > arrive_radius:
		return

	var v: Vector3 = linear_velocity
	v.y = 0.0

	var t: float = 1.0 - clamp(dist / arrive_radius, 0.0, 1.0)
	t = pow(t, 1.6)

	var brake_gain: float = brake_strength
	if dist < settle_radius:
		brake_gain *= 2.2

	apply_central_force(-v * brake_gain * t * mass)
	

func get_camera_feed() -> Texture2D:
	return vision_viewport.get_texture()

func is_camera_enabled() -> bool:
	return vision_enabled

func set_camera_enabled(enabled: bool) -> void:
	vision_enabled = enabled
	if vision_camera != null:
		vision_camera.current = enabled
