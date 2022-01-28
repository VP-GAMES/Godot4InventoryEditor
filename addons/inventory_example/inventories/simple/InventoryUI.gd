# Example implementation for inventory to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends InventoryUI

onready var _grid_ui = $NinePatchRect/Margin/Grid as GridContainer

export(PackedScene) var Item

func set_inventory_manager(inv_uuid, manager) -> void:
	inventory = inv_uuid
	_inventoryManager = manager
	_update_view()

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)
	_update_view()

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	var children = _grid_ui.get_children()
	for child in children:
		_grid_ui.remove_child(child)
		child.queue_free()

func _draw_view() -> void:
	if _inventoryManager:
		var inventory_db = _inventoryManager.get_inventory_db(inventory) as InventoryInventory
		if inventory_db:
			for index in range(inventory_db.stacks):
				var item_ui = Item.instance()
				_grid_ui.add_child(item_ui)
				item_ui.set_index(index)
			_set_inventory_manager_to_stacks(self)
