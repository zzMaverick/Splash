class_name GameDebugger
extends Node

## Script de debug para testar funcionalidades do jogo
## Pressione as teclas abaixo durante o jogo para testar

func _ready() -> void:
	print("\n=== SPLASH - DEBUG MODE ===")
	print("Teclas de Debug:")
	print("F1 - Salvar jogo manualmente")
	print("F2 - Carregar jogo")
	print("F3 - Deletar save")
	print("F4 - Imprimir estado do inventário")
	print("F5 - Imprimir dados do save")
	print("F6 - Adicionar 5 peixes ao inventário (teste)")
	print("=====================================\n")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_1"):  # F1
		_test_save()
	elif Input.is_action_just_pressed("ui_2"):  # F2
		_test_load()
	elif Input.is_action_just_pressed("ui_3"):  # F3
		_test_delete_save()
	elif Input.is_action_just_pressed("ui_4"):  # F4
		_print_inventory_state()
	elif Input.is_action_just_pressed("ui_5"):  # F5
		_print_save_data()
	elif Input.is_action_just_pressed("ui_6"):  # F6
		_add_test_fish()

func _test_save() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.save_game()
		print("✅ Jogo salvo manualmente!")
	else:
		print("❌ Player não encontrado!")

func _test_load() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		var saved_data = SaveManager.load_game()
		player.fishing_component.load_game_state(saved_data)
		print("✅ Jogo carregado manualmente!")
	else:
		print("❌ Player não encontrado!")

func _test_delete_save() -> void:
	if SaveManager.delete_save():
		print("✅ Save deletado com sucesso!")
	else:
		print("❌ Nenhum save para deletar!")

func _print_inventory_state() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("❌ Player não encontrado!")
		return
	
	var inventory = player.inventory
	print("\n=== ESTADO DO INVENTÁRIO ===")
	print("Total de slots: ", inventory.size)
	print("Slots ocupados: ", inventory.get_occupied_slots())
	print("\nItens:")
	
	var item_count = 0
	for slot in inventory.item_slots:
		if slot.item:
			item_count += 1
			print("  [%d] %s x%d" % [item_count, slot.item.display_name, slot.quantity])
	
	if item_count == 0:
		print("  (vazio)")
	
	print("=============================\n")

func _print_save_data() -> void:
	var saved_data = SaveManager.load_game()
	print("\n=== DADOS DO SAVE ===")
	print("Peixes coletados: ", saved_data.fish_collected)
	print("Durabilidade da vara: ", saved_data.rod_durability)
	print("Itens no inventário: ", saved_data.inventory_items.size())
	
	for item_data in saved_data.inventory_items:
		if item_data.get("item_path", "") != "":
			print("  - ", item_data["item_path"], " x", item_data["quantity"])
	
	print("====================\n")

func _add_test_fish() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player:
		print("❌ Player não encontrado!")
		return
	
	# Carregar alguns peixes
	var fish_path = "res://itens/fish/"
	var dir = DirAccess.open(fish_path)
	var fish_added = 0
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "" and fish_added < 5:
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource = load(fish_path + file_name)
				if resource is ConsumablesItemData:
					player.inventory.add_item(resource)
					fish_added += 1
			file_name = dir.get_next()
	
	print("✅ %d peixes adicionados ao inventário!" % fish_added)
	_print_inventory_state()
