extends RigidBody3D

# -----------------------
# Flight / movement tuning
# -----------------------
@export var tilt_speed := 3.0
@export var min_thrust := 0.0
@export var max_thrust := 60.0

@export var hover_height := 3.0
@export var height_strength := 15.0
@export var height_damping := 8.0

@export var target: Area3D
var target_position: Vector3
@export var arrive_radius := 8.0
@export var stop_radius := 2.0

@export var max_forward_tilt := 0.25
@export var max_side_tilt := 0.25
@export var cruise_tilt := 0.12
@export var yaw_speed := 3.0

# Braking near goal
@export var brake_strength := 8.0

# Position hold (inside stop bubble)
@export var hold_kp := 10.0
@export var hold_kd := 6.0
@export var max_hold_force := 40.0
@export var reached_level_speed := 12.0
@export var reached_stop_speed := 12.0

# -----------------------
# Sensors toggles + fusion
# -----------------------
@export var vision_enabled := true
@export var lidar_enabled := true
@export var fusion_mode := "min" # "min" | "vision" | "lidar"

# -----------------------
# Vision (camera-only) params
# -----------------------
@export var vision_interval := 0.05
@export var avoid_yaw_speed := 2.2

@export var avoid_trigger_flow := 0.06
@export var avoid_clear_flow := 0.03
@export var avoid_trigger_edge := 0.10
@export var avoid_clear_edge := 0.07
@export var edge_step := 2
@export var flow_step := 3

# -----------------------
# LiDAR params
# -----------------------
@export var lidar_trigger_dist := 7.0
@export var lidar_clear_dist := 8.0
@export var lidar_min_avoid_time := 0.45
@export var lidar_dir_deadband := 0.35
@export var lidar_smooth := 0.20

# -----------------------
# Avoidance behavior tuning (important)
# -----------------------
@export var avoid_creep := 0.55          # how much forward remains during avoidance (0..1)
@export var avoid_stop_strength := 0.90  # if avoid_strength above this, stop forward
@export var avoid_bank := 0.7            # roll lerp during avoidance (0..1)
@export var avoid_force := 22.0          # horizontal push strength (tune 10..30)
@export var backoff_force := 18.0         # extra push backward when too close
@export var no_forward_dist := 2.5     # if C < this, do not command forward pitch
@export var brake_dist := 3.5          # if C < this, brake forward velocity
@export var reverse_dist := 0.9        # last resort reverse
@export var forward_brake_gain := 22.0 # how hard to brake forward speed

@onready var vision_viewport: SubViewport = get_node("VisionViewport")
@onready var lidar: LidarSensor3D = $Lidar

# --------------------------------------
# Escape / un-wedge behavior
#---------------------------------------
@export var emergency_dist := 1.4      # meters: if center this close, back off
@export var backoff_time := 0.35       # seconds
@export var backoff_tilt := 0.10       # positive = backwards in your scheme



# Timers
var vision_timer := 0.0
var prev_img: Image = null

# Controller outputs
var target_pitch := 0.0
var target_roll := 0.0
var target_thrust := 0.0

# Final fused avoidance output
var avoid_active := false
var avoid_yaw_dir := 0.0
var avoid_strength := 0.0

# Vision output
var vision_avoid_latch := false
var avoid_active_vision := false
var avoid_dir_vision := 0.0
var avoid_strength_vision := 0.0

# LiDAR output
var avoid_active_lidar := false
var avoid_dir_lidar := 0.0
var avoid_strength_lidar := 0.0
var lidar_center_latest: float = 20.0

# LiDAR smoothing + timer
var lidar_left_f: float = 0.0
var lidar_center_f: float = 0.0
var lidar_right_f: float = 0.0
var lidar_avoid_timer: float = 0.0

#Escape
var backoff_timer: float = 0.0

func _ready() -> void:
	target_position = target.global_position

