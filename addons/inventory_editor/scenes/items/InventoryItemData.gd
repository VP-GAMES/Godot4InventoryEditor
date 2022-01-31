# Inventory item data UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer

var _item: InventoryItem
var _data: InventoryData
var localization_editor

@onready var _data_ui = $MarginData
@onready var _stacksize_ui = $MarginData/VBox/HBox/VBox/HBoxStack/Stacksize as LineEdit
@onready var _icon_ui = $MarginData/VBox/HBox/VBox/HBoxIcon/Icon as LineEdit
@onready var _add_ui = $MarginData/VBox/HBoxAdd/Add as Button
@onready var _scene_ui = $MarginData/VBox/HBox/VBox/HBoxScene/Scene as LineEdit
@onready var _open_ui = $MarginData/VBox/HBox/VBox/HBoxScene/Open as Button
@onready var _description_ui =$MarginData/VBox/HBox/VBox/HBoxDescription/Description as TextEdit
@onready var _dropdown_description_ui = $MarginData/VBox/HBox/VBox/HBoxDescription/Dropdown
@onready var _properties_ui = $MarginData/VBox/VBoxProperties as VBoxContainer
@onready var _icon_preview_ui = $MarginData/VBox/HBox/VBoxIcon/Texture as TextureRect

const InventoryItemDataProperty = preload("res://addons/inventory_editor/scenes/items/InventoryItemDataProperty.tscn")

func set_data(data: InventoryData) -> void:
	_data = data
	_item = _data.selected_item()
	_init_connections()
	_init_connections_item()
	_draw_view()
	_update_view_visibility()

func _process(delta: float) -> void:
	if not localization_editor:
		_dropdown_ui_init()

func _dropdown_ui_init() -> void:
	if not localization_editor:
		localization_editor = get_tree().get_root().find_node("LocalizationEditor", true, false)
	if localization_editor:
		var data = localization_editor.get_data()
		if data:
			if not data.data_changed.is_connected(_on_localization_data_changed):
				data.data_changed.connect(_on_localization_data_changed)
			if not data.data_key_value_changed.is_connected(_on_localization_data_changed):
				data.data_key_value_changed.connect(_on_localization_data_changed)
			_on_localization_data_changed()

func _on_localization_data_changed() -> void:
	_fill_dropdown_description_ui()

func _fill_dropdown_description_ui() -> void:
	if _dropdown_description_ui:
		_dropdown_description_ui.clear()
		for key in localization_editor.get_data().data.keys:
			_dropdown_description_ui.add_item_as_string(key.value)
		_dropdown_description_ui.set_selected_by_value(_item.description)

func _init_connections() -> void:
	if not _data.type_selection_changed.is_connected(_on_type_selection_changed):
		assert(_data.type_selection_changed.connect(_on_type_selection_changed) == OK)
	if not _data.item_selection_changed.is_connected(_on_item_selection_changed):
		assert(_data.item_selection_changed.connect(_on_item_selection_changed) == OK)
	if not _stacksize_ui.text_changed.is_connected(_on_stacksize_text_changed):
		assert(_stacksize_ui.text_changed.connect(_on_stacksize_text_changed) == OK)
	if not _open_ui.pressed.is_connected(_on_open_pressed):
		assert(_open_ui.pressed.connect(_on_open_pressed) == OK)
	if not _description_ui.text_changed.is_connected(_on_description_text_changed):
		assert(_description_ui.text_changed.connect(_on_description_text_changed) == OK)
	if not _add_ui.pressed.is_connected(_on_add_pressed):
		assert(_add_ui.pressed.connect(_on_add_pressed) == OK)
	if _data.setting_localization_editor_enabled():
		if not _dropdown_description_ui.selection_changed.is_connected(_on_selection_changed_description):
			assert(_dropdown_description_ui.selection_changed.connect(_on_selection_changed_description) == OK)

func _on_type_selection_changed(type: InventoryType) -> void:
	_update_selection_view()

func _on_item_selection_changed(item: InventoryItem) -> void:
	_update_selection_view()

func _update_selection_view() -> void:
	_item = _data.selected_item()
	_init_connections_item()
	_draw_view()

func _on_selection_changed_description(item: DropdownItem) -> void:
	_item.description = item.value

func _init_connections_item() -> void:
	if _item:
		if not _item.icon_changed.is_connected(_on_icon_changed):
			assert(_item.icon_changed.connect(_on_icon_changed) == OK)
		if not _item.property_added.is_connected(_on_property_added):
			assert(_item.property_added.connect(_on_property_added) == OK)
		if not _item.property_removed.is_connected(_on_property_removed):
			assert(_item.property_removed.connect(_on_property_removed) == OK)

func _on_icon_changed() -> void:
	_draw_view_icon_preview_ui()

func _on_property_added() -> void:
	_draw_view_properties_ui()

func _on_property_removed() -> void:
	_draw_view_properties_ui()

func _on_stacksize_text_changed(new_text: String) -> void:
	_item.set_stacksize(new_text.to_int())

func _on_open_pressed() -> void:
	if _item != null and _item.scene != null:
		var scene = load(_item.scene).instantiate()
		if scene:
			var mainscreen
			if scene.is_class("Node3D"):
				mainscreen = "3D"
			elif scene.is_class("Control") or scene.is_class("Node2D"):
				mainscreen = "2D"
			if mainscreen: 
				_data.editor().get_editor_interface().set_main_screen_editor(mainscreen)
		_data.editor().get_editor_interface().open_scene_from_path(_item.scene)

func _on_description_text_changed() -> void:
	_item.change_description(_description_ui.text)

func _on_add_pressed() -> void:
	_item.add_property()
	_draw_view_properties_ui()

func _update_view_visibility() -> void:
	if _data.setting_localization_editor_enabled():
		_description_ui.hide()
		_dropdown_description_ui.show()
	else:
		_description_ui.show()
		_dropdown_description_ui.hide()

func _draw_view() -> void:
	check_view_visibility()
	if _item:
		_update_view_data()
		_draw_view_stacksize_ui()
		_draw_view_description_ui()
		_draw_view_properties_ui()
		_draw_view_icon_preview_ui()

func check_view_visibility() -> void:
	if _item:
		_data_ui.show()
	else:
		_data_ui.hide()

func _update_view_data() -> void:
	_icon_ui.set_data(_item, _data)
	_scene_ui.set_data(_item, _data)

func _draw_view_stacksize_ui() -> void:
	_stacksize_ui.text = str(_item.stacksize)

func _draw_view_description_ui() -> void:
	_description_ui.text = _item.description
	_dropdown_description_ui.set_selected_by_value(_item.description)

func _draw_view_properties_ui() -> void:
	_clear_view_properties()
	_draw_view_properties()

func _draw_view_properties() -> void:
	for property in _item.properties:
		_draw_property(property)

func _draw_property(property) -> void:
	var property_ui = InventoryItemDataProperty.instantiate()
	_properties_ui.add_child(property_ui)
	property_ui.set_data(property, _item)

func _clear_view_properties() -> void:
	for property_ui in _properties_ui.get_children():
		_properties_ui.remove_child(property_ui)
		property_ui.queue_free()

func _draw_view_icon_preview_ui() -> void:
	var t = load("res://addons/inventory_editor/icons/Item.png")
	if _item != null and _item.icon != null and _data.resource_exists(_item.icon):
		t = load(_item.icon)
		t = _data.resize_texture(t, Vector2(100, 100))
	_icon_preview_ui.texture = t
