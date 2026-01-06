class_name FishingBobber
extends CharacterBody3D

const SPEED = 120
const LIFE_TIME = 5.0

var has_started_minigame := false
var elapsed_time := 0.0

func _ready() -> void:
	add_to_group("bobber")

func _physics_process(delta: float) -> void:
	if has_started_minigame:
		return
	
	elapsed_time += delta
	
	# Verificar timeout
	if elapsed_time >= LIFE_TIME:
		_notify_player_bobber_deleted()
		queue_free()
		return
	
	# Movimento
	var motion = transform.basis.z * SPEED * delta
	var collision = move_and_collide(motion)
	
	if collision:
		var collider = collision.get_collider()
		
		if collider.name == "Agua":
			_start_minigame()
		else:
			_notify_player_bobber_deleted()
			queue_free()

func _start_minigame() -> void:
	has_started_minigame = true
	var player = _get_player()
	if player:
		player.iniciar_minigame()

func _notify_player_bobber_deleted() -> void:
	var player = _get_player()
	if player and player.has_method("on_boia_deleted"):
		player.on_boia_deleted()

func _get_player() -> Node:
	var player = get_tree().get_first_node_in_group("Player")
	return player
