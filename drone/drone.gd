extends RigidBody3D

signal send_message(msg: String)

# -----------------------
# Flight / movement tuning
# -----------------------
@export var tilt_speed: float = 3.0
@export var min_thrust: float = 0.0
@export var max_thrust: float = 60.0

@export var hover_height: float = 1.0
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
@export var min_vision_samples_for_path_box: int = 3
@export var min_corridor_confidence_for_path_box: float = 0.18

@export var planner_camera_near: float = 0.05
@export var planner_camera_far: float = 20.0
@export var planner_camera_fov: float = 90.0

@export var display_camera_near: float = 0.05
@export var display_camera_far: float = 150.0
@export var display_camera_fov: float = 90.0

@export var display_camera_enabled: bool = true
@export var planner_vision_enabled: bool = true

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
@export var side_trigger_dist: float = 1.3
@export var side_push_force: float = 16.0
@export var rear_trigger_dist: float = 1.0
@export var rear_push_force: float = 12.0

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
@export var climb_target_offset: float = 4.0
@export var max_hover_height: float = 8.0
@export var return_rate: float = 1.2
@export var descend_rate: float = 4.0
@export var ceiling_clearance_margin: float = 1.4
@export var vision_ceiling_block_threshold: float = 0.16
@export var vision_climb_bonus_scale: float = 0.25
@export var vision_ceiling_push_scale: float = 0.45
@export var min_up_intent_for_climb: float = 0.08
@export var climb_assist_gain: float = 1.10
@export var climb_hold_bias: float = 0.65
@export var max_extra_climb_above_hover: float = 4.0
@export var high_return_rate: float = 6.0
@export var window_clearance_margin: float = 0.35


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
@export var min_corridor_confidence_for_commit: float = 0.16
@export var vision_corridor_commit_smooth: float = 0.10

@export var camera_only_progress_scale: float = 0.70
@export var camera_only_clearance_scale: float = 1.20
@export var camera_only_min_margin_scale: float = 1.20
@export var camera_only_vision_weight_scale: float = 1.60

@export var roi_left_frac: float = 0.15
@export var roi_right_frac: float = 0.85
@export var roi_top_frac: float = 0.28
@export var roi_bottom_frac: float = 0.82

# Corridor memory
@export var corridor_lock_time: float = 0.65
@export var corridor_lock_retain_dist: float = 2.5
@export var corridor_lock_min_up: float = 0.18
@export var corridor_lock_goal_align: float = 0.55
@export var corridor_emergency_clearance: float = 1.0


# -----------------------
# Stuck Detection
# -----------------------

@export var stuck_speed_threshold: float = 0.35
@export var stuck_progress_threshold: float = 0.15
@export var stuck_time_trigger: float = 0.9
@export var stuck_backoff_time: float = 0.8
@export var stuck_turn_bias: float = 1.0



# -----------------------
# Readys
# -----------------------

@onready var vision_pivot: Node3D = $VisionPivot
@onready var planner_viewport: SubViewport = $PlannerViewport
@onready var planner_camera: Camera3D = $PlannerViewport/PlannerCamera
@onready var display_viewport: SubViewport = $DisplayViewport
@onready var display_camera: Camera3D = $DisplayViewport/DisplayCamera

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
var vision_upper_blockage: float = 0.0
var vision_lower_blockage: float = 0.0


# Vision corridor output
var vision_corridor_local: Vector3 = Vector3(0.0, 0.0, -1.0)
var vision_corridor_confidence: float = 0.0
var vision_corridor_rect_px: Rect2 = Rect2()
var vision_corridor_rect_valid: bool = false
var last_cell_weights: Array = []
var last_best_weight: float = 0.0
var last_corridor_cols: int = 0
var last_corridor_rows: int = 0
var last_vision_img: Image = null
var vision_samples_ready: int = 0

# LiDAR output
var avoid_active_lidar: bool = false
var avoid_dir_lidar: float = 0.0
var avoid_strength_lidar: float = 0.0
var lidar_center_latest: float = 20.0
var lidar_trigger_timer: float = 0.0
var lidar_side_left_latest: float = 20.0
var lidar_side_right_latest: float = 20.0
var lidar_rear_latest: float = 20.0

# LiDAR smoothing + timer
var lidar_left_f: float = 0.0
var lidar_center_f: float = 0.0
var lidar_right_f: float = 0.0
var lidar_avoid_timer: float = 0.0

# 3D motion planner output
var planned_motion_local: Vector3 = Vector3(0.0, 0.0, -1.0)
var planned_motion_world: Vector3 = Vector3(0.0, 0.0, -1.0)
var stable_vision_corridor_local: Vector3 = Vector3(0.0, 0.0, -1.0)

# Corridor lock
var corridor_lock_timer: float = 0.0
var corridor_locked: bool = false
var corridor_locked_motion_local: Vector3 = Vector3(0.0, 0.0, -1.0)

# Stuck Detection
var stuck_timer: float = 0.0
var stuck_recover_timer: float = 0.0
var last_target_dist: float = 0.0

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
		
	last_target_dist = global_position.distance_to(target_position)
		
	if planner_camera != null:
		planner_camera.near = planner_camera_near
		planner_camera.far = planner_camera_far
		planner_camera.fov = planner_camera_fov

	if display_camera != null:
		display_camera.near = display_camera_near
		display_camera.far = display_camera_far
		display_camera.fov = display_camera_fov
	
	if planner_viewport != null:
		planner_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	if display_viewport != null:
		display_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	if planner_camera != null:
		planner_camera.current = planner_vision_enabled

	if display_camera != null:
		display_camera.current = display_camera_enabled

	

	desired_hover_height = hover_height
	planned_motion_world = -transform.basis.z

