# 2D Level player to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
extends CharacterBody2D

const FLOOR_NORMAL: = Vector2.UP
@export var speed: = Vector2(400.0, 500.0)
@export var gravity: = 1000.0

var _velocity: = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_velocity.y += gravity * delta
	var is_jump_interrupted: = Input.is_action_just_released("move_up") and _velocity.y < 0.0
	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	var snap: Vector2 = Vector2.DOWN * 60.0 if direction.y == 0.0 else Vector2.ZERO
	velocity = _velocity
	move_and_slide()

func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-Input.get_action_strength("move_up") if is_on_floor() and Input.is_action_just_pressed("move_up") else 0.0)

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var velocity: = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y = 0.0
	return velocity
