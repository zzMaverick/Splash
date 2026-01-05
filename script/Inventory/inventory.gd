class_name Inventory
extends Node

class ItemSlot:
	var item : ItemData
	var quantity : int

signal updated_inventory
signal updated_slot(slot : ItemSlot)

var item_slots : Array [ItemSlot]

@export var size : int = 9
@export var start_items : Dictionary[ItemData, int]

func _ready() -> void:
	
	for i in range(size):
		item_slots.append(ItemSlot.new())
	
	for key in start_items:
		for i in range(start_items[key]): 
			add_item(key)
	
func add_item(item : ItemData) -> bool:
	var slot: ItemSlot = get_item_slot(item)
	if slot and slot.quantity < item.max_stack_item_size:
		slot.quantity += 1
	else:
		slot = get_empty_item_slot()
		
		if not slot :
			return false
			
		slot.item = item
		slot.quantity += 1
	updated_inventory.emit()
	updated_slot.emit(slot)
	
	return true 
	
func remove_item(item : ItemData) :
	for slot in item_slots:
		if slot.item == item:
			remove_item_for_slot(slot)
			return

func remove_item_for_slot(slot : ItemSlot):
	if not slot.item:
		return 
	if slot.quantity == 1:
		slot.item = null
	else:
		slot.quantity -= 1
	
	updated_inventory.emit()
	updated_slot.emit(slot)
	
func get_item_slot(item: ItemData) -> ItemSlot:
	for slot in item_slots:
		if slot.item == item and slot.quantity < item.max_stack_item_size:
			return slot
	
	return null
	
func get_empty_item_slot() -> ItemSlot:
	for slot in item_slots:
		if slot.item == null:
			return slot
	
	return null 
	
func has_item(item : ItemData):
	for slot in item_slots:
		if slot.item == item:
			return true
	return false
