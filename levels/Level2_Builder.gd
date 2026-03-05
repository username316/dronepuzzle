@tool 
extends Node3D

# LEVEL 2: THE VENTILATION SHAFTS
# Focus: Vertical navigation and staggered flight paths.

@export var refresh_level: bool = false:
	set(val):
		if is_inside_tree():
			build_level.call_deferred()

func _ready():
	if not is_inside_tree():
		return
	if not is_node_ready():
		await ready
	
	await get_tree().process_frame
	build_level.call_deferred()

func build_level():
	var old = get_node_or_null("LevelGeometry")
	if old:
		old.name = "DeleteMe"
		old.free()
		
	var level_root = Node3D.new()
	level_root.name = "LevelGeometry"
	add_child(level_root)
	
	_build_layout(level_root)
	_position_drone_safely()

func _position_drone_safely():
	var drone = find_child("Drone", true, false)
	if drone and drone.is_inside_tree():
		drone.global_position = Vector3(6, 2, 6) # Start position for Level 2
		print("Level 2: Drone positioned at Start Pad.")
	else:
		get_tree().create_timer(0.1).timeout.connect(
			func(): 
				if drone and drone.is_inside_tree(): 
					drone.global_position = Vector3(6, 2, 6)
		)

func _build_layout(parent: Node3D):
	# 1. BASE FLOOR & START
	parent.add_child(_create_floor("BaseFloor", Vector3(0, 0, 0), Vector3(20, 1, 20)))
	parent.add_child(_create_pad(Vector3(6, 0.6, 6), Color.GREEN))

	# 2. THE STAGGERED CLIMB (Floors with holes at different spots)
	# Floor 1 at Y=5, Hole at (-6, -6)
	parent.add_child(_create_floor_with_hole("Floor_Low", Vector3(0, 5, 0), Vector3(-6, 0, -6)))
	
	# Floor 2 at Y=10, Hole at (-6, 6)
	parent.add_child(_create_floor_with_hole("Floor_Mid", Vector3(0, 10, 0), Vector3(-6, 0, 6)))
	
	# Floor 3 at Y=15, Hole at (6, 6)
	parent.add_child(_create_floor_with_hole("Floor_High", Vector3(0, 15, 0), Vector3(6, 0, 6)))

	# 3. STATIC FAN OBSTACLES (The "Blades")
	var fan_hub = CSGCombiner3D.new()
	fan_hub.name = "FanObstacles"
	fan_hub.position = Vector3(0, 12, 0)
	for i in range(4):
		var blade = CSGBox3D.new()
		blade.size = Vector3(14, 0.2, 2)
		blade.rotation_degrees.y = i * 45
		blade.material = _get_mat(Color(0.3, 0.3, 0.4))
		fan_hub.add_child(blade)
	parent.add_child(fan_hub)

	# 4. THE ROOFTOP LANDING
	parent.add_child(_create_floor("Roof", Vector3(0, 20, 0), Vector3(10, 1, 10)))
	parent.add_child(_create_pad(Vector3(0, 20.6, 0), Color.RED))

# --- Helpers ---

func _get_mat(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.5
	return mat

func _create_floor(n, pos, sz):
	var f = CSGBox3D.new()
	f.name = n
	f.use_collision = true
	f.size = sz
	f.position = pos
	f.material = _get_mat(Color(0.15, 0.15, 0.18))
	return f

func _create_floor_with_hole(n, pos, hole_pos):
	var f = CSGBox3D.new()
	f.name = n
	f.use_collision = true
	f.size = Vector3(20, 1, 20)
	f.position = pos
	f.material = _get_mat(Color(0.15, 0.15, 0.18))
	var hole = CSGBox3D.new()
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	hole.size = Vector3(6, 2, 6)
	hole.position = hole_pos
	f.add_child(hole)
	return f

func _create_pad(pos: Vector3, color: Color) -> CSGBox3D:
	var p = CSGBox3D.new()
	p.use_collision = true
	p.size = Vector3(4, 0.2, 4)
	p.position = pos
	p.material = _get_mat(color)
	return p
