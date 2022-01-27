# Inventory ItemControl as custom type for UI in InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends Control
class_name InventoryUI

const InventoryManagerName = "InventoryManager"
var _inventoryManager

@export var inventory: String # inventory_uuid

func set_inventory_manager(inv_uuid, manager) -> void:
	inventory = inv_uuid
	_inventoryManager = manager
	_set_inventory_manager_to_stacks(self)

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)
		if _inventoryManager:
			_set_inventory_manager_to_stacks(self)

func _set_inventory_manager_to_stacks(node: Node) -> void:
	for child in node.get_children():
		if child.has_method("set_inventory_manager"):
			child.set_inventory_manager(inventory, _inventoryManager)
		for sub_child in child.get_children():
			_set_inventory_manager_to_stacks(child)