func _physics_process(delta: float) -> void:
	if planner_camera != null:
		planner_camera.global_transform = vision_pivot.global_transform

	if display_camera != null:
		display_camera.global_transform = vision_pivot.global_transform

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

	# Rebuild the path box AFTER plan_visible_motion so it uses the current plan
	if (
		last_vision_img != null
		and last_cell_weights.size() > 0
		and last_best_weight > 0.0
		and vision_samples_ready >= min_vision_samples_for_path_box
		and vision_corridor_confidence >= min_corridor_confidence_for_path_box
	):
		rebuild_path_box_from_plan(last_vision_img, last_cell_weights, last_corridor_cols, last_corridor_rows, last_best_weight)
	else:
		vision_corridor_rect_valid = false
		vision_corridor_rect_px = Rect2()

	var to_target_full: Vector3 = target_position - global_position
	var to_target_flat: Vector3 = to_target_full
	to_target_flat.y = 0.0

	var dist: float = to_target_flat.length()
	var dist_3d: float = to_target_full.length()
	var vertical_dist: float = abs(to_target_full.y)

	var blocked_near_goal: bool = (
		(lidar_enabled and lidar_center_latest < no_forward_dist) or
		avoid_active_lidar or
		(avoid_active_vision and vision_corridor_confidence > 0.12)
	)

	var reached: bool = dist <= stop_radius and vertical_dist <= vertical_stop_radius
	var settling: bool = dist <= settle_radius and not blocked_near_goal

	var flat_speed: float = Vector2(linear_velocity.x, linear_velocity.z).length()
	var progress_rate: float = (last_target_dist - dist_3d) / max(delta, 0.001)
	last_target_dist = dist_3d

	var trying_to_move: bool = dist > stop_radius and (
		-planned_motion_local.z > 0.20 or
		abs(planned_motion_local.x) > 0.15 or
		planned_motion_local.y > min_up_intent_for_climb
	)

	if trying_to_move and flat_speed < stuck_speed_threshold and progress_rate < stuck_progress_threshold:
		stuck_timer += delta
	else:
		stuck_timer = max(stuck_timer - delta * 1.5, 0.0)

	if stuck_timer >= stuck_time_trigger:
		stuck_recover_timer = stuck_backoff_time
		stuck_timer = 0.0

		# Camera-only should not carry a stale reactive avoid latch into recovery,
		# because that creates a self-sustaining turn loop.
		if not lidar_enabled:
			vision_avoid_latch = false
			avoid_active_vision = false
			avoid_dir_vision = 0.0
			avoid_strength_vision = 0.0

	var direct_goal_ready: bool = (
		not avoid_active_lidar and
		not avoid_active_vision and
		lidar_center_latest > max(no_forward_dist + 0.4, 2.2) and
		abs(planned_motion_local.x) < 0.14 and
		planned_motion_local.y < 0.10 and
		-planned_motion_local.z > 0.72
	)

	if reached:
		corridor_locked = false
		corridor_lock_timer = 0.0
	else:
		# Keep corridor memory alive even inside settle radius.
		update_corridor_lock(delta, planned_motion_local)

	if corridor_locked and not (settling and direct_goal_ready):
		planned_motion_local = corridor_locked_motion_local
		planned_motion_world = (transform.basis * planned_motion_local).normalized()
	elif settling and direct_goal_ready:
		corridor_locked = false
		corridor_lock_timer = 0.0

	vertical_avoidance_update(delta)

	var height_error: float = desired_hover_height - global_position.y
	var vertical_velocity: float = linear_velocity.y
	var height_correction: float = height_error * height_strength - vertical_velocity * height_damping
	target_thrust = clamp(9.8 * mass + height_correction, min_thrust, max_thrust)

	if reached:
		_do_reached_hold(delta)
	else:
		
		var planner_owns_route: bool = (
			corridor_locked or
			(
				planner_vision_enabled and
				vision_corridor_confidence > 0.18 and
				(abs(planned_motion_local.x) > 0.14 or planned_motion_local.y > 0.10)
			)
		)

		var use_vision_active: bool = avoid_active_vision
		var use_vision_dir: float = avoid_dir_vision
		var use_vision_strength: float = avoid_strength_vision

		# If the planner already has a corridor, do not let the camera's
		# reactive avoid latch fight that route.
		if planner_owns_route:
			use_vision_active = false
			use_vision_dir = 0.0
			use_vision_strength = 0.0
			vision_avoid_latch = false

		if settling:
			use_vision_active = false
			use_vision_dir = 0.0
			use_vision_strength = 0.0
			vision_avoid_latch = false

		fuse_avoidance(
			use_vision_active, use_vision_dir, use_vision_strength,
			avoid_active_lidar, avoid_dir_lidar, avoid_strength_lidar
		)

		if stuck_recover_timer > 0.0:
			stuck_recover_timer -= delta

			if lidar_enabled:
				var right: Vector3 = transform.basis.x
				var forward: Vector3 = -transform.basis.z

				var side_bias: float = 1.0
				if lidar_side_left_latest < lidar_side_right_latest:
					side_bias = 1.0
				else:
					side_bias = -1.0

				var recover_force: Vector3 = (-forward * backoff_force + right * side_bias * avoid_force * 0.6) * mass
				recover_force.y = 0.0
				apply_central_force(recover_force)

				target_pitch = 0.0
				target_roll = side_bias * max_side_tilt * 0.5
				rotation.y += side_bias * avoid_yaw_speed * stuck_turn_bias * delta
			else:
				# Camera-only recovery should be a steering reset, not a fake shove.
				vision_avoid_latch = false
				avoid_active_vision = false
				avoid_dir_vision = 0.0
				avoid_strength_vision = 0.0
				avoid_active = false
				avoid_yaw_dir = 0.0
				avoid_strength = 0.0

				var recover_local: Vector3 = stable_vision_corridor_local
				if recover_local.length() < 0.001:
					recover_local = planned_motion_local
				if recover_local.length() < 0.001:
					recover_local = Vector3(0.0, 0.0, -1.0)

				var recover_world: Vector3 = (transform.basis * recover_local).normalized()
				var recover_flat: Vector3 = recover_world
				recover_flat.y = 0.0

				if recover_flat.length() > 0.001:
					yaw_toward_goal(recover_flat.normalized(), delta)

				target_pitch = -0.03
				target_roll = clamp(recover_local.x, -1.0, 1.0) * max_side_tilt * 0.20
		else:
			steer_toward_goal(dist, delta, settling)

			# Only LiDAR should create physical avoidance forces.
			if avoid_active and lidar_enabled:
				var phys_scale: float = settle_avoid_scale if settling else 1.0
				if planner_owns_route:
					phys_scale *= 0.35
				apply_avoidance_physics(phys_scale)

		apply_braking(dist)

		rotation.x = lerpf(rotation.x, target_pitch, delta * tilt_speed)
		rotation.z = lerpf(rotation.z, target_roll, delta * tilt_speed)

	var lift: Vector3 = transform.basis.y * target_thrust
	apply_central_force(lift)
	
	

