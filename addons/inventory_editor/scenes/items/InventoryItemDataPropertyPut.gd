# Item put texture for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends TextureRect

var _property
var _item: InventoryItem

func set_data(property, item: InventoryItem) -> void:
	_property = property
	_item = item

func can_drop_data(position, data) -> bool:
	return true

func drop_data(position, data) -> void:
	if data.has("files"):
		var path_value = data["files"][0]
		_item.change_property_value(_property, path_value)
