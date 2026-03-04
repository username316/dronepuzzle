extends RigidBody3D

@export var max_tilt := 0.4
@export var tilt_speed := 3.0
@export var min_thrust := 0.0
@export var max_thrust := 60.0

@export var hover_height := 3.0
@export var height_strength := 15.0
@export var height_damping := 8.0

@export var target_position: Vector3
@export var arrive_radius := 8.0
@export var stop_radius := 2.0

@export var max_forward_tilt := 0.25
@export var max_side_tilt := 0.25
@export var cruise_tilt := 0.12

@export var yaw_speed := 3.0

# Vision / avoidance (camera-only)
@export var vision_interval := 0.05      # 20 Hz is much better than 10 Hz
@export var avoid_yaw_speed := 3.5
@export var vision_enabled := true

# Flow + edges thresholds (tune in Inspector)
@export var avoid_trigger_flow := 0.06
@export var avoid_clear_flow := 0.03
@export var avoid_trigger_edge := 0.10
@export var avoid_clear_edge := 0.07

@export var edge_step := 2               # 1 = more accurate slower, 2 = good
@export var flow_step := 3               # 2 = more accurate slower, 3 = good

# Braking near goal
@export var brake_strength := 8.0

# Position hold (inside stop bubble)
@export var hold_kp := 10.0
@export var hold_kd := 6.0
@export var max_hold_force := 40.0
@export var reached_level_speed := 12.0
@export var reached_stop_speed := 12.0

@onready var vision_viewport: SubViewport = get_node("VisionViewport")

var vision_timer := 0.0
var prev_img: Image = null

var target_pitch := 0.0
var target_roll := 0.0
var target_thrust := 0.0

var avoid_active := false
var avoid_yaw_dir := 0.0      # -1 = left, +1 = right
var avoid_strength := 0.0     # 0..1

func _physics_process(delta: float) -> void:
	# --- Altitude hold ---
	var height_error = hover_height - global_position.y
	var vertical_velocity = linear_velocity.y
	var height_correction = height_error * height_strength - vertical_velocity * height_damping
	target_thrust = clamp(9.8 * mass + height_correction, min_thrust, max_thrust)

	# --- Goal distance (horizontal) ---
	var to_target = target_position - global_position
	to_target.y = 0.0
	var dist = to_target.length()
	var reached = dist <= stop_radius

	if reached:
		# Stop commanding motion
		target_pitch = 0.0
		target_roll  = 0.0

		# Level quickly so lift doesn't push sideways
		rotation.x = lerp(rotation.x, 0.0, delta * reached_level_speed)
		rotation.z = lerp(rotation.z, 0.0, delta * reached_level_speed)

		# Cancel horizontal motion
		linear_velocity.x = move_toward(linear_velocity.x, 0.0, reached_stop_speed * delta)
		linear_velocity.z = move_toward(linear_velocity.z, 0.0, reached_stop_speed * delta)
		angular_velocity = angular_velocity.lerp(Vector3.ZERO, delta * 8.0)

		# Position hold (horizontal PD)
		var err = target_position - global_position
		err.y = 0.0

		var vel = linear_velocity
		vel.y = 0.0

		var hold_force = err * hold_kp - vel * hold_kd
		if hold_force.length() > max_hold_force:
			hold_force = hold_force.normalized() * max_hold_force
		apply_central_force(hold_force * mass)

	else:
		# Vision update
		if vision_enabled:
			vision_timer += delta
			if vision_timer >= vision_interval:
				vision_timer = 0.0
				process_vision()
		else:
			# ensure avoidance is disabled when camera is off
			avoid_active = false
			avoid_yaw_dir = 0.0
			avoid_strength = 0.0

		# Steering (goal + camera avoidance)
		steer_toward_goal(dist, delta)

		# Braking as we approach goal (helps stop overshoot)
		apply_braking(dist)

		# Smooth tilt control
		rotation.x = lerp(rotation.x, target_pitch, delta * tilt_speed)
		rotation.z = lerp(rotation.z, target_roll,  delta * tilt_speed)

	# Apply thrust in drone-up direction
	var lift = transform.basis.y * target_thrust
	apply_central_force(lift)

