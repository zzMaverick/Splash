extends GridContainer

var slot_scene = preload("res://scenes/slots.tscn")
var inventory: Inventory

func _ready() -> void:
	await get_tree().process_frame
	
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		var player = players[0]
		if "inventory" in player:
			inventory = player.inventory
			_setup_inventory()
	else:
		print("Player não encontrado no grupo 'Player'")

func _setup_inventory():
	for child in get_children():
		child.queue_free()
	
	inventory.updated_inventory.connect(update_slots)
	inventory.updated_slot.connect(update_single_slot)
	
	for i in range(inventory.size):
		var slot_instance = slot_scene.instantiate()
		add_child(slot_instance)
		
	update_slots()

func update_slots():
	for i in range(min(inventory.item_slots.size(), get_child_count())):
		var slot_data = inventory.item_slots[i]
		var slot_ui = get_child(i)
		if slot_ui.has_method("set_slot_data"):
			slot_ui.set_slot_data(slot_data.item, slot_data.quantity)

func update_single_slot(slot_data):
	var index = inventory.item_slots.find(slot_data)
	if index != -1 and index < get_child_count():
		var slot_ui = get_child(index)
		if slot_ui.has_method("set_slot_data"):
			slot_ui.set_slot_data(slot_data.item, slot_data.quantity)
