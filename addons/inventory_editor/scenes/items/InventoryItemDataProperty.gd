# Inventory item data for InventoryEditor: MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer

var _property
var _item: InventoryItem

@onready var _name_ui = $Name
@onready var _value_ui = $HBox/Value
@onready var _del_ui = $HBox/Del

func set_data(property, item: InventoryItem) -> void:
	_property = property
	_item = item
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _name_ui.text_changed.is_connected(_on_name_text_changed):
		assert(_name_ui.text_changed.connect(_on_name_text_changed) == OK)
	if not _value_ui.text_changed.is_connected(_on_value_text_changed):
		assert(_value_ui.text_changed.connect(_on_value_text_changed) == OK)
	if not _item.property_name_changed.is_connected(_on_property_name_changed):
		assert(_item.property_name_changed.connect(_on_property_name_changed) == OK)
	if not _item.property_value_changed.is_connected(_on_property_value_changed):
		assert(_item.property_value_changed.connect(_on_property_value_changed) == OK)
	if not _del_ui.pressed.is_connected(_on_del_pressed):
		assert(_del_ui.pressed.connect(_on_del_pressed) == OK)

func _on_name_text_changed(new_text: String) -> void:
	_item.change_property_name(_property, new_text, false)

func _on_value_text_changed(new_text: String) -> void:
	_item.change_property_value(_property, new_text, false)

func _on_property_name_changed(property) -> void:
	if _property == property:
		_draw_view_name()

func _on_property_value_changed(property) -> void:
	if _property == property:
		_draw_view_value()

func _on_del_pressed() -> void:
	_item.del_property(_property)

func _draw_view() -> void:
	_draw_view_name()
	_draw_view_value()

func _draw_view_name() -> void:
	_name_ui.text = _property.name

func _draw_view_value() -> void:
	_value_ui.text = _property.value
