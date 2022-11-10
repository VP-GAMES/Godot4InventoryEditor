# Inventories data for InventoryManager in InventoryEditor : MIT License
# @author Vladimir Petrenko
extends Resource
class_name InventoryInventories

@export var inventories = {}
# {"inventory_uuid": {"stacks": [{"item_uuid": uuid, "quantity": 0}]}}

func reset() -> void:
	inventories = {}
