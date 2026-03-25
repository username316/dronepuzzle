@tool
extends MultiMeshInstance3D

@export var tree_mesh: Mesh
@export var tree_count: int = 500
@export var area_size: Vector2 = Vector2(100, 100)
@export var random_seed: int = 12345
@export var min_scale: float = 0.8
@export var max_scale: float = 1.3
@export var y_level: float = 0.0

@export_tool_button("Generate Forest")
var generate_forest_action = generate_forest

func generate_forest() -> void:
	if tree_mesh == null:
		push_warning("Assign a tree_mesh first.")
		return

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = tree_mesh
	mm.instance_count = tree_count

	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	for i in tree_count:
		var x = rng.randf_range(-area_size.x * 0.5, area_size.x * 0.5)
		var z = rng.randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		var rot = rng.randf_range(0.0, TAU)
		var s = rng.randf_range(min_scale, max_scale)

		var basis := Basis()
		basis = basis.rotated(Vector3.UP, rot)
		basis = basis.scaled(Vector3(s, s, s))

		var transform := Transform3D(basis, Vector3(x, y_level, z))
		mm.set_instance_transform(i, transform)

	multimesh = mm

	if Engine.is_editor_hint():
		notify_property_list_changed()
