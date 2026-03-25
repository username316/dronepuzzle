@tool
extends Node3D

@export var tree_scene: PackedScene
@export var tree_count: int = 200
@export var area_size: Vector2 = Vector2(100, 100)
@export var random_seed: int = 12345
@export var align_to_ground: bool = true
@export var raycast_height: float = 200.0
@export var collision_mask: int = 1
@export var min_scale: float = 0.9
@export var max_scale: float = 1.2

@export_tool_button("Generate Trees", "Callable") var generate_action: Callable = generate_trees
@export_tool_button("Clear Trees", "Callable") var clear_action: Callable = clear_trees

func _get_container() -> Node3D:
	var container := get_node_or_null("GeneratedTrees") as Node3D
	if container == null:
		container = Node3D.new()
		container.name = "GeneratedTrees"
		add_child(container)
		container.owner = get_tree().edited_scene_root
	return container

func generate_trees() -> void:
	if not Engine.is_editor_hint():
		return
	if tree_scene == null:
		push_warning("Assign tree_scene first.")
		return

	clear_trees()

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	var root := get_tree().edited_scene_root
	var container := _get_container()

	if root == null:
		push_warning("No edited scene root found.")
		return

	for i in range(tree_count):
		var tree := tree_scene.instantiate() as Node3D
		if tree == null:
			continue

		container.add_child(tree)
		tree.owner = root

		var x = rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z = rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		var pos := Vector3(x, 0.0, z)

		if align_to_ground:
			var from := global_position + Vector3(x, raycast_height, z)
			var to := global_position + Vector3(x, -raycast_height, z)

			var query := PhysicsRayQueryParameters3D.create(from, to)
			query.collision_mask = collision_mask

			var result := get_world_3d().direct_space_state.intersect_ray(query)
			if result:
				pos = container.to_local(result.position)
			else:
				tree.queue_free()
				continue

		tree.position = pos
		tree.rotation.y = rng.randf_range(0.0, TAU)

		var s := rng.randf_range(min_scale, max_scale)
		tree.scale = Vector3.ONE * s

func clear_trees() -> void:
	if not Engine.is_editor_hint():
		return

	var container := get_node_or_null("GeneratedTrees")
	if container == null:
		return

	for child in container.get_children():
		child.free()
