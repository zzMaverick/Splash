class_name FishingMinigame
extends Control

signal minigame_concluded(peixe_capturado: bool)

@onready var barra = $ProgressBar
@onready var label = $Label

const MAX_VALUE = 100.0
const INITIAL_VALUE = 20.0
const RISE_SPEED = 100.0
const FALL_SPEED = 30.0
const COMPLETION_DELAY = 2.0

var valor: float = INITIAL_VALUE
var esta_jogando := true

func _ready() -> void:
	_initialize_bar()

func _initialize_bar() -> void:
	barra.min_value = 0
	barra.max_value = MAX_VALUE
	barra.value = INITIAL_VALUE

func _process(delta: float) -> void:
	if not esta_jogando:
		return
	
	_update_bar_value(delta)
	barra.value = valor
	
	if valor >= MAX_VALUE:
		_finish_minigame(true)
	elif valor <= 0.0:
		_finish_minigame(false)

func _update_bar_value(delta: float) -> void:
	if Input.is_action_pressed("click"):
		valor += RISE_SPEED * delta
	else:
		valor -= FALL_SPEED * delta
	
	valor = clamp(valor, 0.0, MAX_VALUE)

func _finish_minigame(ganhou: bool) -> void:
	esta_jogando = false
	_show_result(ganhou)
	await get_tree().create_timer(COMPLETION_DELAY).timeout
	_remove_minigame()

func _show_result(ganhou: bool) -> void:
	if ganhou:
		label.text = "O peixe foi capturado!"
		label.modulate = Color.GREEN
	else:
		label.text = "O peixe escapou!"
		label.modulate = Color.RED

func _remove_minigame() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_property(self, "scale", Vector2(1.4, 1.4), 0.4)
	await tween.finished
	minigame_concluded.emit(label.text.contains("capturado"))
	queue_free()
