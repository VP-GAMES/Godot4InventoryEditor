# 3D Level player to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
extends KinematicBody

@export var speed : float = 30
@export var speed_rotation : float = 65
@export var acceleration : float = 15
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
		rotation_degrees.y += speed_rotation * delta
	if Input.is_action_pressed("move_right"):
		rotation_degrees.y -= speed_rotation * delta
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