func apply_avoidance_physics(scale: float = 1.0) -> void:
	if not lidar_enabled or lidar == null:
		return

	var right: Vector3 = transform.basis.x
	var forward: Vector3 = -transform.basis.z

	var s: float = clamp(avoid_strength, 0.0, 1.0)
	var c: float = lidar_center_latest

	var detour_amount: float = max(abs(planned_motion_local.x), max(planned_motion_local.y, 0.0))

	var corridor_commit: float = 0.0
	if corridor_locked:
		corridor_commit = 0.80

	corridor_commit = max(corridor_commit, clamp(detour_amount / 0.45, 0.0, 1.0))

	if planner_vision_enabled and vision_corridor_confidence > 0.18:
		var corridor_agreement: float = max(planned_motion_local.dot(stable_vision_corridor_local), 0.0)
		corridor_commit = max(corridor_commit, corridor_agreement * vision_corridor_confidence)

	# When the planner is intentionally taking a detour/climb corridor,
	# keep physical side-shoves weak so braking still works but orbiting does not.
	var lateral_allow: float = lerp(1.0, 0.10, corridor_commit)
	if c < no_forward_dist:
		lateral_allow = max(lateral_allow, 0.20)

	var lateral_scale: float = s
	if c > brake_dist:
		lateral_scale *= 0.55

	var lateral: Vector3 = (right * avoid_yaw_dir) * (avoid_force * lateral_scale * lateral_allow) * mass
	lateral.y = 0.0

	var v: Vector3 = linear_velocity
	v.y = 0.0
	var fwd_speed: float = v.dot(forward)

	var brake: Vector3 = Vector3.ZERO
	if c < brake_dist and fwd_speed > 0.0:
		var closeness: float = clamp((brake_dist - c) / max(brake_dist, 0.001), 0.0, 1.0)
		closeness = pow(closeness, 1.8)
		brake = -forward * fwd_speed * (forward_brake_gain * closeness) * mass

	var reverse: Vector3 = Vector3.ZERO
	if c < reverse_dist:
		var closeness2: float = clamp((reverse_dist - c) / max(reverse_dist, 0.001), 0.0, 1.0)
		closeness2 = pow(closeness2, 1.5)
		reverse = -forward * (backoff_force * 0.45 * closeness2 * lerp(1.0, 0.65, corridor_commit)) * mass

	var side_push: Vector3 = Vector3.ZERO
	if lidar_side_left_latest < side_trigger_dist:
		var left_closeness: float = clamp(
			(side_trigger_dist - lidar_side_left_latest) / max(side_trigger_dist, 0.001),
			0.0,
			1.0
		)
		side_push += right * side_push_force * left_closeness * lerp(1.0, 0.25, corridor_commit) * mass

	if lidar_side_right_latest < side_trigger_dist:
		var right_closeness: float = clamp(
			(side_trigger_dist - lidar_side_right_latest) / max(side_trigger_dist, 0.001),
			0.0,
			1.0
		)
		side_push -= right * side_push_force * right_closeness * lerp(1.0, 0.25, corridor_commit) * mass

	var rear_push: Vector3 = Vector3.ZERO
	if lidar_rear_latest < rear_trigger_dist:
		var rear_closeness: float = clamp(
			(rear_trigger_dist - lidar_rear_latest) / max(rear_trigger_dist, 0.001),
			0.0,
			1.0
		)
		rear_push = forward * rear_push_force * rear_closeness * lerp(1.0, 0.60, corridor_commit) * mass

	brake.y = 0.0
	reverse.y = 0.0
	side_push.y = 0.0
	rear_push.y = 0.0

	apply_central_force((lateral + brake + reverse + side_push + rear_push) * clamp(scale, 0.0, 1.0))

