class_name GameHUD
extends Control

@onready var missao_label = $VBoxContainer/missao
@onready var peixes_label = $VBoxContainer2/Peixes

var player: Node = null

func _ready() -> void:
	await get_tree().process_frame
	_initialize_hud()

func _initialize_hud() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	if not player:
		print("ERRO: Player não encontrado!")
		return
	
	_connect_signals()
	_update_initial_state()

func _connect_signals() -> void:
	if player.has_signal("mission_updated"):
		player.mission_updated.connect(_on_mission_updated)
	
	if player.has_signal("fish_caught"):
		player.fish_caught.connect(_on_fish_caught)
	
	if player.has_signal("mission_completed"):
		player.mission_completed.connect(_on_mission_completed)

func _update_initial_state() -> void:
	if player and "fishing_component" in player:
		var fc = player.fishing_component
		update_mission("Pesque %d peixes" % fc.fish_needed)
		update_fish_count(fc.fish_collected)

func _on_mission_updated(text: String) -> void:
	update_mission(text)

func _on_fish_caught(current: int, _target: int) -> void:
	update_fish_count(current)

func _on_mission_completed() -> void:
	modulate = Color(1, 1, 0)

func update_mission(text: String) -> void:
	if missao_label:
		missao_label.text = text

func update_fish_count(count: int) -> void:
	if peixes_label:
		peixes_label.text = str(count)
