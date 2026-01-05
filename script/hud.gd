extends Control

var missao_label: Label = null
var peixes_label: Label = null

func _ready():
	missao_label = get_node("VBoxContainer/missao")
	peixes_label = get_node("VBoxContainer2/Peixes")
	
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var player = players[0]
		_connect_player(player)
	else:
		print("HUD: Player não encontrado")
	
	atualizar_missao("Missão iniciada")
	atualizar_peixes(0)

func _connect_player(player):
	if player.has_signal("mission_updated"):
		player.mission_updated.connect(atualizar_missao)
	if player.has_signal("fish_caught"):
		player.fish_caught.connect(_on_fish_caught)
	if player.has_signal("mission_completed"):
		player.mission_completed.connect(_on_mission_completed)
	
	# Sincronizar estado inicial
	if "peixes_coletados" in player:
		atualizar_peixes(player.peixes_coletados)
	if "peixes_necessarios" in player:
		atualizar_missao("Pesque %d peixes" % player.peixes_necessarios)

func _on_fish_caught(current: int, _target: int):
	atualizar_peixes(current)

func _on_mission_completed():
	modulate = Color(1, 1, 0)

func atualizar_missao(texto: String) -> void:
	if missao_label:
		missao_label.text = texto

func atualizar_peixes(valor: int) -> void:
	if peixes_label:
		peixes_label.text = str(valor)