func _do_reached_hold(delta: float) -> void:
	target_pitch = 0.0
	target_roll = 0.0

	var reached_h: float = clamp(target_position.y, hover_height - 1.0, max_hover_height)
	desired_hover_height = move_toward(desired_hover_height, reached_h, high_return_rate * delta)

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
	if not planner_vision_enabled:
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0
		vision_corridor_local = Vector3(0.0, 0.0, -1.0)
		stable_vision_corridor_local = Vector3(0.0, 0.0, -1.0)
		vision_corridor_confidence = 0.0
		vision_corridor_rect_valid = false
		vision_corridor_rect_px = Rect2()
		vision_upper_blockage = 0.0
		vision_lower_blockage = 0.0
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
	var img: Image = planner_viewport.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)

	if prev_img == null:
		prev_img = img.duplicate()
		last_vision_img = img.duplicate()
		vision_samples_ready = 0
		vision_avoid_latch = false
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0
		stable_vision_corridor_local = Vector3(0.0, 0.0, -1.0)
		vision_corridor_local = Vector3(0.0, 0.0, -1.0)
		vision_corridor_confidence = 0.0
		vision_corridor_rect_valid = false
		vision_corridor_rect_px = Rect2()
		return

	var w: int = img.get_width()
	var h: int = img.get_height()
	
	# Estimate how blocked the upper and lower forward view are.
	# Lower blockage being higher than upper blockage suggests climbing may help.
	var upper_edges: float = edge_density(
		img,
		int(w * 0.35), int(w * 0.65),
		int(h * 0.10), int(h * 0.35),
		edge_step
	)

	var lower_edges: float = edge_density(
		img,
		int(w * 0.35), int(w * 0.65),
		int(h * 0.45), int(h * 0.75),
		edge_step
	)

	vision_upper_blockage = lerpf(vision_upper_blockage, upper_edges, 0.18)
	vision_lower_blockage = lerpf(vision_lower_blockage, lower_edges, 0.18)

	var left_flow: float = flow_band(img, prev_img, int(w * 0.10), int(w * 0.35), int(h * 0.35), int(h * 0.65), flow_step)
	var center_flow: float = flow_band(img, prev_img, int(w * 0.40), int(w * 0.60), int(h * 0.35), int(h * 0.65), flow_step)
	var right_flow: float = flow_band(img, prev_img, int(w * 0.65), int(w * 0.90), int(h * 0.35), int(h * 0.65), flow_step)

	var edge_c: float = edge_density(img, int(w * 0.40), int(w * 0.60), int(h * 0.35), int(h * 0.65), edge_step)

	update_vision_corridor(img)

	prev_img = img.duplicate()
	last_vision_img = img.duplicate()
	vision_samples_ready += 1

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

	var roi_x0: int = int(w * roi_left_frac)
	var roi_x1: int = int(w * roi_right_frac)
	var roi_y0: int = int(h * roi_top_frac)
	var roi_y1: int = int(h * roi_bottom_frac)

	var roi_w: int = max(roi_x1 - roi_x0, 1)
	var roi_h: int = max(roi_y1 - roi_y0, 1)

	var to_target: Vector3 = target_position - global_position
	var goal_local: Vector3 = Vector3(0.0, 0.0, -1.0)
	if to_target.length() > 0.001:
		goal_local = (transform.basis.inverse() * to_target.normalized()).normalized()

	var goal_px: float = clamp(goal_local.x / 0.8, -1.0, 1.0) * 0.5 + 0.5
	var goal_py: float = (1.0 - clamp(goal_local.y / 0.6, 0.0, 1.0)) * 0.7 + 0.15

	var mem_px: float = clamp(stable_vision_corridor_local.x / 0.8, -1.0, 1.0) * 0.5 + 0.5
	var mem_py: float = (1.0 - clamp(stable_vision_corridor_local.y / 0.6, 0.0, 1.0)) * 0.7 + 0.15

	var climb_hint: float = clamp(
		(vision_lower_blockage - vision_upper_blockage - 0.015) / 0.12,
		0.0,
		1.0
	)

	var total_weight: float = 0.0
	var best_weight: float = -1e20
	var seed_col: int = int(cols * 0.5)
	var seed_row: int = int(rows * 0.4)

	var cell_weights: Array = []
	cell_weights.resize(rows)
	for r in range(rows):
		cell_weights[r] = []

	for row in range(rows):
		for col in range(cols):
			var x0: int = roi_x0 + int(float(col) / float(cols) * float(roi_w))
			var x1: int = roi_x0 + int(float(col + 1) / float(cols) * float(roi_w))
			var y0: int = roi_y0 + int(float(row) / float(rows) * float(roi_h))
			var y1: int = roi_y0 + int(float(row + 1) / float(rows) * float(roi_h))

			var edges: float = edge_density(img, x0, x1, y0, y1, edge_step)

			var flow: float = 0.0
			if prev_img != null:
				flow = flow_band(img, prev_img, x0, x1, y0, y1, flow_step)

			var openness: float = 1.0 / (0.001 + edges * 2.4 + flow * 1.8)

			var cx: float = (float(col) + 0.5) / float(cols)
			var cy: float = (float(row) + 0.5) / float(rows)

			var center_bonus: float = 1.0 - abs(cx - 0.5) / 0.5
			center_bonus = clamp(center_bonus, 0.0, 1.0)

			var row_norm: float = float(row) / max(float(rows - 1), 1.0)

			var base_vertical_pref: float = 1.0 - abs(row_norm - 0.42) / 0.58
			base_vertical_pref = clamp(base_vertical_pref, 0.0, 1.0)

			var upper_pref: float = 1.0 - abs(row_norm - 0.24) / 0.42
			upper_pref = clamp(upper_pref, 0.0, 1.0)

			var vertical_pref: float = lerp(base_vertical_pref, upper_pref, climb_hint)

			var goal_bias: float = 1.0 - Vector2(cx, cy).distance_to(Vector2(goal_px, goal_py)) / 1.1
			goal_bias = clamp(goal_bias, 0.0, 1.0)

			var memory_bias: float = 1.0 - Vector2(cx, cy).distance_to(Vector2(mem_px, mem_py)) / 1.1
			memory_bias = clamp(memory_bias, 0.0, 1.0)

			var upward_route_bonus: float = 0.0
			if climb_hint > 0.0:
				upward_route_bonus = (1.0 - row_norm) * climb_hint

			var top_penalty: float = 0.0
			if row == 0:
				top_penalty = lerp(0.10, 0.02, climb_hint)

			var weight: float = (
				openness * 2.4 +
				goal_bias * 0.90 +
				memory_bias * 0.70 +
				center_bonus * 0.16 +
				vertical_pref * 0.42 +
				upward_route_bonus * 0.55 -
				top_penalty
			)
			weight = max(weight, 0.0)

			cell_weights[row].append(weight)
			total_weight += weight

			if weight > best_weight:
				best_weight = weight
				seed_col = col
				seed_row = row

	last_cell_weights = cell_weights
	last_best_weight = max(best_weight, 0.0)
	last_corridor_cols = cols
	last_corridor_rows = rows

	if best_weight <= 0.0001:
		vision_corridor_local = vision_corridor_local.lerp(Vector3(0.0, 0.0, -1.0), 0.18).normalized()
		vision_corridor_confidence = lerpf(vision_corridor_confidence, 0.0, 0.18)
		vision_corridor_rect_valid = false
		vision_corridor_rect_px = Rect2()
		return

	var threshold: float = best_weight * lerp(0.68, 0.76, 1.0 - climb_hint)

	var visited: Array = []
	visited.resize(rows)
	for r in range(rows):
		visited[r] = []
		for _c in range(cols):
			visited[r].append(false)

	var queue: Array[Vector2i] = [Vector2i(seed_col, seed_row)]
	visited[seed_row][seed_col] = true

	var comp_weight: float = 0.0
	var comp_sum_x: float = 0.0
	var comp_sum_y: float = 0.0

	while queue.size() > 0:
		var p: Vector2i = queue.pop_front()
		var c: int = p.x
		var r: int = p.y

		var weight: float = cell_weights[r][c]
		if weight < threshold:
			continue

		var cx: float = (float(c) + 0.5) / float(cols)
		var cy: float = (float(r) + 0.5) / float(rows)

		comp_weight += weight
		comp_sum_x += cx * weight
		comp_sum_y += cy * weight

		var neighbors: Array[Vector2i] = [
			Vector2i(c - 1, r),
			Vector2i(c + 1, r),
			Vector2i(c, r - 1),
			Vector2i(c, r + 1)
		]

		for n in neighbors:
			if n.x < 0 or n.x >= cols or n.y < 0 or n.y >= rows:
				continue
			if visited[n.y][n.x]:
				continue
			visited[n.y][n.x] = true
			if cell_weights[n.y][n.x] >= threshold:
				queue.append(n)

	if comp_weight <= 0.0001:
		vision_corridor_local = vision_corridor_local.lerp(Vector3(0.0, 0.0, -1.0), 0.18).normalized()
		vision_corridor_confidence = lerpf(vision_corridor_confidence, 0.0, 0.18)
		vision_corridor_rect_valid = false
		vision_corridor_rect_px = Rect2()
		return

	var mean_x: float = comp_sum_x / comp_weight
	var mean_y: float = comp_sum_y / comp_weight

	var x_norm: float = mean_x * 2.0 - 1.0
	var y_norm: float = 1.0 - mean_y * 2.0

	var lateral: float = x_norm * 0.34
	var climb: float = max(y_norm, 0.0) * lerp(0.48, 0.66, climb_hint)

	var candidate: Vector3 = Vector3(lateral, climb, -1.0).normalized()

	var component_ratio: float = clamp(comp_weight / max(total_weight, 0.001), 0.0, 1.0)
	var confidence: float = clamp(0.18 + component_ratio * 0.58 + climb_hint * 0.14, 0.0, 0.94)

	vision_corridor_local = vision_corridor_local.lerp(candidate, 0.32).normalized()
	vision_corridor_confidence = lerpf(vision_corridor_confidence, confidence, 0.26)

	if vision_corridor_confidence >= min_corridor_confidence_for_commit:
		stable_vision_corridor_local = stable_vision_corridor_local.lerp(
			vision_corridor_local,
			0.26
		).normalized()

