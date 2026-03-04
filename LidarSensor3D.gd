extends Node3D
class_name LidarSensor3D

@export var enabled: bool = true
@export var collision_mask: int = 1

@export var min_range: float = 0.2
@export var max_range: float = 20.0

@export var horizontal_fov_deg: float = 270.0   # common indoor lidar: 270°
@export var rays_per_scan: int = 360            # angular resolution
@export var scans_per_second: float = 10.0      # scan rate (Hz)

# Realism knobs
@export var noise_std: float = 0.02             # meters (Gaussian-ish approximation)
@export var dropout_rate: float = 0.01          # 0..1 chance a ray returns "no hit"
@export var jitter_deg: float = 0.15            # small angular jitter

# If true, we sweep rays across time instead of doing all rays instantly
@export var rolling_scan: bool = true

# Outputs (updated continuously)
var ranges: PackedFloat32Array

# internal
var _angle0: float
var _angle_step: float
var _rays_done_this_scan: int = 0
var _scan_time_accum: float = 0.0
var _rng := RandomNumberGenerator.new()

func _ready():
	_rng.randomize()
	_configure()

func _configure():
	ranges = PackedFloat32Array()
	ranges.resize(rays_per_scan)
	for i in range(rays_per_scan):
		ranges[i] = max_range

	_angle0 = -deg_to_rad(horizontal_fov_deg) * 0.5
	_angle_step = deg_to_rad(horizontal_fov_deg) / float(max(rays_per_scan - 1, 1))

func set_enabled(v: bool) -> void:
	enabled = v
	if not enabled:
		# Reset to "no obstacles"
		for i in range(ranges.size()):
			ranges[i] = max_range

func _physics_process(delta: float) -> void:
	if not enabled:
		return

	if ranges.size() != rays_per_scan:
		_configure()

	var world := get_world_3d()
	if world == null:
		return
	var space_state := world.direct_space_state

	# How many rays should we do this frame?
	var rays_per_second = float(rays_per_scan) * scans_per_second
	var rays_this_frame = int(ceil(rays_per_second * delta))
	rays_this_frame = clamp(rays_this_frame, 1, rays_per_scan)

	if not rolling_scan:
		rays_this_frame = rays_per_scan

	for k in range(rays_this_frame):
		var i := _rays_done_this_scan

		# Angle (with jitter)
		var ang = _angle0 + _angle_step * float(i)
		ang += deg_to_rad(_rng.randf_range(-jitter_deg, jitter_deg))

		# Direction in local space (LiDAR scans in its local XZ plane)
		var dir_local = Vector3(sin(ang), 0.0, -cos(ang))
		var from = global_position
		var to = from + (global_transform.basis * dir_local).normalized() * max_range

		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = collision_mask
		# exclude the whole drone by excluding the parent body if you want:
		if get_parent() != null:
			query.exclude = [get_parent()]

		var hit = space_state.intersect_ray(query)

		var d = max_range
		if _rng.randf() < dropout_rate:
			d = max_range
		elif hit:
			d = from.distance_to(hit.position)
			d = clamp(d, min_range, max_range)

			# Add small distance noise (uniform approximation)
			d += _rng.randf_range(-noise_std, noise_std)
			d = clamp(d, min_range, max_range)

		ranges[i] = d

		_rays_done_this_scan += 1
		if _rays_done_this_scan >= rays_per_scan:
			_rays_done_this_scan = 0
			# (a new scan begins)

func get_sector_min(left_deg: float, right_deg: float) -> float:
	# Degrees are relative to LiDAR forward (-Z): negative = left, positive = right
	# Example: center sector [-10, +10]
	if ranges.is_empty():
		return max_range

	var fov = horizontal_fov_deg
	var a0 = -fov * 0.5
	var step = fov / float(max(rays_per_scan - 1, 1))

	var i0 = int(round((left_deg - a0) / step))
	var i1 = int(round((right_deg - a0) / step))
	i0 = clamp(min(i0, i1), 0, rays_per_scan - 1)
	i1 = clamp(max(i0, i1), 0, rays_per_scan - 1)

	var m = max_range
	for i in range(i0, i1 + 1):
		m = min(m, ranges[i])
	return m
