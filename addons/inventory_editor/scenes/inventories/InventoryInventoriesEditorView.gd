# Inventories editor view for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _data: InventoryData
var _split_viewport_size = 0

@onready var _split_ui = $Split
@onready var _inventories_ui = $Split/Inventories
@onready var _inventory_data_ui = $Split/VBoxData/InventoryData
@onready var _hseparator_ui = $Split/VBoxData/HSeparator
@onready var _preview_data_ui = $Split/VBoxData/PreviewData

func set_data(data: InventoryData) -> void:
	_data = data
	_inventories_ui.set_data(data)
	_inventory_data_ui.set_data(data)
	_preview_data_ui.set_data(data)
	_init_connections()
	check_view_visibility()

func _init_connections() -> void:
	if not _split_ui.dragged.is_connected(_on_split_dragged):
		assert(_split_ui.dragged.connect(_on_split_dragged) == OK)
	if not _data.inventory_added.is_connected(_on_inventory_added):
		assert(_data.inventory_added.connect(_on_inventory_added) == OK)
	if not _data.inventory_removed.is_connected(_on_inventory_removed):
		assert(_data.inventory_removed.connect(_on_inventory_removed) == OK)

func _process(delta):
	if _split_viewport_size != rect_size.x:
		_split_viewport_size = rect_size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = InventoryData.SETTINGS_INVENTORIES_SPLIT_OFFSET_DEFAULT
	if _data:
		offset = _data.setting_inventories_split_offset()
	_split_ui.set_split_offset(-rect_size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-rect_size.x / 2 - offset)
		_data.setting_inventories_split_offset_put(value)

func _on_inventory_added(type) -> void:
	check_view_visibility()

func _on_inventory_removed(type) -> void:
	check_view_visibility()

func check_view_visibility() -> void:
	if _data.inventories != null and _data.inventories.size() > 0:
		_inventory_data_ui.show()
		_hseparator_ui.show()
		_preview_data_ui.show()
	else:
		_inventory_data_ui.hide()
		_hseparator_ui.hide()
		_preview_data_ui.hide()
