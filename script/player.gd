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
	
	_setup_inventory()
	
	_setup_components()
	
	_setup_ui()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("_notificar_estado_inicial")

func _setup_inventory():
	inventory = Inventory.new()
	inventory.size = 20
	add_child(inventory)

func _setup_components():
	movement_component = MovementComponent.new()
	movement_component.setup(self)
	add_child(movement_component)
	
	camera_component = CameraComponent.new()
	camera_component.setup(self, head_vertical)
	add_child(camera_component)
	
	fishing_component = FishingComponent.new()
	fishing_component.projectile_scene = load("res://scenes/boia.tscn")
	
	var fish_list = _load_fish_resources()
	
	fishing_component.setup(self, inventory, casting_pos, fish_list)
	fishing_component.set_sounds(sound_acerto)
	add_child(fishing_component)
	
	fishing_component.connect("mission_updated", func(text): mission_updated.emit(text))
	fishing_component.connect("mission_completed", func(): mission_completed.emit())
	fishing_component.connect("fish_caught", func(curr, target): fish_caught.emit(curr, target))

func _setup_ui():
	if not inventariohud:
		inventariohud = get_parent().get_node_or_null("inventario")
		if not inventariohud:
			inventariohud = get_tree().current_scene.get_node_or_null("inventario")
		if not inventariohud:
			inventariohud = get_tree().current_scene.get_node_or_null("Inventario")

	if inventariohud:
		print("Inventário HUD encontrado: ", inventariohud.name)
		inventariohud.visible = false
	else:
		print("AVISO CRÍTICO: Nó 'inventario' não encontrado na cena!")

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
		print("Peixes carregados: ", fish_list.size())
	else:
		print("Erro ao abrir diretório de peixes")
	return fish_list

func _notificar_estado_inicial():
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

func toggle_inventory():
	if inventariohud:
		inventariohud.visible = !inventariohud.visible
		
		if inventariohud.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if fishing_component: fishing_component.can_shoot = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			if fishing_component: fishing_component.can_shoot = true
	else:
		print("Inventário HUD não configurado!")

func iniciar_minigame():
	if fishing_component:
		fishing_component.start_minigame()

func on_boia_deleted():
	if fishing_component:
		fishing_component.notify_projectile_lost()

func _exit_tree():
	if fishing_component:
		fishing_component.cleanup()
