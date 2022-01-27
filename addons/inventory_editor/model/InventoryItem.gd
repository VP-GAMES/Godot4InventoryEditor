# Inventory item for InventoryEditor: MIT License
# @author Vladimir Petrenko
@tool
extends Resource
class_name InventoryItem

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor
var _undo_redo

func set_editor(editor) -> void:
	_editor = editor
	if _editor:
		_undo_redo = _editor.get_undo_redo()
	
const UUID = preload("res://addons/inventory_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

signal name_changed(name)
signal description_changed(description)
signal stacksize_changed
signal icon_changed
signal scene_changed
signal property_added
signal property_removed
signal property_name_changed(property)
signal property_value_changed(property)

@export var uuid: String
@export var type_uuid: String # uuid from InventoryInventory
@export var name: String
@export var description: String
@export var stacksize: int = 1
@export var icon: String
@export var scene: String
@export var properties: Array

func change_name(new_name: String):
	name = new_name
	emit_signal("name_changed")

func change_description(new_description: String):
	description = new_description
	emit_signal("description_changed")

func set_stacksize(new_stacksize: int) -> void:
	stacksize = new_stacksize
	emit_signal("stacksize_changed")

func set_icon(new_icon_path: String) -> void:
	icon = new_icon_path
	emit_signal("icon_changed")

func set_scene(new_scene_path: String) -> void:
	scene = new_scene_path
	emit_signal("scene_changed")

func change_property_name(property, name, sendSignal = true) -> void:
	var old_name = "" + property.name
	if _undo_redo != null:
		_undo_redo.create_action("Change property name")
		_undo_redo.add_do_method(self, "_change_property_name", property, name, sendSignal)
		_undo_redo.add_undo_method(self, "_change_property_name", property, old_name, true)
		_undo_redo.commit_action()
	else:
		_change_property_name(property, name, sendSignal)

func _change_property_name(property, name, sendSignal = true) -> void:
	property.name = name
	if sendSignal:
		emit_signal("property_name_changed", property)

func change_property_value(property, value, sendSignal = true) -> void:
	var old_value = property.value
	if _undo_redo != null:
		_undo_redo.create_action("Change property value")
		_undo_redo.add_do_method(self, "_change_property_value", property, value, sendSignal)
		_undo_redo.add_undo_method(self, "_change_property_value", property, old_value, true)
		_undo_redo.commit_action()
	else:
		_change_property_value(property, value, sendSignal)

func _change_property_value(property, value, sendSignal = true) -> void:
	property.value = value
	if sendSignal:
		emit_signal("property_value_changed", property)

func add_property() -> void:
	var property = _create_property()
	if _undo_redo != null:
		_undo_redo.create_action("Add property")
		_undo_redo.add_do_method(self, "_add_property", property)
		_undo_redo.add_undo_method(self, "_del_property", property)
		_undo_redo.commit_action()
	else:
		_add_property(property)

func _create_property() -> Dictionary:
	return {"uuid": UUID.v4(), "name": _next_property_name(), "value": ""}

func _next_property_name() -> String:
	var base_name = "property"
	var value = -9223372036854775807
	var property_found = false
	if properties:
		for property in properties:
			var name = property.name
			if name.begins_with(base_name):
				property_found = true
				var behind = property.name.substr(base_name.length())
				var regex = RegEx.new()
				regex.compile("^[0-9]+$")
				var result = regex.search(behind)
				if result:
					var new_value = int(behind)
					if  value < new_value:
						value = new_value
	var next_name = base_name
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif property_found:
		next_name += "1"
	return next_name

func _add_property(property, position = properties.size()) -> void:
	properties.insert(position, property)
	emit_signal("property_added")

func del_property(property) -> void:
	if _undo_redo != null:
		var index = properties.find(property)
		_undo_redo.create_action("Del property")
		_undo_redo.add_do_method(self, "_del_property", property)
		_undo_redo.add_undo_method(self, "_add_property", property, index)
		_undo_redo.commit_action()
	else:
		_del_property(property)

func _del_property(property) -> void:
		properties.erase(property)
		emit_signal("property_removed")
