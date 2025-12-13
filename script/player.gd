extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var bullet = load("res://scenes/boia.tscn")
@onready var pos = $head/vertical/Camera3D/varadepescabase/pos
var current_bullet: Node = null
var linha_mesh: MeshInstance3D = null

@export_category("Settings Mouse")
@export var mouse_sensitivity := 0.2
@export var camera_limit_down := -80
@export var camera_limit_up := 60

@export_category("Sistema de pesca")
@export var pode_atirar := true
@export var cor_linha := Color(0.4, 0.3, 0.2)
@export var espessura_linha := 0.02

var can_ver := 0.0
var peixes_coletados := 0
var peixes_necessarios := 5
var missao_concluida := false
var hud: Node = null

func _ready() -> void:
	hud = get_tree().current_scene.get_node_or_null("hud")
	
	if hud:
		print("HUD encontrado com sucesso!")
	else:
		print("ERRO: HUD não encontrado!")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	call_deferred("_atualizar_hud")
	call_deferred("criar_linha_3d")

func criar_linha_3d():
	linha_mesh = MeshInstance3D.new()
	linha_mesh.mesh = ImmediateMesh.new()
	
	var material = StandardMaterial3D.new()
	material.albedo_color = cor_linha
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	linha_mesh.material_override = material
	
	get_tree().current_scene.call_deferred("add_child", linha_mesh)
	linha_mesh.visible = false
	
	print("Linha 3D criada com sucesso!")

func _process(delta):
	if current_bullet and not is_instance_valid(current_bullet):
		current_bullet = null
		pode_atirar = true
	
	if current_bullet and linha_mesh and is_instance_valid(current_bullet):
		atualizar_linha_3d()
	elif linha_mesh:
		linha_mesh.visible = false

func atualizar_linha_3d():
	var im = linha_mesh.mesh as ImmediateMesh
	im.clear_surfaces()
	
	var inicio = pos.global_position
	var fim = current_bullet.global_position
	
	im.surface_begin(Mesh.PRIMITIVE_LINES)
	im.surface_add_vertex(inicio)
	im.surface_add_vertex(fim)
	im.surface_end()
	
	linha_mesh.visible = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		can_ver -= event.relative.y * mouse_sensitivity
		can_ver = clamp(can_ver, camera_limit_down, camera_limit_up)
		$head/vertical.rotation_degrees.x = can_ver
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("click") and current_bullet == null and pode_atirar:
		var instance = bullet.instantiate()
		instance.position = pos.global_position
		instance.transform = pos.global_transform
		get_parent().add_child(instance)
		current_bullet = instance

func deletar_boia():
	if current_bullet and is_instance_valid(current_bullet):
		current_bullet.queue_free()
	current_bullet = null
	if linha_mesh:
		linha_mesh.visible = false

func iniciar_minigame():
	print("INICIANDO MINIGAME...")
	pode_atirar = false
	
	if linha_mesh:
		linha_mesh.visible = false
	
	var minigame = load("res://scenes/barra_pesca.tscn").instantiate()
	get_tree().current_scene.add_child(minigame)
	
	var connection_result = minigame.connect("minigame_concluido", Callable(self, "_on_minigame_concluido"))
	if connection_result == OK:
		print("Sinal conectado com sucesso!")

func _on_minigame_concluido(peixe_capturado: bool):
	print("SINAL RECEBIDO! Peixe capturado:", peixe_capturado)
	
	deletar_boia()
	
	if peixe_capturado:
		peixes_coletados += 1
		print("Peixe capturado! Total:", peixes_coletados)
		_atualizar_hud()
		
		if peixes_coletados >= peixes_necessarios:
			missao_concluida = true
			if hud:
				hud.modulate = Color(1, 1, 0)  
				hud.atualizar_missao("Missão concluída!")
	
	pode_atirar = true

func _atualizar_hud():
	if hud:
		hud.atualizar_missao("Pesque %d peixes" % peixes_necessarios)
		hud.atualizar_peixes(peixes_coletados)
		print("HUD atualizado:", peixes_coletados, "peixes")

func _exit_tree():
	if linha_mesh:
		linha_mesh.queue_free()
