extends Control

var missao_label: Label = null
var peixes_label: Label = null

func _ready():
	missao_label = get_node("VBoxContainer/missao")
	peixes_label = get_node("VBoxContainer2/Peixes")
	
	atualizar_missao("Missão iniciada")
	atualizar_peixes(0)

func atualizar_missao(texto: String) -> void:
	if missao_label:
		missao_label.text = texto

func atualizar_peixes(valor: int) -> void:
	if peixes_label:
		peixes_label.text = str(valor)