func _physics_process(delta: float) -> void:
	# --- Altitude hold ---
	var height_error := hover_height - global_position.y
	var vertical_velocity := linear_velocity.y
	var height_correction := height_error * height_strength - vertical_velocity * height_damping
	target_thrust = clamp(9.8 * mass + height_correction, min_thrust, max_thrust)

	# --- Horizontal distance to goal ---
	var to_target := target_position - global_position
	to_target.y = 0.0
	var dist := to_target.length()
	var reached := dist <= stop_radius
	
	if lidar != null:
		lidar.global_rotation = Vector3(0.0, global_rotation.y, 0.0)

	if reached:
		_do_reached_hold(delta)
	else:
		# 1) Update sensors (each writes into its own output vars)
		_update_vision(delta)
		_update_lidar(delta)

		# 2) Fuse into final avoid_active/avoid_yaw_dir/avoid_strength
		fuse_avoidance(
			avoid_active_vision, avoid_dir_vision, avoid_strength_vision,
			avoid_active_lidar,  avoid_dir_lidar,  avoid_strength_lidar
		)

		# 3) Steering
		steer_toward_goal(dist, delta)
		
		# Apply physical avoidance force (makes it actually move away)
		if avoid_active:
			apply_avoidance_physics()
		
		# 4) Braking near goal
		apply_braking(dist)

		# 5) Smooth tilt control
		rotation.x = lerp(rotation.x, target_pitch, delta * tilt_speed)
		rotation.z = lerp(rotation.z, target_roll,  delta * tilt_speed)

	# Apply thrust (always)
	var lift := transform.basis.y * target_thrust
	apply_central_force(lift)

func apply_avoidance_physics() -> void:
	var right: Vector3 = transform.basis.x
	var forward: Vector3 = -transform.basis.z

	# Lateral slide away from obstacle
	var s: float = clamp(avoid_strength, 0.0, 1.0)
	var lateral: Vector3 = (right * avoid_yaw_dir) * (avoid_force * s) * mass
	lateral.y = 0.0

	# Forward braking when close (feels like a real controller)
	var c: float = lidar_center_latest
	var v: Vector3 = linear_velocity
	v.y = 0.0
	var fwd_speed: float = v.dot(forward) # + when moving forward

	var brake: Vector3 = Vector3.ZERO
	if lidar_enabled and c < brake_dist and fwd_speed > 0.0:
		var closeness: float = clamp((brake_dist - c) / max(brake_dist, 0.001), 0.0, 1.0)
		closeness = pow(closeness, 1.6)
		brake = -forward * fwd_speed * (forward_brake_gain * closeness) * mass

	# Last resort reverse only if EXTREMELY close
	var reverse: Vector3 = Vector3.ZERO
	if lidar_enabled and c < reverse_dist:
		var closeness2: float = clamp((reverse_dist - c) / max(reverse_dist, 0.001), 0.0, 1.0)
		closeness2 = pow(closeness2, 1.4)
		reverse = -forward * (backoff_force * 0.35 * closeness2) * mass

	brake.y = 0.0
	reverse.y = 0.0

	apply_central_force(lateral + brake + reverse)

func _do_reached_hold(delta: float) -> void:
	target_pitch = 0.0
	target_roll  = 0.0

	rotation.x = lerp(rotation.x, 0.0, delta * reached_level_speed)
	rotation.z = lerp(rotation.z, 0.0, delta * reached_level_speed)

	linear_velocity.x = move_toward(linear_velocity.x, 0.0, reached_stop_speed * delta)
	linear_velocity.z = move_toward(linear_velocity.z, 0.0, reached_stop_speed * delta)
	angular_velocity = angular_velocity.lerp(Vector3.ZERO, delta * 8.0)

	var err := target_position - global_position
	err.y = 0.0
	var vel := linear_velocity
	vel.y = 0.0

	var hold_force := err * hold_kp - vel * hold_kd
	if hold_force.length() > max_hold_force:
		hold_force = hold_force.normalized() * max_hold_force
	apply_central_force(hold_force * mass)

func _update_vision(delta: float) -> void:
	if not vision_enabled:
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0
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

