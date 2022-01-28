# Inventory type data UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer

var _type: InventoryType
var _data: InventoryData

@onready var _data_ui = $MarginData as MarginContainer
@onready var _preview_ui = $MarginPreview as MarginContainer
@onready var _icon_ui = $MarginData/VBox/HBoxIcon/Icon as LineEdit
@onready var _icon_preview_ui = $MarginData/VBox/HBoxContainer/Texture as TextureRect

func set_data(data: InventoryData) -> void:
	_data = data
	_type = _data.selected_type()
	_init_connections()
	_init_connections_type()
	_draw_view()

func _init_connections() -> void:
	if not _data.type_selection_changed.is_connected(_on_type_selection_changed):
		assert(_data.type_selection_changed.connect(_on_type_selection_changed) == OK)

func _on_type_selection_changed(type: InventoryType) -> void:
	_type = _data.selected_type()
	_init_connections_type()
	_draw_view()

func _init_connections_type() -> void:
	if _type:
		if not _type.icon_changed.is_connected(_on_icon_changed):
			assert(_type.icon_changed.connect(_on_icon_changed) == OK)

func _on_icon_changed() -> void:
	_draw_view_icon_preview_ui()

func _draw_view() -> void:
		_update_view_data()
		_draw_view_icon_preview_ui()

func _update_view_data() -> void:
	_icon_ui.set_data(_type, _data)

func _draw_view_icon_preview_ui() -> void:
	var t = load("res://addons/inventory_editor/icons/Type.png")
	if _type != null and _type.icon != null and _data.resource_exists(_type.icon):
		t = load(_type.icon)
		t = _data.resize_texture(t, Vector2(100, 100))
	_icon_preview_ui.texture = t
