class_name Inventory
extends Node

class ItemSlot:
	var item: ItemData
	var quantity: int
	
	func _init(p_item: ItemData = null, p_quantity: int = 0) -> void:
		item = p_item
		quantity = p_quantity
	
	func to_dict() -> Dictionary:
		if not item:
			return {"item_path": "", "quantity": 0}
		return {
			"item_path": item.resource_path,
			"quantity": quantity
		}
	
	static func from_dict(data: Dictionary) -> ItemSlot:
		var slot = ItemSlot.new()
		if data.get("item_path", "") != "":
			var item = load(data["item_path"]) as ItemData
			slot.item = item
			slot.quantity = data.get("quantity", 0)
		return slot

signal updated_inventory
signal updated_slot(slot: ItemSlot)

var item_slots: Array[ItemSlot] = []
var size: int = 20

@export var start_items: Dictionary[ItemData, int] = {}

func _ready() -> void:
	_initialize_slots()
	_add_start_items()

func _initialize_slots() -> void:
	item_slots.clear()
	for i in range(size):
		item_slots.append(ItemSlot.new())

func _add_start_items() -> void:
	for item_data in start_items:
		for _i in range(start_items[item_data]):
			add_item(item_data)

func add_item(item: ItemData) -> bool:
	if not item:
		return false
	
	# Tentar encontrar slot existente com espaço
	var existing_slot = get_item_slot(item)
	if existing_slot:
		existing_slot.quantity += 1
		updated_inventory.emit()
		updated_slot.emit(existing_slot)
		return true
	
	# Encontrar slot vazio
	var empty_slot = get_empty_item_slot()
	if empty_slot:
		empty_slot.item = item
		empty_slot.quantity = 1
		updated_inventory.emit()
		updated_slot.emit(empty_slot)
		return true
	
	print("Inventário cheio! Não é possível adicionar: ", item.display_name)
	return false

func remove_item(item: ItemData) -> bool:
	if not item:
		return false
	
	for slot in item_slots:
		if slot.item == item:
			return remove_item_for_slot(slot)
	
	return false

func remove_item_for_slot(slot: ItemSlot) -> bool:
	if not slot or not slot.item:
		return false
	
	slot.quantity -= 1
	
	if slot.quantity <= 0:
		slot.item = null
		slot.quantity = 0
	
	updated_inventory.emit()
	updated_slot.emit(slot)
	return true

func get_item_slot(item: ItemData) -> ItemSlot:
	if not item:
		return null
	
	for slot in item_slots:
		if slot.item == item and slot.quantity < item.max_stack_item_size:
			return slot
	
	return null

func get_empty_item_slot() -> ItemSlot:
	for slot in item_slots:
		if slot.item == null:
			return slot
	
	return null

func has_item(item: ItemData) -> bool:
	if not item:
		return false
	
	for slot in item_slots:
		if slot.item == item and slot.quantity > 0:
			return true
	
	return false

func get_item_count(item: ItemData) -> int:
	if not item:
		return 0
	
	for slot in item_slots:
		if slot.item == item:
			return slot.quantity
	
	return 0

func clear_inventory() -> void:
	for slot in item_slots:
		slot.item = null
		slot.quantity = 0
	updated_inventory.emit()

func to_dict() -> Array:
	var data: Array = []
	for slot in item_slots:
		data.append(slot.to_dict())
	return data

func from_dict(data: Array) -> void:
	clear_inventory()
	for i in range(min(data.size(), item_slots.size())):
		item_slots[i] = ItemSlot.from_dict(data[i])
	updated_inventory.emit()

func get_occupied_slots() -> int:
	var count = 0
	for slot in item_slots:
		if slot.item != null:
			count += 1
	return count
