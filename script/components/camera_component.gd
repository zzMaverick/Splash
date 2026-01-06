class_name CameraComponent
extends Node

@export var mouse_sensitivity := 0.2
@export var camera_limit_down := -80.0
@export var camera_limit_up := 60.0

var vertical_pivot: Node3D
var character_body: CharacterBody3D
var current_rotation_x := 0.0

func setup(body: CharacterBody3D, pivot: Node3D) -> void:
	character_body = body
	vertical_pivot = pivot

func handle_input(event: InputEvent) -> void:
	if not character_body or not vertical_pivot:
		return
	
	if event is InputEventMouseMotion:
		character_body.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		current_rotation_x -= event.relative.y * mouse_sensitivity
		current_rotation_x = clamp(current_rotation_x, camera_limit_down, camera_limit_up)
		vertical_pivot.rotation_degrees.x = current_rotation_x
