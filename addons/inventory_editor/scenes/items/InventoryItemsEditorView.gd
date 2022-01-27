# Inventory items view for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends VBoxContainer

var _data: InventoryData
var _split_viewport_size = 0

@onready var _split_ui = $Split
@onready var _items_ui = $Split/Items
@onready var _itemsdata_ui = $Split/ItemsData

func set_data(data: InventoryData) -> void:
	_data = data
	_items_ui.set_data(data)
	_itemsdata_ui.set_data(_data)
	_init_connections()

func _init_connections() -> void:
	if not _split_ui.dragged.is_connected(_on_split_dragged):
		assert(_split_ui.dragged.connect(_on_split_dragged) == OK)

func _process(delta):
	if _split_viewport_size != rect_size.x:
		_split_viewport_size = rect_size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = InventoryData.SETTINGS_ITEMS_SPLIT_OFFSET_DEFAULT
	if _data:
		offset = _data.setting_items_split_offset()
	_split_ui.set_split_offset(-rect_size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-rect_size.x / 2 - offset)
		_data.setting_items_split_offset_put(value)
