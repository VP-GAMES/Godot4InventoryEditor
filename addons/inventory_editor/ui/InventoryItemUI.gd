# Inventory Item as custom type for UI in InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends TextureRect
class_name ItemUI

var _item_ui_icon

const ItemUIIcon = preload("res://addons/inventory_editor/ui/InventoryItemUIIcon.tscn")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if not has_node("ItemUIIcon"):
			_add_item_ui_icon()

func _add_item_ui_icon() -> void:
	_item_ui_icon = ItemUIIcon.instantiate()
	_item_ui_icon.name = "ItemUIIcon"
	add_child(_item_ui_icon)
	_item_ui_icon.set_owner(get_tree().edited_scene_root)
