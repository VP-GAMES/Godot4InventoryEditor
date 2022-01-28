# Example implementation for inventory item to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
tool
extends ItemUI

func set_index(index) -> void:
	if not _item_ui_icon:
		_item_ui_icon = $ItemUIIcon
	if not _item_ui_icon:
		_add_item_ui_icon()
	_item_ui_icon.index = index
