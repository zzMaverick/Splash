class_name SaveManager
extends Node

const SAVE_PATH := "user://splash_save.json"

class GameData:
	var fish_collected: int = 0
	var inventory_items: Array[Dictionary] = []
	var rod_durability: float = 50.0

static func save_game(game_data: GameData) -> bool:
	var data_dict = {
		"fish_collected": game_data.fish_collected,
		"rod_durability": game_data.rod_durability,
		"inventory_items": game_data.inventory_items
	}
	
	var json = JSON.stringify(data_dict)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	if file == null:
		print("Erro ao salvar o jogo: ", FileAccess.get_open_error())
		return false
	
	file.store_string(json)
	print("Jogo salvo com sucesso!")
	return true

static func load_game() -> GameData:
	var game_data = GameData.new()
	
	if not ResourceLoader.exists(SAVE_PATH):
		print("Nenhum save encontrado. Usando dados padrão.")
		return game_data
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		print("Erro ao carregar o jogo: ", FileAccess.get_open_error())
		return game_data
	
	var json_str = file.get_as_text()
	var json = JSON.new()
	
	if json.parse(json_str) != OK:
		print("Erro ao fazer parse do JSON")
		return game_data
	
	var data_dict = json.data as Dictionary
	game_data.fish_collected = data_dict.get("fish_collected", 0)
	game_data.rod_durability = data_dict.get("rod_durability", 50.0)
	game_data.inventory_items = data_dict.get("inventory_items", [])
	
	print("Jogo carregado com sucesso!")
	return game_data

static func delete_save() -> bool:
	if ResourceLoader.exists(SAVE_PATH):
		var error = DirAccess.remove_absolute(SAVE_PATH)
		if error == OK:
			print("Save deletado com sucesso!")
			return true
	return false
