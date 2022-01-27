# Drag and drop UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
# This is a workaround for https://github.com/godotengine/godot/issues/30480
@tool
extends TextureRect

var _item: InventoryItem
var _data: InventoryData

func set_data(item: InventoryItem, data: InventoryData) -> void:
	_item = item
	_data = data

func can_drop_data(position, data) -> bool:
	var resource_value = data["files"][0]
	var resource_extension = _data.file_extension(resource_value)
	if resource_extension == "tscn":
		return true
	return false

func drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_item.set_scene(path_value)
