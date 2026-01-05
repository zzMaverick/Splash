class_name FishingComponent
extends Node

signal fish_caught(current_amount: int, target_amount: int)
signal mission_completed
signal mission_updated(text: String)

@export var projectile_scene: PackedScene
@export var line_color := Color(0.4, 0.3, 0.2)
@export var casting_position_node: Node3D

var player: CharacterBody3D
var inventory: Inventory

var current_projectile: Node = null
var line_mesh: MeshInstance3D = null
var can_shoot := true
var fish_collected := 0
var fish_needed := 5
var mission_done := false
var available_fish: Array[ConsumablesItemData] = []

var equipped_rod: WeaponItemData
var current_bait: BaitItemData

var sound_success: AudioStreamPlayer3D
var sound_error_path := "res://Songs/erro.mp3"

func setup(body: CharacterBody3D, inv: Inventory, cast_pos: Node3D, fish_list: Array[ConsumablesItemData]):
	player = body
	inventory = inv
	casting_position_node = cast_pos
	available_fish = fish_list
	
	create_line_3d()
	
	equipped_rod = WeaponItemData.new()
	equipped_rod.display_name = "Vara Básica"
	equipped_rod.max_durability = 50
	equipped_rod.current_durability = 50

func set_sounds(success_node: AudioStreamPlayer3D):
	sound_success = success_node

func handle_process(_delta: float):
	if current_projectile and not is_instance_valid(current_projectile):
		current_projectile = null
		can_shoot = true
	
	if current_projectile and line_mesh and is_instance_valid(current_projectile):
		update_line_3d()
	elif line_mesh:
		line_mesh.visible = false

func handle_input():
	if Input.is_action_just_pressed("click") and current_projectile == null and can_shoot:
		try_cast_rod()

func try_cast_rod():
	if equipped_rod and equipped_rod.is_broken():
		mission_updated.emit("Vara quebrada!")
		return

	var bait = _find_bait_in_inventory()
	if bait:
		current_bait = bait
		print("Usando isca: ", bait.display_name)
	else:
		current_bait = null
		print("Pescando sem isca (ou isca padrão)")

	cast_rod()

func cast_rod():
	if not projectile_scene or not casting_position_node:
		return
		
	var instance = projectile_scene.instantiate()
	instance.position = casting_position_node.global_position
	instance.transform = casting_position_node.global_transform
	player.get_parent().add_child(instance)
	current_projectile = instance
	
	if equipped_rod:
		equipped_rod.reduce_durability(1)
		print("Durabilidade da vara: ", equipped_rod.current_durability)

func notify_projectile_lost():
	current_projectile = null
	can_shoot = true
	if line_mesh:
		line_mesh.visible = false

func delete_bobber():
	if current_projectile and is_instance_valid(current_projectile):
		current_projectile.queue_free()
	current_projectile = null
	if line_mesh:
		line_mesh.visible = false

func start_minigame():
	print("INICIANDO MINIGAME...")
	can_shoot = false
	
	if line_mesh:
		line_mesh.visible = false
	
	var minigame = load("res://scenes/barra_pesca.tscn").instantiate()
	player.get_tree().current_scene.add_child(minigame)
	
	minigame.connect("minigame_concluido", _on_minigame_concluded)

func _on_minigame_concluded(caught: bool):
	delete_bobber()
	
	if caught:
		_handle_catch_success()
	else:
		_handle_catch_fail()
	
	can_shoot = true

func _handle_catch_success():
	fish_collected += 1
	
	if current_bait:
		inventory.remove_item(current_bait)
		current_bait = null
	
	var fish = _roll_for_fish()
	if fish:
		inventory.add_item(fish)
		print("Peixe capturado: ", fish.display_name)
	
	mission_updated.emit("Pesque %d peixes" % fish_needed)
	fish_caught.emit(fish_collected, fish_needed)
	
	if fish_collected >= fish_needed:
		mission_done = true
		mission_updated.emit("Missão concluída!")
		mission_completed.emit()
		if sound_success:
			sound_success.play()

func _handle_catch_fail():
	if current_bait:
		inventory.remove_item(current_bait)
		current_bait = null

func _find_bait_in_inventory() -> BaitItemData:
	for slot in inventory.item_slots:
		if slot.item is BaitItemData:
			return slot.item
	return null

func _roll_for_fish() -> ConsumablesItemData:
	var total_weight = 0.0
	for f in available_fish:
		total_weight += f.weight
	
	var roll = randf_range(0, total_weight)
	var accumulated = 0.0
	for f in available_fish:
		accumulated += f.weight
		if roll <= accumulated:
			return f
	return null

func create_line_3d():
	line_mesh = MeshInstance3D.new()
	line_mesh.mesh = ImmediateMesh.new()
	
	var material = StandardMaterial3D.new()
	material.albedo_color = line_color
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	line_mesh.material_override = material
	
	player.get_tree().current_scene.call_deferred("add_child", line_mesh)
	line_mesh.visible = false

func update_line_3d():
	var im = line_mesh.mesh as ImmediateMesh
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(casting_position_node.global_position)
	im.surface_add_vertex(current_projectile.global_position)
	im.surface_end()