func rebuild_path_box_from_plan(img: Image, cell_weights: Array, cols: int, rows: int, best_weight: float) -> void:
	var w: int = img.get_width()
	var h: int = img.get_height()

	var conf_t: float = clamp(vision_corridor_confidence, 0.0, 1.0)
	var threshold: float = best_weight * lerp(0.84, 0.72, conf_t)

	# Seed from the actual chosen plan, not from the biggest open image region.
	var dir: Vector3 = planned_motion_local.normalized()

	var x_norm: float = clamp(dir.x / 0.8, -1.0, 1.0)
	var y_norm: float = clamp(dir.y / 0.6, 0.0, 1.0)

	var px: float = (x_norm + 1.0) * 0.5
	var py: float = (1.0 - y_norm) * 0.7 + 0.15

	var seed_col: int = clamp(int(px * float(cols)), 0, cols - 1)
	var seed_row: int = clamp(int(py * float(rows)), 0, rows - 1)

	if cell_weights[seed_row][seed_col] < threshold:
		var found: bool = false
		var best_dist: float = 999999.0
		var best_seed_col: int = seed_col
		var best_seed_row: int = seed_row

		for row in range(rows):
			for col in range(cols):
				var weight: float = cell_weights[row][col]
				if weight >= threshold:
					var dx: float = float(col - seed_col)
					var dy: float = float(row - seed_row)
					var d2: float = dx * dx + dy * dy
					if d2 < best_dist:
						best_dist = d2
						best_seed_col = col
						best_seed_row = row
						found = true

		if found:
			seed_col = best_seed_col
			seed_row = best_seed_row
		else:
			vision_corridor_rect_valid = false
			vision_corridor_rect_px = Rect2()
			return

	var visited: Array = []
	visited.resize(rows)
	for r in range(rows):
		visited[r] = []
		for _c in range(cols):
			visited[r].append(false)

	var queue: Array[Vector2i] = [Vector2i(seed_col, seed_row)]
	visited[seed_row][seed_col] = true

	var min_col: int = seed_col
	var max_col: int = seed_col
	var min_row: int = seed_row
	var max_row: int = seed_row

	while queue.size() > 0:
		var p: Vector2i = queue.pop_front()
		var c: int = p.x
		var r: int = p.y

		min_col = min(min_col, c)
		max_col = max(max_col, c)
		min_row = min(min_row, r)
		max_row = max(max_row, r)

		var neighbors: Array[Vector2i] = [
			Vector2i(c - 1, r),
			Vector2i(c + 1, r),
			Vector2i(c, r - 1),
			Vector2i(c, r + 1)
		]

		for n in neighbors:
			if n.x < 0 or n.x >= cols or n.y < 0 or n.y >= rows:
				continue
			if visited[n.y][n.x]:
				continue
			visited[n.y][n.x] = true

			if cell_weights[n.y][n.x] >= threshold:
				queue.append(n)

	if max_col >= min_col and max_row >= min_row:
		var rx: float = float(min_col) / float(cols) * float(w)
		var ry: float = float(min_row) / float(rows) * float(h)
		var rw: float = float(max_col - min_col + 1) / float(cols) * float(w)
		var rh: float = float(max_row - min_row + 1) / float(rows) * float(h)

		vision_corridor_rect_px = Rect2(rx, ry, rw, rh)

		# Tighten the box a bit so it reads like a route, not a region blob.
		var shrink_x: float = vision_corridor_rect_px.size.x * 0.12
		var shrink_y: float = vision_corridor_rect_px.size.y * 0.18
		vision_corridor_rect_px.position += Vector2(shrink_x, shrink_y)
		vision_corridor_rect_px.size -= Vector2(shrink_x * 2.0, shrink_y * 2.0)

		vision_corridor_rect_valid = vision_corridor_rect_px.size.x > 0.0 and vision_corridor_rect_px.size.y > 0.0
	else:
		vision_corridor_rect_valid = false
		vision_corridor_rect_px = Rect2()


func get_vision_corridor_rect_normalized() -> Rect2:
	if not vision_corridor_rect_valid or planner_viewport == null:
		return Rect2()

	var vp_size: Vector2 = planner_viewport.size
	if vp_size.x <= 0.0 or vp_size.y <= 0.0:
		return Rect2()

	return Rect2(
		vision_corridor_rect_px.position / vp_size,
		vision_corridor_rect_px.size / vp_size
	)


func has_vision_corridor_rect() -> bool:
	return vision_corridor_rect_valid


func is_target_visible() -> bool:
	if display_camera == null:
		return false

	if display_camera.is_position_behind(target_position):
		return false

	var screen_pos: Vector2 = display_camera.unproject_position(target_position)
	var vp_size: Vector2 = display_viewport.size

	if screen_pos.x < 0.0 or screen_pos.y < 0.0 or screen_pos.x > vp_size.x or screen_pos.y > vp_size.y:
		return false

	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(
		display_camera.global_position,
		target_position
	)
	query.exclude = [self]

	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true

	if target != null and result.has("collider") and result["collider"] == target:
		return true

	return result["position"].distance_to(target_position) < 0.2


func get_vision_camera() -> Camera3D:
	return display_camera