# -----------------------
# Camera-only vision
# -----------------------
func process_vision() -> void:
	var img := vision_viewport.get_texture().get_image()
	img.convert(Image.FORMAT_RGBA8)

	if prev_img == null:
		prev_img = img.duplicate()
		vision_avoid_latch = false
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0
		return

	var w := img.get_width()
	var h := img.get_height()

	var left_flow := flow_band(img, prev_img, int(w * 0.10), int(w * 0.35), int(h * 0.35), int(h * 0.65), flow_step)
	var center_flow := flow_band(img, prev_img, int(w * 0.40), int(w * 0.60), int(h * 0.35), int(h * 0.65), flow_step)
	var right_flow := flow_band(img, prev_img, int(w * 0.65), int(w * 0.90), int(h * 0.35), int(h * 0.65), flow_step)

	var edge_c := edge_density(img, int(w * 0.40), int(w * 0.60), int(h * 0.35), int(h * 0.65), edge_step)

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
		var dir := (-1.0 if left_flow < right_flow else 1.0)

		var s_flow: float = clamp((center_flow - avoid_trigger_flow) / max(avoid_trigger_flow, 0.001), 0.0, 1.0)
		var s_edge: float = clamp((edge_c - avoid_trigger_edge) / max(avoid_trigger_edge, 0.001), 0.0, 1.0)
		var s := float(clamp(max(s_flow, s_edge), 0.0, 1.0))

		avoid_active_vision = true
		avoid_dir_vision = dir
		avoid_strength_vision = s
	else:
		avoid_active_vision = false
		avoid_dir_vision = 0.0
		avoid_strength_vision = 0.0

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
# LiDAR avoidance
# -----------------------
func lidar_avoidance_update() -> void:
	var left: float   = lidar.get_sector_min(-60.0, -20.0)
	var center: float = lidar.get_sector_min(-12.0, 12.0)
	var right: float  = lidar.get_sector_min(20.0, 60.0)

	# Smooth (low-pass)
	if lidar_left_f == 0.0:
		lidar_left_f = left
		lidar_center_f = center
		lidar_right_f = right
	else:
		lidar_left_f = lerp(lidar_left_f, left, lidar_smooth)
		lidar_center_f = lerp(lidar_center_f, center, lidar_smooth)
		lidar_right_f = lerp(lidar_right_f, right, lidar_smooth)

	left = lidar_left_f
	center = lidar_center_f
	right = lidar_right_f
	
	lidar_center_latest = center
	
	# DEBUG
	if Engine.get_physics_frames() % 10 == 0:
		print("L:", left, " C:", center, " R:", right, " avoid:", avoid_active_lidar)

	# Trigger avoidance
	if not avoid_active_lidar and center < lidar_trigger_dist:
		avoid_active_lidar = true
		lidar_avoid_timer = lidar_min_avoid_time

	# Countdown
	if lidar_avoid_timer > 0.0:
		lidar_avoid_timer -= get_physics_process_delta_time()

	# Clear only when timer expired AND clearly safe
	if avoid_active_lidar and lidar_avoid_timer <= 0.0 and center > lidar_clear_dist:
		avoid_active_lidar = false

	if avoid_active_lidar:
		# Strength first
		avoid_strength_lidar = clamp((lidar_trigger_dist - center) / max(lidar_trigger_dist, 0.001), 0.0, 1.0)

		# If both sides are very close, keep the previous direction (don't flip)
		if not (left < 1.5 and right < 1.5):
			var diff := left - right
			if abs(diff) > lidar_dir_deadband:
				avoid_dir_lidar = -1.0 if diff > 0.0 else 1.0
	else:
		avoid_strength_lidar = 0.0
		avoid_dir_lidar = 0.0

# -----------------------
# Fusion
# -----------------------
func fuse_avoidance(vision_a: bool, vision_dir: float, vision_s: float,
					lidar_a: bool, lidar_dir: float, lidar_s: float) -> void:
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

	# fusion_mode == "min"
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

	# Avoidance override (typed to avoid Variant inference)
	if avoid_active:
		var c: float = lidar_center_latest
		var yaw_scale: float = 1.0
		if lidar_enabled:
			# less yaw when very close -> less jitter, more sliding away
			yaw_scale = clamp((c - 0.8) / 2.2, 0.15, 1.0)

		rotation.y += avoid_yaw_dir * avoid_yaw_speed * yaw_scale * delta
		target_roll = lerp(target_roll, avoid_yaw_dir * max_side_tilt, 0.7)

		var a_strength: float = clamp(avoid_strength, 0.0, 1.0)

		# Default: do not push forward if we're within no_forward_dist
		if lidar_enabled and c < no_forward_dist:
			target_pitch = 0.0
		else:
			# Otherwise allow a little creep forward while turning
			var speed_scale: float = clamp(dist / arrive_radius, 0.0, 1.0)
			speed_scale = pow(speed_scale, 0.35)
			var commanded: float = lerp(cruise_tilt, max_forward_tilt, speed_scale)

			var slow: float = lerp(1.0, 0.35, a_strength)
			target_pitch = -commanded * slow

		# Extra braking / last resort reverse handled by forces (feels more physical)
		return
	
	

	# Normal navigation
	yaw_toward_goal(goal_dir, delta)

	var speed_scale: float = clamp(dist / arrive_radius, 0.0, 1.0)
	speed_scale = pow(speed_scale, 0.35)
	var commanded: float = lerp(cruise_tilt, max_forward_tilt, speed_scale)
	target_pitch = -commanded

	target_roll = lerp(target_roll, 0.0, 0.2)

func apply_braking(dist: float) -> void:
	if dist > arrive_radius:
		return
	var v = linear_velocity
	v.y = 0.0
	var t = 1.0 - clamp(dist / arrive_radius, 0.0, 1.0)
	t = pow(t, 2.0)
	apply_central_force(-v * brake_strength * t * mass)
