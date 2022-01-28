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

var _inventory_editor: Control = null
var _inventory_editor_plugin: EditorInspectorPlugin = null

func _enter_tree() -> void:
	add_autoload_singleton("InventoryManager", "res://addons/inventory_editor/InventoryManager.gd")
	_inventory_editor = InventoryEditor.instantiate()
	_inventory_editor.name = "InventoryEditor"
	get_editor_interface().get_editor_main_control().add_child(_inventory_editor)
	_inventory_editor.set_editor(self)
	_make_visible(false)
	add_custom_type("Item2D", "Node2D", InventoryItem2D, InventoryItemIcon)
	add_custom_type("Item3D", "Node3D", InventoryItem3D, InventoryItemIcon)
	add_custom_type("ItemUI", "TextureRect", ItemUI, InventoryItemUIIcon)
	_inventory_editor_plugin = preload("res://addons/inventory_editor/InventoryInspectorPluginItem.gd").new()
	_inventory_editor_plugin.set_data(_inventory_editor.get_data())
	add_inspector_plugin(_inventory_editor_plugin)

func _exit_tree() -> void:
	if _inventory_editor:
		_inventory_editor.queue_free()
	remove_custom_type("Item2D")
	remove_custom_type("Item3D")
	remove_custom_type("ItemControl")
	remove_inspector_plugin(_inventory_editor_plugin)

func _has_main_screen():
	return true

func _make_visible(visible):
	if _inventory_editor:
		_inventory_editor.visible = visible

func _get_plugin_name():
	return "Inventory"

func _get_plugin_icon():
	return IconResource