func get_planner_camera() -> Camera3D:
	return planner_camera

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
	var side_left: float = lidar.get_sector_percentile(-95.0, -70.0, 0.25)
	var side_right: float = lidar.get_sector_percentile(70.0, 95.0, 0.25)
	var rear: float = lidar.get_sector_percentile(155.0, 180.0, 0.25)

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
	lidar_side_left_latest = side_left
	lidar_side_right_latest = side_right
	lidar_rear_latest = rear

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
	
	var target_visible_now: bool = is_target_visible()
	
	var effective_progress_weight: float = planner_progress_weight
	var effective_clearance_weight: float = planner_clearance_weight
	var effective_min_margin_weight: float = planner_min_margin_weight
	var effective_vision_weight: float = vision_corridor_weight

	if planner_vision_enabled and not lidar_enabled:
		effective_progress_weight *= camera_only_progress_scale
		effective_clearance_weight *= camera_only_clearance_scale
		effective_min_margin_weight *= camera_only_min_margin_scale
		effective_vision_weight *= camera_only_vision_weight_scale

	if not lidar_enabled or lidar == null:
		var fallback_local: Vector3 = goal_local

		if planner_vision_enabled and vision_corridor_confidence > 0.10:
			var visual_up_route: bool = (
				vision_corridor_confidence > min_corridor_confidence_for_commit and
				stable_vision_corridor_local.y > 0.10 and
				vision_lower_blockage > vision_upper_blockage + 0.015 and
				vision_upper_blockage < vision_ceiling_block_threshold
			)

			var corridor_commit: float = clamp(0.30 + vision_corridor_confidence * 1.00, 0.0, 0.95)

			# Commit earlier to a valid upper route, even before the goal is fully occluded.
			if visual_up_route:
				corridor_commit = max(corridor_commit, 0.76)

			if avoid_active_vision or not target_visible_now:
				corridor_commit = max(corridor_commit, 0.66)

			if near_goal and target_visible_now and not visual_up_route:
				corridor_commit *= vision_corridor_near_goal_scale

			var route_local: Vector3 = stable_vision_corridor_local

			# Give camera-only mode a little more proactive climb authority when the
			# visual corridor is clearly above the blocked lower region.
			if visual_up_route:
				route_local = Vector3(
					route_local.x,
					max(route_local.y, 0.18),
					min(route_local.z, -0.70)
				).normalized()

			fallback_local = goal_local.lerp(route_local, corridor_commit).normalized()

		var follow_smooth: float = planner_direction_smooth
		if vision_corridor_confidence > 0.20 and (abs(fallback_local.x) > 0.12 or fallback_local.y > 0.10):
			follow_smooth = max(follow_smooth, 0.52)

		planned_motion_local = planned_motion_local.lerp(fallback_local, follow_smooth).normalized()
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

			var vertical_balance: float = 1.0 - clamp(abs(clear_up - clear_down) / 4.0, 0.0, 1.0)
			var vertical_offset: float = clamp((clear_up - clear_down) / 4.0, -1.0, 1.0)

			# For upward candidates, score using upward clearance instead of punishing
			# them because the drone is close to the floor.
			var climb_t: float = clamp(climb_bias / 0.72, 0.0, 1.0)
			var vertical_clear_for_candidate: float = lerpf(clear_mid, clear_up, climb_t)
			var vertical_escape_gain: float = max(clear_up - clear_mid, 0.0)

			var desired_climb_bias: float = clamp(
				0.18 + vertical_offset * 0.55 + planner_vertical_center_bias * 0.18,
				0.0,
				0.85
			)

			var climb_alignment: float = 1.0 - abs(climb_bias - desired_climb_bias) / 0.85
			climb_alignment = clamp(climb_alignment, 0.0, 1.0)

			var constrained_vertical: float = 1.0 - clamp(
				vertical_clear_for_candidate / max(planner_vertical_safe_distance, 0.001),
				0.0,
				1.0
			)
			var vertical_center_bias_score: float = climb_alignment * (0.35 + constrained_vertical * 0.65)

			var combined_min_margin: float = min(lateral_min_margin, vertical_clear_for_candidate)
			var min_margin_score: float = clamp(
				(combined_min_margin - planner_body_margin) / max(planner_safe_distance, 0.001),
				0.0,
				1.5
			)

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
			if vertical_offset > 0.08 and vertical_clear_for_candidate < planner_vertical_safe_distance * 1.4:
				climb_penalty *= 0.35

			var corridor_reward: float = 0.0
			if clear_mid < climb_clear_dist and combined_min_margin > planner_body_margin:
				corridor_reward = 1.0 + vertical_balance * 0.7 + lateral_balance * 0.5

			var score: float = (
				goal_align * effective_progress_weight +
				forwardness * planner_forward_gain +
				clearance_score * effective_clearance_weight +
				min_margin_score * effective_min_margin_weight +
				centering_score * planner_centering_weight +
				vertical_center_bias_score * planner_vertical_margin_bias +
				corridor_reward -
				turn_penalty * planner_turn_weight -
				blocked_penalty -
				climb_penalty
			)

			if climb_bias > 0.08:
				score += clamp(
					vertical_clear_for_candidate / max(planner_vertical_safe_distance, 0.001),
					0.0,
					1.5
				) * 0.8

				score += clamp(
					vertical_escape_gain / max(planner_vertical_safe_distance, 0.001),
					0.0,
					1.0
				) * 0.6

				if abs(angle - goal_angle_deg) < 16.0 and vertical_clear_for_candidate > planner_body_margin:
					score += 0.6

			if planner_vision_enabled and vision_corridor_confidence > 0.10:
				var vision_align: float = clamp(dir_local.dot(stable_vision_corridor_local), -1.0, 1.0)
				var v_mix: float = effective_vision_weight * vision_corridor_confidence

				if near_goal and target_visible_now:
					v_mix *= vision_corridor_near_goal_scale

				var needs_corridor: bool = (
					not target_visible_now or
					clear_mid < climb_clear_dist or
					avoid_active_vision
				)

				if needs_corridor:
					score += vision_align * (0.9 + 2.4 * v_mix)

					if vision_align < -0.15:
						score -= (0.35 + 1.4 * v_mix)

			if score > best_score:
				best_score = score
				best_dir_local = dir_local

		angle += planner_step_deg

	planned_motion_local = planned_motion_local.lerp(best_dir_local, planner_direction_smooth).normalized()
	planned_motion_world = (transform.basis * planned_motion_local).normalized()

