extends Node3D
class_name LidarSensor3D

@export var enabled: bool = true
@export var collision_mask: int = 1

@export var min_range: float = 0.2
@export var max_range: float = 20.0

@export var horizontal_fov_deg: float = 270.0
@export var rays_per_scan: int = 360
@export var scans_per_second: float = 10.0

# Realism
@export var noise_std: float = 0.02
@export var dropout_rate: float = 0.01
@export var jitter_deg: float = 0.15
@export var rolling_scan: bool = true

# Debug drawing
@export var debug_draw_enabled: bool = true
@export var debug_draw_every_n_rays: int = 6
@export var debug_color: Color = Color(0.0, 1.0, 0.0, 1.0)

# Outputs
var ranges: PackedFloat32Array
var hit_points: Array[Vector3] = []

# Internal
var _angle0: float
var _angle_step: float
var _rays_done_this_scan: int = 0
var _rng := RandomNumberGenerator.new()

# Debug mesh
var _debug_mesh_instance: MeshInstance3D
var _debug_immediate_mesh: ImmediateMesh
var _debug_material: ORMMaterial3D

func _ready() -> void:
	_rng.randomize()
	_configure()
	_setup_debug_draw()

func _configure() -> void:
	ranges = PackedFloat32Array()
	ranges.resize(rays_per_scan)

	hit_points.clear()
	hit_points.resize(rays_per_scan)

	for i in range(rays_per_scan):
		ranges[i] = max_range
		hit_points[i] = Vector3(0.0, 0.0, -max_range)

	_angle0 = -deg_to_rad(horizontal_fov_deg) * 0.5
	_angle_step = deg_to_rad(horizontal_fov_deg) / float(max(rays_per_scan - 1, 1))

func set_enabled(v: bool) -> void:
	enabled = v
	if not enabled:
		for i in range(ranges.size()):
			ranges[i] = max_range
			hit_points[i] = Vector3(0.0, 0.0, -max_range)

func _physics_process(delta: float) -> void:
	if not enabled:
		if debug_draw_enabled:
			_draw_debug_rays()
		return

	if ranges.size() != rays_per_scan:
		_configure()

	var world := get_world_3d()
	if world == null:
		return
	var space_state := world.direct_space_state

	var rays_per_second: float = float(rays_per_scan) * scans_per_second
	var rays_this_frame: int = int(ceil(rays_per_second * delta))
	rays_this_frame = clamp(rays_this_frame, 1, rays_per_scan)

	if not rolling_scan:
		rays_this_frame = rays_per_scan

	for _k in range(rays_this_frame):
		var i: int = _rays_done_this_scan

		var ang: float = _angle0 + _angle_step * float(i)
		ang += deg_to_rad(_rng.randf_range(-jitter_deg, jitter_deg))

		# Scan in local XZ plane
		var dir_local := Vector3(sin(ang), 0.0, -cos(ang)).normalized()
		var dir_world := (global_transform.basis * dir_local).normalized()

		var from: Vector3 = global_position
		var to: Vector3 = from + dir_world * max_range

		var query := PhysicsRayQueryParameters3D.create(from, to)
		query.collision_mask = collision_mask
		query.collide_with_bodies = true
		query.collide_with_areas = false

		# Exclude parent drone body
		if get_parent() != null:
			query.exclude = [get_parent()]

		var hit: Dictionary = space_state.intersect_ray(query)

		var d: float = max_range
		var hit_pos: Vector3 = to

		if _rng.randf() < dropout_rate:
			d = max_range
			hit_pos = to
		elif not hit.is_empty():
			d = from.distance_to(hit.position)
			d = clamp(d, min_range, max_range)
			d += _rng.randf_range(-noise_std, noise_std)
			d = clamp(d, min_range, max_range)
			hit_pos = from + dir_world * d
		else:
			hit_pos = to

		ranges[i] = d
		hit_points[i] = to_local(hit_pos)

		_rays_done_this_scan += 1
		if _rays_done_this_scan >= rays_per_scan:
			_rays_done_this_scan = 0

	if debug_draw_enabled:
		_draw_debug_rays()

func get_sector_min(left_deg: float, right_deg: float) -> float:
	if ranges.is_empty():
		return max_range

	var fov: float = horizontal_fov_deg
	var a0: float = -fov * 0.5
	var step: float = fov / float(max(rays_per_scan - 1, 1))

	var i0: int = int(round((left_deg - a0) / step))
	var i1: int = int(round((right_deg - a0) / step))

	var lo: int = clamp(min(i0, i1), 0, rays_per_scan - 1)
	var hi: int = clamp(max(i0, i1), 0, rays_per_scan - 1)

	var m: float = max_range
	for i in range(lo, hi + 1):
		m = min(m, ranges[i])
	return m

func _setup_debug_draw() -> void:
	_debug_immediate_mesh = ImmediateMesh.new()
	_debug_mesh_instance = MeshInstance3D.new()
	_debug_mesh_instance.mesh = _debug_immediate_mesh

	_debug_material = ORMMaterial3D.new()
	_debug_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_debug_material.albedo_color = debug_color

	_debug_mesh_instance.material_override = _debug_material
	add_child(_debug_mesh_instance)

func _draw_debug_rays() -> void:
	if _debug_immediate_mesh == null:
		return

	_debug_material.albedo_color = debug_color
	_debug_immediate_mesh.clear_surfaces()
	_debug_immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, _debug_material)

	var step: int = max(1, debug_draw_every_n_rays)

	for i in range(0, rays_per_scan, step):
		_debug_immediate_mesh.surface_add_vertex(Vector3.ZERO)
		_debug_immediate_mesh.surface_add_vertex(hit_points[i])

	_debug_immediate_mesh.surface_end()
	
func get_sector_percentile(left_deg: float, right_deg: float, percentile: float = 0.25) -> float:
	if ranges.is_empty():
		return max_range

	var fov: float = horizontal_fov_deg
	var a0: float = -fov * 0.5
	var step: float = fov / float(max(rays_per_scan - 1, 1))

	var i0: int = int(round((left_deg - a0) / step))
	var i1: int = int(round((right_deg - a0) / step))

	var lo: int = clamp(min(i0, i1), 0, rays_per_scan - 1)
	var hi: int = clamp(max(i0, i1), 0, rays_per_scan - 1)

	var vals: Array[float] = []
	for i in range(lo, hi + 1):
		vals.append(ranges[i])

	vals.sort()

	var idx: int = clamp(int(floor((vals.size() - 1) * percentile)), 0, vals.size() - 1)
	return vals[idx]
