# 3D Level player to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
extends CharacterBody3D

@export var speed : float = 30
@export var speed_rotation : float = 3
@export var gravity : float = 0.98

var velocity : Vector3

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var direction = Vector3()
	if Input.is_action_pressed("move_up"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_bottom"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_left"):
		rotation.y += speed_rotation * delta
	if Input.is_action_pressed("move_right"):
		rotation.y -= speed_rotation * delta
	direction = direction.normalized()
	direction = direction * speed
	motion_velocity = Vector3(direction.x, 0, direction.z)
	move_and_slide()