func vertical_avoidance_update(delta: float) -> void:
	var to_target: Vector3 = target_position - global_position
	var flat_dist: float = Vector2(to_target.x, to_target.z).length()
	var vertical_goal_error: float = target_position.y - global_position.y
	var target_visible_now: bool = is_target_visible()

	var at_goal_now: bool = (
		flat_dist <= stop_radius and
		abs(vertical_goal_error) <= vertical_stop_radius
	)

	if at_goal_now:
		corridor_locked = false
		corridor_lock_timer = 0.0

		var reached_h: float = clamp(target_position.y, hover_height - 1.0, max_hover_height)
		desired_hover_height = move_toward(desired_hover_height, reached_h, high_return_rate * delta)
		return

	var direct_height_match: bool = (
		flat_dist <= settle_radius and
		max(planned_motion_local.y, 0.0) < 0.10 and
		(not lidar_enabled or lidar_center_latest > climb_clear_dist) and
		not avoid_active_vision and
		target_visible_now
	)

	if direct_height_match:
		var target_h_goal: float = clamp(target_position.y, hover_height - 1.0, max_hover_height)
		desired_hover_height = move_toward(desired_hover_height, target_h_goal, climb_rate * delta)
		return

	var target_h: float = hover_height
	var up_intent: float = max(planned_motion_local.y, 0.0)

	var locked_up: float = 0.0
	if corridor_locked:
		locked_up = max(corridor_locked_motion_local.y, 0.0)

	var visual_corridor_up: float = 0.0
	if planner_vision_enabled:
		visual_corridor_up = max(stable_vision_corridor_local.y, 0.0)

	var route_commit_up: float = max(up_intent, max(locked_up, visual_corridor_up))

	var upward_bonus: float = 0.0
	var downward_push: float = 0.0

	var front_tight: bool = false
	var more_room_above_lidar: bool = false
	var upper_tight: bool = false

	var more_open_above_vis: bool = false
	var upper_visually_blocked: bool = false
	var conf: float = clamp(vision_corridor_confidence, 0.0, 1.0)

	# -----------------------
	# LiDAR-based vertical reasoning
	# -----------------------
	if lidar_enabled and lidar_up != null and lidar_down != null:
		var clear_up: float = lidar_up.get_sector_percentile(-10.0, 10.0, 0.25)
		var clear_down: float = lidar_down.get_sector_percentile(-10.0, 10.0, 0.25)
		var clear_mid: float = lidar_center_latest

		var vertical_min: float = min(clear_up, clear_down)
		front_tight = clear_mid < climb_clear_dist
		more_room_above_lidar = clear_up > clear_down + 0.20
		upper_tight = clear_up < ceiling_clearance_margin

		if route_commit_up > min_up_intent_for_climb and more_room_above_lidar and not upper_tight:
			var climb_amount: float = pow(route_commit_up, 0.50)
			upward_bonus += climb_amount * climb_target_offset * (climb_assist_gain + 0.28)

			var goal_height_error: float = max(vertical_goal_error, 0.0)
			upward_bonus += min(goal_height_error, climb_target_offset) * 0.65

		if front_tight and more_room_above_lidar and not upper_tight:
			upward_bonus += max(climb_target_offset * 0.38, planner_body_margin + window_clearance_margin)

			var vertical_pressure: float = clamp(
				(planner_vertical_safe_distance - vertical_min) / max(planner_vertical_safe_distance, 0.001),
				0.0,
				1.0
			)
			upward_bonus += vertical_pressure * climb_target_offset * 1.00

		if corridor_locked and locked_up > min_up_intent_for_climb and not target_visible_now and not upper_tight:
			upward_bonus += climb_target_offset * 0.28

		if upper_tight:
			var ceiling_pressure: float = clamp(
				(ceiling_clearance_margin - clear_up) / max(ceiling_clearance_margin, 0.001),
				0.0,
				1.0
			)
			downward_push += ceiling_pressure * climb_target_offset

	# -----------------------
	# Camera-based vertical reasoning
	# -----------------------
	if planner_vision_enabled:
		var lower_visually_blocked: bool = vision_lower_blockage > 0.12
		more_open_above_vis = vision_upper_blockage < vision_lower_blockage * 0.90
		upper_visually_blocked = vision_upper_blockage > vision_ceiling_block_threshold

		var early_visual_climb: bool = (
			conf > min_corridor_confidence_for_commit and
			visual_corridor_up > 0.10 and
			more_open_above_vis and
			not upper_visually_blocked and
			vision_lower_blockage > vision_upper_blockage + 0.015
		)

		if not lidar_enabled:
			var visual_up_commit: float = max(route_commit_up, visual_corridor_up)

			if early_visual_climb:
				upward_bonus += climb_target_offset * 0.55 * max(conf, 0.45)

			if visual_up_commit > min_up_intent_for_climb and more_open_above_vis and not upper_visually_blocked:
				upward_bonus += pow(visual_up_commit, 0.50) * climb_target_offset * 1.25 * max(conf, 0.45)

			if lower_visually_blocked and more_open_above_vis and conf > 0.12 and not upper_visually_blocked:
				upward_bonus += climb_target_offset * max(vision_climb_bonus_scale, 0.45) * max(conf, 0.45)

			# Allow early climb even before the target is fully hidden.
			if early_visual_climb and target_visible_now:
				upward_bonus += climb_target_offset * 0.22 * max(conf, 0.45)

			if not target_visible_now and more_open_above_vis and not upper_visually_blocked:
				upward_bonus += climb_target_offset * 0.24 * max(conf, 0.45)

			if corridor_locked and locked_up > min_up_intent_for_climb and not target_visible_now and more_open_above_vis and not upper_visually_blocked:
				upward_bonus += climb_target_offset * 0.24 * max(conf, 0.45)

			if upper_visually_blocked:
				var ceiling_vis_pressure: float = clamp(
					(vision_upper_blockage - vision_ceiling_block_threshold) / max(vision_ceiling_block_threshold, 0.001),
					0.0,
					1.0
				)
				downward_push += climb_target_offset * vision_ceiling_push_scale * ceiling_vis_pressure * max(conf, 0.35)

		else:
			if route_commit_up > min_up_intent_for_climb and more_open_above_vis and not upper_visually_blocked and conf > 0.12:
				upward_bonus += climb_target_offset * 0.18 * conf

			if lower_visually_blocked and more_open_above_vis and conf > 0.12 and not upper_visually_blocked:
				upward_bonus += climb_target_offset * 0.14 * conf

			if upper_visually_blocked:
				var ceiling_vis_pressure_fused: float = clamp(
					(vision_upper_blockage - vision_ceiling_block_threshold) / max(vision_ceiling_block_threshold, 0.001),
					0.0,
					1.0
				)
				downward_push += climb_target_offset * 0.15 * ceiling_vis_pressure_fused * max(conf, 0.35)

	target_h += upward_bonus
	target_h -= downward_push

	var committed_climb: bool = (
		route_commit_up > min_up_intent_for_climb and (
			(lidar_enabled and more_room_above_lidar and not upper_tight) or
			((not lidar_enabled) and more_open_above_vis and not upper_visually_blocked)
		)
	)

	var climb_cap: float = hover_height + max_extra_climb_above_hover
	if committed_climb:
		climb_cap = max_hover_height

	target_h = clamp(target_h, hover_height - 1.0, climb_cap)
	target_h = min(target_h, max_hover_height)

	if committed_climb and target_h < desired_hover_height:
		target_h = max(target_h, desired_hover_height)

	if desired_hover_height > hover_height and target_h < desired_hover_height:
		target_h = max(target_h, hover_height + (desired_hover_height - hover_height) * climb_hold_bias)

	if target_h > desired_hover_height:
		desired_hover_height = move_toward(desired_hover_height, target_h, climb_rate * delta)
	else:
		var descend_speed: float = descend_rate
		if desired_hover_height > hover_height + 0.5:
			descend_speed = max(descend_rate, high_return_rate)
		desired_hover_height = move_toward(desired_hover_height, target_h, descend_speed * delta)

