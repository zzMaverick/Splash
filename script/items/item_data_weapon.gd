class_name WeaponItemData
extends ItemData

@export var max_durability: float = 100.0
@export var current_durability: float = 100.0

func reduce_durability(amount: float):
	current_durability = max(0, current_durability - amount)

func is_broken() -> bool:
	return current_durability <= 0
