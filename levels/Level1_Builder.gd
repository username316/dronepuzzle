@tool 
extends Level

# LEVEL 1: THE PROVING GROUNDS
# Professional Version - Safety Updated to fix Cyclic and Tree errors

@export var refresh_level: bool = false:
	set(val):
		if is_inside_tree():
			# Use call_deferred to wait for a safe frame
			build_level.call_deferred()

func _ready():
	super._ready()
	# SAFETY GATE: Only run if we are actually in the scene tree
	if not is_inside_tree():
		return
		
	# Wait until the node is fully ready and wait one extra frame for parent
	if not is_node_ready():
		await ready
	
	await get_tree().process_frame
	
	# Build the level on the first safe frame
	build_level.call_deferred()

func build_level():
	# 1. Cleanup old nodes safely
	var old = get_node_or_null("LevelGeometry")
	if old:
		old.name = "DeleteMe" # Rename to avoid name conflicts
		old.free()
		
	# 2. Create the container
	var level_root = Node3D.new()
	level_root.name = "LevelGeometry"
	add_child(level_root)
	
	# 3. Build Layout
	_build_layout(level_root)
	
	# 4. Position the Drone SAFELY
	_position_drone_safely()

func _position_drone_safely():
	# Use find_child to look through the inherited tree
	var drone = find_child("Drone", true, false)
	
	# Only set position if drone is valid and in the world
	if drone and drone.is_inside_tree():
		drone.global_position = Vector3(0, 2, 15)
		print("Level 1: Drone positioned at Start Pad.")
	else:
		# If it's not ready, don't throw an error, just try once more shortly
		get_tree().create_timer(0.1).timeout.connect(
			func(): 
				if drone and drone.is_inside_tree(): 
					drone.global_position = Vector3(0, 2, 15)
		)

func _build_layout(parent: Node3D):
	# FLOOR
	var floor_obj = CSGBox3D.new()
	floor_obj.use_collision = true
	floor_obj.size = Vector3(60, 0.5, 60)
	floor_obj.position.y = -0.2
	floor_obj.material = _get_mat(Color(0.1, 0.1, 0.1)) 
	parent.add_child(floor_obj)
	
	# THE GATE
	var wall = CSGBox3D.new()
	wall.use_collision = true
	wall.size = Vector3(30, 15, 1)
	wall.position = Vector3(0, 7.5, 0)
	wall.material = _get_mat(Color(0.9, 0.4, 0.1)) # Orange
	
	var hole = CSGBox3D.new()
	hole.operation = CSGShape3D.OPERATION_SUBTRACTION
	hole.size = Vector3(10, 8, 4)
	wall.add_child(hole)
	parent.add_child(wall)

	# PADS
	parent.add_child(_create_pad(Vector3(0, 0.1, 15), Color.GREEN))  # Start
	parent.add_child(_create_pad(Vector3(0, 0.1, -20), Color.RED))   # Finish

func _get_mat(color: Color) -> StandardMaterial3D:
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.5
	return mat

func _create_pad(pos: Vector3, color: Color) -> CSGBox3D:
	var p = CSGBox3D.new()
	p.use_collision = true
	p.size = Vector3(5, 0.2, 5)
	p.position = pos
	p.material = _get_mat(color)
	return p
