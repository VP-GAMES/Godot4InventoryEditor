# Example implementation for inventory item icon to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends TextureRect

const InventoryManagerName = "InventoryManager"
var _inventoryManager

var _item
var _item_db: InventoryItem

@export var inventory: String # inventory_uuid
@export var type: String # type_uuid
@export var index: int = -1
@export var show_quantity: bool = true

@onready var _quantity_ui = $Quantity as Label

func set_inventory_manager(inv_uuid, manager) -> void:
	inventory = inv_uuid
	_inventoryManager = manager
	_init_connections()
	_update_item()

func _ready() -> void:
	if get_tree().get_root().has_node(InventoryManagerName):
		_inventoryManager = get_tree().get_root().get_node(InventoryManagerName)
		_init_connections()
		_update_item()

func _init_connections() -> void:
	if _inventoryManager:
		if not _inventoryManager.inventory_changed.is_connected(_on_inventory_changed):
			_inventoryManager.inventory_changed.connect(_on_inventory_changed)

func _on_inventory_changed(inv_uuid: String) -> void:
	if inventory == inv_uuid:
		_update_item()

func _update_item() -> void:
	if show_quantity:
		_quantity_ui.show()
	else:
		_quantity_ui.hide()
	
	if _inventoryManager and index >= 0:
		var items = _inventoryManager.get_inventory_items(inventory)
		if items and index < items.size():
			_item = items[index]
			if items[index].has("item_uuid"):
				_item_db = _inventoryManager.get_item_db(items[index].item_uuid)
				if _item_db != null and _item_db.icon != null:
					texture = load(_item_db.icon)
				if _item.quantity:
					_quantity_ui.text = str(_item.quantity)
			else:
				_item = null
				_item_db = null
				texture = null
				_quantity_ui.text = "0"

func _get_drag_data(position: Vector2):
	var drag_texture = TextureRect.new()
	drag_texture.ignore_texture_size = true
	drag_texture.size = Vector2(size)
	drag_texture.texture = texture

	var preview = Control.new()
	preview.add_child(drag_texture)
	drag_texture.position = -0.5 * drag_texture.size
	# https://godotengine.org/qa/30298/drag_preview-get-hide-under-canvaslayer
	set_drag_preview(preview)
	
	var data = {
		"type": "InventoryItem",
		"inventory": inventory,
		"index": index,
		"item": _item,
		"item_db": _item_db
	}
	return data

func _can_drop_data(position: Vector2, data) -> bool:
	if data.has("type") and data["type"] == "InventoryItem":
		if type == null:
			return true
		else:
			return type == data["item_db"].type_uuid
	return false

func _drop_data(position: Vector2, data) -> void:
	if _inventoryManager and data.has("index"):
		_inventoryManager.move_item(data["inventory"], data["index"], inventory, index)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		if _item_db is InventoryRecipe:
			if _inventoryManager.is_craft_possible(inventory, _item_db.uuid):
				_inventoryManager.craft_item(inventory, _item_db.uuid)
