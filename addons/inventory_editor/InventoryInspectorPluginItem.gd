# InspectorPlugin for InventoryEditor : MIT License
# @author Vladimir Petrenko
extends EditorInspectorPlugin

var _data: InventoryData

func set_data(data: InventoryData) -> void:
	_data = data

func can_handle(object):
	return object is Item2D or object is Item3D or object is Control or object is ItemUI

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_STRING:
		match path:
			"to_inventory", "inventory_uuid", "inventory":
				var inspectorEditorInventory = InventoryInspectorEditorInventory.new()
				inspectorEditorInventory.set_data(_data)
				add_property_editor(path, inspectorEditorInventory)
				return true
			"type":
				var inspectorEditorType = InventoryInspectorEditorType.new()
				inspectorEditorType.set_data(_data)
				add_property_editor(path, inspectorEditorType)
				return true
			"item_put":
				var inspectorEditorItem = InventoryInspectorEditorItem.new()
				inspectorEditorItem.set_data(_data, object)
				add_property_editor(path, inspectorEditorItem)
				return true
	return false
