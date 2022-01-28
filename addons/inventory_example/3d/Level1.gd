# 3D Level to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
extends Node3D

var inventoryManager

@export var clear_inventory: bool = true

@onready var _error_ui = $CanvasError as CanvasLayer
@onready var _inventory = $CanvasInventory/Inventory
@onready var _inventory_button_ui = $CanvasButton/TextureButton as TextureButton

func _ready() -> void:
	if get_tree().get_root().has_node("InventoryManager"):
		_error_ui.queue_free()
		inventoryManager = get_tree().get_root().get_node("InventoryManager")
		inventoryManager.player = $Player
		if clear_inventory:
			inventoryManager.clear_inventory(_inventory.inventory)
		_inventory_button_ui.pressed.connect(_on_inventory_button_pressed)

func _on_inventory_button_pressed() -> void:
	if _inventory.visible:
		_inventory.hide()
	else:
		_inventory.show()