func update_corridor_lock(delta: float, candidate_motion_local: Vector3) -> void:
	var to_target: Vector3 = target_position - global_position
	if to_target.length() < 0.001:
		corridor_locked = false
		corridor_lock_timer = 0.0
		return

	var center_clear: float = lidar_center_latest
	var goal_local: Vector3 = (transform.basis.inverse() * to_target.normalized()).normalized()
	var goal_align: float = candidate_motion_local.dot(goal_local)

	var detour_amount: float = max(abs(candidate_motion_local.x), max(candidate_motion_local.y, 0.0))

	var visual_up_route: bool = (
		planner_vision_enabled and
		vision_corridor_confidence > min_corridor_confidence_for_commit and
		stable_vision_corridor_local.y > 0.10 and
		vision_lower_blockage > vision_upper_blockage + 0.015 and
		vision_upper_blockage < vision_ceiling_block_threshold
	)

	var visual_geometry_support: bool = (
		planner_vision_enabled and
		vision_corridor_confidence > min_corridor_confidence_for_commit and
		(
			not is_target_visible() or
			vision_lower_blockage > 0.12 or
			stable_vision_corridor_local.y > 0.08 or
			abs(stable_vision_corridor_local.x) > 0.12
		)
	)

	var lidar_geometry_support: bool = (
		lidar_enabled and (
			center_clear < climb_clear_dist or
			avoid_active_lidar
		)
	)

	var geometry_support: bool = lidar_geometry_support or avoid_active_vision or visual_geometry_support

	var vision_support: bool = true
	if planner_vision_enabled and vision_corridor_confidence > 0.18:
		vision_support = candidate_motion_local.dot(stable_vision_corridor_local) > 0.08

	var detour_threshold: float = corridor_lock_min_up
	var goal_align_threshold: float = corridor_lock_goal_align

	if visual_up_route:
		detour_threshold = min(detour_threshold, 0.10)
		goal_align_threshold = min(goal_align_threshold, 0.42)

	var candidate_is_gap_route: bool = (
		detour_amount > detour_threshold and
		goal_align > goal_align_threshold and
		geometry_support and
		vision_support
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
			corridor_locked_motion_local = corridor_locked_motion_local.lerp(candidate_motion_local, 0.22).normalized()

		var emergency_blocked: bool = lidar_enabled and center_clear < corridor_emergency_clearance
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

	var move_world: Vector3 = planned_motion_world.normalized()
	var flat_move: Vector3 = move_world
	flat_move.y = 0.0

	var blocked_forward: bool = lidar_enabled and lidar_center_latest < no_forward_dist

	var planner_needs_corridor: bool = (
		corridor_locked or
		abs(planned_motion_local.x) > 0.18 or
		planned_motion_local.y > 0.10 or
		-planned_motion_local.z < 0.72
	)

	var can_point_directly_at_goal: bool = (
		settling and
		not blocked_forward and
		not avoid_active and
		not planner_needs_corridor
	)

	if can_point_directly_at_goal and to_target_flat.length() > 0.001:
		var settle_dir: Vector3 = to_target_flat.normalized()
		var desired_yaw: float = atan2(-settle_dir.x, -settle_dir.z)
		rotation.y = lerp_angle(rotation.y, desired_yaw, delta * settle_yaw_speed)

		var speed_scale_settle: float = clamp(dist / max(settle_radius, 0.001), 0.0, 1.0)
		speed_scale_settle = pow(speed_scale_settle, 0.7)

		var commanded_settle: float = lerp(0.02, cruise_tilt, speed_scale_settle)
		target_pitch = -commanded_settle * settle_pitch_scale
		target_roll = lerpf(target_roll, 0.0, delta * 4.0)
		return

	if flat_move.length() > 0.001:
		flat_move = flat_move.normalized()
		yaw_toward_goal(flat_move, delta)

	var speed_scale: float = clamp(dist / arrive_radius, 0.0, 1.0)
	speed_scale = pow(speed_scale, 0.35)

	var commanded: float = lerp(cruise_tilt, max_forward_tilt, speed_scale)
	if settling:
		commanded *= settle_pitch_scale

	var forward_keep: float = clamp(-planned_motion_local.z, 0.18 if settling else 0.35, 1.0)
	var side_amount: float = clamp(planned_motion_local.x, -1.0, 1.0)
	var up_amount: float = clamp(planned_motion_local.y, 0.0, 1.0)

	target_pitch = -commanded * forward_keep
	target_roll = side_amount * max_side_tilt * (0.45 if settling else 0.8)

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

	var to_goal: Vector3 = target_position - global_position
	to_goal.y = 0.0

	var v: Vector3 = linear_velocity
	v.y = 0.0

	var t: float = 1.0 - clamp(dist / arrive_radius, 0.0, 1.0)
	t = pow(t, 1.6)

	var brake_gain: float = brake_strength
	if dist < settle_radius:
		brake_gain *= 2.2

	var brake_force: Vector3 = -v * brake_gain * t

	# Extra anti-orbit damping near the goal.
	if to_goal.length() > 0.001:
		var radial_dir: Vector3 = to_goal.normalized()
		var radial_speed: float = v.dot(radial_dir)
		var tangential_v: Vector3 = v - radial_dir * radial_speed

		brake_force += -tangential_v * brake_gain * t * 1.4

		# If we are moving away from the goal near the end, damp that too.
		if dist < settle_radius and radial_speed < 0.0:
			brake_force += -radial_dir * radial_speed * brake_gain * 0.6

	apply_central_force(brake_force * mass)
	

func get_camera_feed() -> Texture2D:
	if display_viewport == null:
		return null
	return display_viewport.get_texture()

func get_planner_feed() -> Texture2D:
	if planner_viewport == null:
		return null
	return planner_viewport.get_texture()

func is_camera_enabled() -> bool:
	return display_camera_enabled

func is_planner_vision_enabled() -> bool:
	return planner_vision_enabled

func set_camera_enabled(enabled: bool) -> void:
	display_camera_enabled = enabled

	if display_camera != null:
		display_camera.current = enabled

	if display_viewport != null:
		display_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if enabled else SubViewport.UPDATE_DISABLED

func set_planner_vision_enabled(enabled: bool) -> void:
	planner_vision_enabled = enabled

	if planner_camera != null:
		planner_camera.current = enabled

	if planner_viewport != null:
		planner_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if enabled else SubViewport.UPDATE_DISABLED
	
func get_debug_world_points() -> Dictionary:
	var origin := global_position
	var goal_dir := (target_position - global_position).normalized()

	return {
		"origin": origin,
		"goal_end": origin + goal_dir * 4.0,
		"plan_end": origin + planned_motion_world.normalized() * 4.0,
		"vision_end": origin + (transform.basis * vision_corridor_local).normalized() * 4.0,
		"avoid_end": origin + transform.basis.x * avoid_yaw_dir * 2.5
	}
	
func get_vision_viewport_size() -> Vector2:
	if display_viewport == null:
		return Vector2.ONE
	return display_viewport.size

func get_planner_viewport_size() -> Vector2:
	if planner_viewport == null:
		return Vector2.ONE
	return planner_viewport.size

func get_vision_corridor_rect_px() -> Rect2:
	return vision_corridor_rect_px
