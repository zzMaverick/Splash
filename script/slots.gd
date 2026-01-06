class_name InventorySlot
extends Control

func set_slot_data(item: ItemData, quantity: int) -> void:
	if item:
		$Name.text = item.display_name
		$Amount.text = str(quantity) if quantity > 0 else ""
		$Item.texture = item.icon
	else:
		_clear_slot()

func _get_drag_data(at_position: Vector2):
	if not $Item.texture:
		return null
	
	var data := {
		"name": $Name.text,
		"amount": $Amount.text,
		"texture": $Item.texture,
		"source_slot": self
	}
	
	var preview = self.duplicate()
	preview.get_node("BackGround").hide()
	preview.get_node("Amount").hide()
	preview.get_node("Item").position = -preview.size / 2
	
	_clear_slot()
	set_drag_preview(preview)
	
	return data

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and "texture" in data

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not data is Dictionary:
		return
	
	var source_slot = data.get("source_slot")
	
	if $Item.texture == data["texture"]:
		# Mesmo item, empilhar
		var current_amount = int($Amount.text) if $Amount.text != "" else 0
		var drop_amount = int(data["amount"]) if data["amount"] != "" else 0
		$Amount.text = str(current_amount + drop_amount)
		$Name.text = data["name"]
	else:
		# Itens diferentes, trocar
		if source_slot:
			source_slot.get_node("Item").texture = $Item.texture
			source_slot.get_node("Amount").text = $Amount.text
			source_slot.get_node("Name").text = $Name.text
		
		$Name.text = data["name"]
		$Item.texture = data["texture"]
		$Amount.text = data["amount"]

func _clear_slot() -> void:
	$Amount.text = ""
	$Item.texture = null
	$Name.text = ""
