class_name MovementComponent
extends Node

@export var speed := 5.0
@export var jump_velocity := 4.5
@export var gravity := 9.8

var character_body: CharacterBody3D

func setup(body: CharacterBody3D) -> void:
	character_body = body
	var project_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	if project_gravity:
		gravity = project_gravity

func handle_physics(delta: float) -> void:
	if not character_body:
		return
	
	# Gravidade
	if not character_body.is_on_floor():
		character_body.velocity.y -= gravity * delta
	
	# Pulo
	if Input.is_action_just_pressed("ui_accept") and character_body.is_on_floor():
		character_body.velocity.y = jump_velocity
	
	# Movimento
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (character_body.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		character_body.velocity.x = direction.x * speed
		character_body.velocity.z = direction.z * speed
	else:
		character_body.velocity.x = move_toward(character_body.velocity.x, 0, speed)
		character_body.velocity.z = move_toward(character_body.velocity.z, 0, speed)
	
	character_body.move_and_slide()
