extends CharacterBody3D

signal fish_caught(current_amount: int, target_amount: int)
signal mission_completed
signal mission_updated(text: String)

var movement_component: MovementComponent
var camera_component: CameraComponent
var fishing_component: FishingComponent

@onready var head_vertical = $head/vertical
@onready var casting_pos = $head/vertical/Camera3D/varadepescabase/pos
@onready var sound_acerto = $SomAcerto

@export var inventariohud: Control
var inventory: Inventory

func _ready() -> void:
	add_to_group("Player")
	
	_initialize_systems()
	_load_game_state()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _initialize_systems() -> void:
	# Inventário
	inventory = Inventory.new()
	inventory.size = 20
	add_child(inventory)
	
	# Componentes
	_setup_movement()
	_setup_camera()
	_setup_fishing()
	_setup_ui()

func _setup_movement() -> void:
	movement_component = MovementComponent.new()
	movement_component.setup(self)
	add_child(movement_component)

func _setup_camera() -> void:
	camera_component = CameraComponent.new()
	camera_component.setup(self, head_vertical)
	add_child(camera_component)

func _setup_fishing() -> void:
	fishing_component = FishingComponent.new()
	fishing_component.projectile_scene = load("res://scenes/boia.tscn")
	
	var fish_list = _load_fish_resources()
	
	fishing_component.setup(self, inventory, casting_pos, fish_list)
	fishing_component.set_sounds(sound_acerto)
	add_child(fishing_component)
	
	# Conectar sinais
	fishing_component.mission_updated.connect(mission_updated.emit)
	fishing_component.mission_completed.connect(mission_completed.emit)
	fishing_component.fish_caught.connect(fish_caught.emit)

func _setup_ui() -> void:
	# Tentar encontrar o inventário HUD
	inventariohud = get_parent().get_node_or_null("inventario")
	if not inventariohud:
		inventariohud = get_tree().current_scene.get_node_or_null("inventario")
	if not inventariohud:
		inventariohud = get_tree().current_scene.get_node_or_null("Inventario")

	if inventariohud:
		inventariohud.visible = false
	else:
		print("AVISO: Inventário HUD não encontrado!")

func _load_fish_resources() -> Array[ConsumablesItemData]:
	var fish_list: Array[ConsumablesItemData] = []
	var path = "res://itens/fish/"
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and (file_name.ends_with(".tres") or file_name.ends_with(".remap")):
				var final_name = file_name.replace(".remap", "")
				var resource = load(path + "/" + final_name)
				if resource is ConsumablesItemData:
					fish_list.append(resource)
			file_name = dir.get_next()
	
	return fish_list

func _load_game_state() -> void:
	var saved_data = SaveManager.load_game()
	if fishing_component:
		fishing_component.load_game_state(saved_data)
	
	# Notificar estado inicial
	await get_tree().process_frame
	mission_updated.emit("Pesque %d peixes" % fishing_component.fish_needed)
	fish_caught.emit(fishing_component.fish_collected, fishing_component.fish_needed)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("OpenInventory"):
		toggle_inventory()
	
	if fishing_component:
		fishing_component.handle_process(delta)
		fishing_component.handle_input()

func _physics_process(delta: float) -> void:
	if movement_component:
		movement_component.handle_physics(delta)

func _input(event: InputEvent) -> void:
	if inventariohud and inventariohud.visible:
		if Input.is_action_just_pressed("ui_cancel"):
			toggle_inventory()
		return
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if camera_component:
		camera_component.handle_input(event)

func toggle_inventory() -> void:
	if not inventariohud:
		return
	
	inventariohud.visible = !inventariohud.visible
	
	if inventariohud.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if fishing_component:
			fishing_component.can_shoot = false
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if fishing_component:
			fishing_component.can_shoot = true

func iniciar_minigame() -> void:
	if fishing_component:
		fishing_component.start_minigame()

func on_boia_deleted() -> void:
	if fishing_component:
		fishing_component.notify_projectile_lost()

func save_game() -> void:
	if fishing_component:
		fishing_component._save_game_state()

func _exit_tree() -> void:
	save_game()
	if fishing_component:
		fishing_component.cleanup()
