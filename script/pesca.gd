extends CharacterBody3D

var speed = 120
var ja_iniciou_minigame = false
var tempo_vida = 5.0
var tempo_decorrido = 0.0

func _ready():
	add_to_group("boia")

func _physics_process(delta):
	if not ja_iniciou_minigame:
		tempo_decorrido += delta
		
		if tempo_decorrido >= tempo_vida:
			notificar_player_boia_deletada()
			queue_free()
			return
		
		var motion = transform.basis.z * speed * delta
		var collision = move_and_collide(motion)
		
		if collision:
			var obj = collision.get_collider()
			
			if obj.name == "Agua":
				iniciar_minigame()
			else:
				notificar_player_boia_deletada()
				queue_free()

func iniciar_minigame():
	ja_iniciou_minigame = true
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.iniciar_minigame()

func notificar_player_boia_deletada():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.current_bullet = null
		player.pode_atirar = true
