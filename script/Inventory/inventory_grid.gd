class_name InventoryUI
extends GridContainer

var slot_scene = preload("res://scenes/slots.tscn")
var inventory: Inventory

func _ready() -> void:
	await get_tree().process_frame
	_initialize_inventory()

func _initialize_inventory() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if not player or not "inventory" in player:
		print("[ERRO] Player não encontrado ou sem inventário!")
		return
	
	inventory = player.inventory
	inventory.updated_inventory.connect(_on_inventory_updated)
	inventory.updated_slot.connect(_on_slot_updated)
	
	_create_slot_ui()
	_update_all_slots()

func _create_slot_ui() -> void:
	for child in get_children():
		child.queue_free()
	
	for i in range(inventory.size):
		var slot_instance = slot_scene.instantiate()
		add_child(slot_instance)

func _update_all_slots() -> void:
	for i in range(min(inventory.item_slots.size(), get_child_count())):
		var slot_data = inventory.item_slots[i]
		var slot_ui = get_child(i)
		if slot_ui.has_method("set_slot_data"):
			slot_ui.set_slot_data(slot_data.item, slot_data.quantity)

func _on_inventory_updated() -> void:
	_update_all_slots()

func _on_slot_updated(slot: Inventory.ItemSlot) -> void:
	var index = inventory.item_slots.find(slot)
	if index != -1 and index < get_child_count():
		var slot_ui = get_child(index)
		if slot_ui.has_method("set_slot_data"):
			slot_ui.set_slot_data(slot.item, slot.quantity)
