# Drag and drop UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
# This is a workaround for https://github.com/godotengine/godot/issues/30480
@tool
extends TextureRect

var _inventory: InventoryInventory
var _data: InventoryData

func set_data(inventory: InventoryInventory, data: InventoryData) -> void:
	_inventory = inventory
	_data = data

func can_drop_data(position, data) -> bool:
	var resource_value = data["files"][0]
	var resource_extension = _data.file_extension(resource_value)
	for extension in _data.SUPPORTED_IMAGE_RESOURCES:
		if resource_extension == extension:
			return true
	return false

func drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_inventory.set_icon(path_value)
	_data.emit_inventory_icon_changed(_inventory)
