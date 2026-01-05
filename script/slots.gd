extends Control

func set_slot_data(item: ItemData, quantity: int) -> void:
	if item:
		$Name.text = item.display_name
		$Amount.text = str(quantity)
		$Item.texture = item.icon
	else:
		set_empty_slot()

func _get_drag_data(at_position: Vector2):
	var data := {
		"Name": $Name.text,
		"Amount": $Amount.text,
		"Item": $Item.texture,
		"backup": self
	}
	var preview = self.duplicate()
	
	preview.get_node("BackGround").hide()
	preview.get_node("Amount").hide()
	preview.get_node("Item").position = -preview.size / 2 
	
	set_empty_slot()
	
	set_drag_preview(preview)
	
	return data

func set_empty_slot() -> void:
	$Amount.text = ""
	$Item.texture = null
	$Name.text = ""

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true 

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if $Item.texture == data["Item"]:
		var drop_item = int($Amount.text)
		drop_item += int(data["Amount"])
		$Amount.text = str(drop_item)
		$Name.text = data["Name"]
		
	else:
		data.backup.get_node("Item").texture = $Item.texture
		data.backup.get_node("Amount").text = $Amount.text
		data.backup.get_node("Name").text = $Name.text
		
		$Name.text = data["Name"]
		$Item.texture = data["Item"]
		$Amount.text = data["Amount"]
		
	
