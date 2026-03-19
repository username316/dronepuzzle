@tool 
extends Level

# LEVEL 3: THE SLALOM RUN
# Focus: High-speed lateral agility and obstacle avoidance.

@export var refresh_level: bool = false:
	set(val):
		if is_inside_tree():
			build_level.call_deferred()

func _ready():
	super._ready()
	
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
		drone.global_position = Vector3(0, 2, 25) # Start at one end of the long course
		print("Level 3: Drone positioned at Start Pad.")
	else:
		get_tree().create_timer(0.1).timeout.connect(
			func(): 
				if drone and drone.is_inside_tree(): 
					drone.global_position = Vector3(0, 2, 25)
		)

func _build_layout(parent: Node3D):
	# 1. THE LONG RUNWAY
	var floor_obj = CSGBox3D.new()
	floor_obj.use_collision = true
	floor_obj.size = Vector3(40, 1, 80)
	floor_obj.material = _get_mat(Color(0.1, 0.1, 0.1))
	parent.add_child(floor_obj)
	
	# Start and Finish Pads
	parent.add_child(_create_pad(Vector3(0, 0.6, 30), Color.GREEN))
	parent.add_child(_create_pad(Vector3(0, 0.6, -30), Color.RED))

	# 2. THE STAGGERED PILLARS (The Slalom)
	var pillar_positions = [
		Vector3(-8, 5, 15),
		Vector3(8, 5, 5),
		Vector3(-8, 5, -5),
		Vector3(8, 5, -15)
	]
	
	for pos in pillar_positions:
		var pillar = CSGCylinder3D.new()
		pillar.use_collision = true
		pillar.radius = 2.0
		pillar.height = 10.0
		pillar.position = pos
		pillar.material = _get_mat(Color(0.8, 0.2, 0.2)) # Industrial Red
		parent.add_child(pillar)

	# 3. THE HORIZONTAL SLIT GATES
	# Gate 1: Low slit
	parent.add_child(_create_wall_with_slit(parent, -22, 3))
	# Gate 2: High slit
	parent.add_child(_create_wall_with_slit(parent, -28, 7))

# --- Helpers ---

func _get_mat(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.4
	return mat

func _create_pad(pos: Vector3, color: Color) -> CSGBox3D:
	var p = CSGBox3D.new()
	p.use_collision = true
	p.size = Vector3(5, 0.2, 5)
	p.position = pos
	p.material = _get_mat(color)
	return p

func _create_wall_with_slit(parent: Node3D, z_pos: float, slit_y: float):
	var wall = CSGBox3D.new()
	wall.use_collision = true
	wall.size = Vector3(40, 15, 1)
	wall.position = Vector3(0, 7.5, z_pos)
	wall.material = _get_mat(Color(0.4, 0.4, 0.4))
	
	var hole = CSGBox3D.new()
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	hole.size = Vector3(15, 4, 4)
	hole.position = Vector3(0, slit_y - 7.5, 0)
	wall.add_child(hole)
	return wall
