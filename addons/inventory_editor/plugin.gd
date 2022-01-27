# Plugin InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends EditorPlugin

const IconResource = preload("res://addons/inventory_editor/icons/Inventory.png")
const InventoryEditor = preload("res://addons/inventory_editor/InventoryEditor.tscn")

# New Types
const InventoryItem2D = preload("res://addons/inventory_editor/InventoryItem2D.gd")
const InventoryItem3D = preload("res://addons/inventory_editor/InventoryItem3D.gd")
const InventoryItemIcon = preload("res://addons/inventory_editor/icons/Item.png")
const InventoryItemUIIcon = preload("res://addons/inventory_editor/icons/ItemControl.png")

var _inventory_editor
var _inventory_editor_plugin_item

func _enter_tree() -> void:
	_inventory_editor = InventoryEditor.instance()
	_inventory_editor.name = "InventoryEditor"
	get_editor_interface().get_editor_viewport().add_child(_inventory_editor)
	_inventory_editor.set_editor(self)
	make_visible(false)
	add_custom_type("Item2D", "Node2D", InventoryItem2D, InventoryItemIcon)
	add_custom_type("Item3D", "Spatial", InventoryItem3D, InventoryItemIcon)
	add_custom_type("ItemUI", "TextureRect", ItemUI, InventoryItemUIIcon)
	_inventory_editor_plugin_item = preload("res://addons/inventory_editor/InventoryInspectorPluginItem.gd").new()
	_inventory_editor_plugin_item.set_data(_inventory_editor.get_data())
	add_inspector_plugin(_inventory_editor_plugin_item)

func _exit_tree() -> void:
	if _inventory_editor:
		_inventory_editor.queue_free()
	remove_custom_type("Item2D")
	remove_custom_type("Item3D")
	remove_custom_type("ItemControl")

func has_main_screen():
	return true

func make_visible(visible):
	if _inventory_editor:
		_inventory_editor.visible = visible

func get_plugin_name():
	return "Inventory"

func get_plugin_icon():
	return IconResource
