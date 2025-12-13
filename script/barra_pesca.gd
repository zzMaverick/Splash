extends Control

signal minigame_concluido(peixe_capturado: bool)

@onready var barra = $ProgressBar
@onready var label = $Label

var valor: float = 20
var maximo: float = 100.0
var esta_jogando = true
var velocidade_subida: float = 100.0
var velocidade_descida: float = 30.0

func _ready():
	barra.min_value = 0
	barra.max_value = 100
	barra.value = 0

func _process(delta: float):
	if esta_jogando:
		if Input.is_action_pressed("click"):
			valor += velocidade_subida * delta
		else:
			valor -= velocidade_descida * delta
		
		valor = clamp(valor, 0.0, maximo)
		barra.value = valor
		
		if valor >= maximo:
			esta_jogando = false
			label.text = "O peixe foi capturado!"
			label.modulate = Color(0, 1, 0)  
			await get_tree().create_timer(2.0).timeout
			terminar_minigame(true)
		
		if valor <= 0.0:
			esta_jogando = false
			label.text = "O peixe escapou!"
			label.modulate = Color(1, 0, 0)  
			await get_tree().create_timer(2.0).timeout
			terminar_minigame(false)

func terminar_minigame(ganhou: bool):
	emit_signal("minigame_concluido", ganhou)
	_remover_minigame()

func _remover_minigame():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.4)
	await tween.finished
	queue_free()
