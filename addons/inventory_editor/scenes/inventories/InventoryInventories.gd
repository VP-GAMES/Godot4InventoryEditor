# Inventories UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Panel

var _data: InventoryData

@onready var _add_ui = $Margin/VBox/HBox/Add as Button
@onready var _inventories_ui = $Margin/VBox/Scroll/Inventories

const InventoryInventoryUI = preload("res://addons/inventory_editor/scenes/inventories/InventoryInventoryUI.tscn")

func set_data(data: InventoryData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		assert(_add_ui.pressed.connect(_on_add_pressed) == OK)
	if not _data.inventory_added.is_connected(_on_inventory_added):
		assert(_data.inventory_added.connect(_on_inventory_added) == OK)
	if not _data.inventory_removed.is_connected(_on_inventory_removed):
		assert(_data.inventory_removed.connect(_on_inventory_removed) == OK)

func _on_add_pressed() -> void:
	_data.add_inventory()

func _on_inventory_added(inventory: InventoryInventory) -> void:
	_update_view()

func _on_inventory_removed(inventory: InventoryInventory) -> void:
	_update_view()
	
func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for inventory_ui in _inventories_ui.get_children():
		_inventories_ui.remove_child(inventory_ui)
		inventory_ui.queue_free()

func _draw_view() -> void:
	for inventory in _data.inventories:
		_draw_inventory(inventory)

func _draw_inventory(inventory: InventoryInventory) -> void:
	var inventory_ui = InventoryInventoryUI.instantiate()
	_inventories_ui.add_child(inventory_ui)
	inventory_ui.set_data(inventory, _data)
