# InspectorPlugin for InventoryEditor : MIT License
# @author Vladimir Petrenko
extends EditorInspectorPlugin

var _data: InventoryData

func set_data(data: InventoryData) -> void:
	_data = data

func _can_handle(object):
	return object is Item2D or object is Item3D or object is Control or object is ItemUI

func _parse_property(object: Object, type: int, name: String, hint_type: int, hint_string: String, usage_flags: int, wide: bool):
	if type == TYPE_STRING:
		match name:
			"to_inventory", "inventory_uuid", "inventory":
				var inspectorEditorInventory = InventoryInspectorEditorInventory.new()
				inspectorEditorInventory.set_data(_data)
				add_property_editor(name, inspectorEditorInventory)
				return true
			"type":
				var inspectorEditorType = InventoryInspectorEditorType.new()
				inspectorEditorType.set_data(_data)
				add_property_editor(name, inspectorEditorType)
				return true
			"item_put":
				var inspectorEditorItem = InventoryInspectorEditorItem.new()
				inspectorEditorItem.set_data(_data, object)
				add_property_editor(name, inspectorEditorItem)
				return true
	return false