# -----------------------
# Camera-only vision
# -----------------------
func process_vision() -> void:
	var img := vision_viewport.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)

	if prev_img == null:
		prev_img = img.duplicate()
		avoid_active = false
		avoid_yaw_dir = 0.0
		avoid_strength = 0.0
		return

	var w := img.get_width()
	var h := img.get_height()

	# Optical flow proxy (frame difference) in 3 bands
	var left_flow := flow_band(img, prev_img,
		int(w * 0.10), int(w * 0.35),
		int(h * 0.35), int(h * 0.65),
		flow_step
	)

	var center_flow := flow_band(img, prev_img,
		int(w * 0.40), int(w * 0.60),
		int(h * 0.35), int(h * 0.65),
		flow_step
	)

	var right_flow := flow_band(img, prev_img,
		int(w * 0.65), int(w * 0.90),
		int(h * 0.35), int(h * 0.65),
		flow_step
	)

	# Edge density in center (helps on low-texture walls)
	var edge_c := edge_density(img,
		int(w * 0.40), int(w * 0.60),
		int(h * 0.35), int(h * 0.65),
		edge_step
	)

	# Update prev
	prev_img = img.duplicate()

	# Trigger/clear with hysteresis latch
	var trigger: bool = (center_flow > avoid_trigger_flow) or (edge_c > avoid_trigger_edge)
	var clear: bool = (center_flow < avoid_clear_flow) and (edge_c < avoid_clear_edge)
	
	if avoid_active:
		if clear:
			avoid_active = false
	else:
		if trigger:
			avoid_active = true

	if avoid_active:
		# Choose calmer side (lower flow) to turn into
		avoid_yaw_dir = -1.0 if left_flow < right_flow else 1.0

		# Strength from strongest cue (flow or edges)
		var s_flow: float = clamp((center_flow - avoid_trigger_flow) / max(avoid_trigger_flow, 0.001), 0.0, 1.0)
		var s_edge: float = clamp((edge_c - avoid_trigger_edge) / max(avoid_trigger_edge, 0.001), 0.0, 1.0)
		avoid_strength = float(clamp(max(s_flow, s_edge), 0.0, 1.0))
	else:
		avoid_yaw_dir = 0.0
		avoid_strength = 0.0

	# Debug if you need it:
	# if Engine.get_physics_frames() % 10 == 0:
	# 	print("flow L/C/R:", left_flow, center_flow, right_flow, " edgeC:", edge_c,
	# 		" avoid:", avoid_active, " dir:", avoid_yaw_dir, " str:", avoid_strength)

func flow_band(img: Image, prev: Image, x0: int, x1: int, y0: int, y1: int, step: int) -> float:
	var sum := 0.0
	var count := 0
	for y in range(y0, y1, step):
		for x in range(x0, x1, step):
			var a: Color = img.get_pixel(x, y)
			var b: Color = prev.get_pixel(x, y)

			var la = a.r * 0.299 + a.g * 0.587 + a.b * 0.114
			var lb = b.r * 0.299 + b.g * 0.587 + b.b * 0.114
			sum += abs(la - lb)
			count += 1
	return sum / max(1, count)

func edge_density(img: Image, x0: int, x1: int, y0: int, y1: int, step: int) -> float:
	var sum := 0.0
	var count := 0
	for y in range(y0, y1 - step, step):
		for x in range(x0, x1 - step, step):
			var c: Color = img.get_pixel(x, y)
			var cx: Color = img.get_pixel(x + step, y)
			var cy: Color = img.get_pixel(x, y + step)

			var l  = c.r  * 0.299 + c.g  * 0.587 + c.b  * 0.114
			var lx = cx.r * 0.299 + cx.g * 0.587 + cx.b * 0.114
			var ly = cy.r * 0.299 + cy.g * 0.587 + cy.b * 0.114

			sum += abs(l - lx) + abs(l - ly)
			count += 1
	return sum / max(1, count)

# -----------------------
# Steering / control
# -----------------------
func yaw_toward_goal(goal_dir: Vector3, delta: float) -> void:
	var desired_yaw = atan2(-goal_dir.x, -goal_dir.z)
	rotation.y = lerp_angle(rotation.y, desired_yaw, delta * yaw_speed)

func steer_toward_goal(dist: float, delta: float) -> void:
	if dist <= stop_radius:
		target_pitch = 0.0
		target_roll = 0.0
		return

	var to_target = target_position - global_position
	to_target.y = 0.0
	var goal_dir = to_target.normalized()

	# --- Camera avoidance overrides navigation ---
	if avoid_active:
		rotation.y += avoid_yaw_dir * avoid_yaw_speed * delta

		# Stop pushing forward while avoiding
		target_pitch = 0.0

		# Bank a bit for realism
		target_roll = lerp(target_roll, avoid_yaw_dir * max_side_tilt, 0.7)
		return

	# --- Normal navigation ---
	yaw_toward_goal(goal_dir, delta)

	var speed_scale = clamp(dist / arrive_radius, 0.0, 1.0)
	speed_scale = pow(speed_scale, 0.35) # slows down later

	var commanded = lerp(cruise_tilt, max_forward_tilt, speed_scale)
	target_pitch = -commanded

	# Let roll settle back to 0 (avoid drifting)
	target_roll = lerp(target_roll, 0.0, 0.2)

func apply_braking(dist: float) -> void:
	if dist > arrive_radius:
		return
	var v = linear_velocity
	v.y = 0.0
	var t = 1.0 - clamp(dist / arrive_radius, 0.0, 1.0)
	t = pow(t, 2.0) # braking ramps in later
	apply_central_force(-v * brake_strength * t * mass)
