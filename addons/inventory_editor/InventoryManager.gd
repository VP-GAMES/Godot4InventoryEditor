# Service to manage game inventories and items
# Please add this script to Project -> Project Settings -> AutoLoad
# to use this manager as singleton
# @author Vladimir Petrenko
@tool
extends Node

signal inventory_changed(inventory_uuid)

var _db = InventoryData.new()
var player

var _path_to_type = "user://inventory.tres"
var _data = InventoryInventories.new()

func ready(db: InventoryData) -> void:
	_db = db
	_init_db()

func _ready() -> void:
	_db.init_data()
	load_data()

func _init_db() -> void:
	if not _db.inventory_stacks_changed.is_connected(_on_inventory_stacks_changed):
		_db.inventory_stacks_changed.connect(_on_inventory_stacks_changed)

func _on_inventory_stacks_changed(inventory) -> void:
	emit_signal("inventory_changed", inventory.uuid)

func load_data() -> void:
	var file = File.new()
	if file.file_exists(_path_to_type):
		var loaded_data = load(_path_to_type)
		if loaded_data:
			_data.inventories = loaded_data.inventories

func save() -> void:
	var state = ResourceSaver.save(_path_to_type, _data)
	if state != OK:
		printerr("Can't save inventories data")

func get_inventory_by_name_items(inventory_name: String) -> Array:
	var inventory = _db.get_inventory_by_name(inventory_name)
	return get_inventory_items(inventory.uuid)

func get_inventory_items(inventory_uuid: String) -> Array:
	var items = []
	if _data.inventories.has(inventory_uuid):
		items = _data.inventories[inventory_uuid]
	return items

func clear_inventory_by_name(inventory_name: String) -> void:
	var inventory = _db.get_inventory_by_name(inventory_name)
	clear_inventory(inventory.uuid)

func clear_inventory(inventory_uuid: String) -> void:
	var items
	if _data.inventories.has(inventory_uuid):
		items = _data.inventories[inventory_uuid]
		for index in range(items.size()):
			items[index] = {}
		emit_signal("inventory_changed", inventory_uuid)

func add_item_by_name(inventory_name: String, item_name: String, quantity: int = 1) -> int:
	var inventory = _db.get_inventory_by_name(inventory_name)
	var item = _db.get_inventory_by_name(item_name)
	return add_item(inventory.uuid, item.uuid, quantity)

func add_item(inventory_uuid: String, item_uuid: String, quantity: int = 1, save = true) -> int:
	var remainder = 0 
	if(quantity < 0):
		printerr("Can't add negative number of items")
		return remainder
	var db_item = _db.get_item_by_uuid(item_uuid)
	if not db_item:
		printerr("Can't find item in itemlist")
		return remainder
	if _data.inventories.has(inventory_uuid):
		var items = _data.inventories[inventory_uuid]
		var item
		for index in range(items.size()):
			if items[index].has("item_uuid") and items[index].item_uuid == item_uuid:
				item = items[index]
				break
		if item:
			if item.quantity + quantity > db_item.stacksize:
				remainder = item.quantity + quantity - db_item.stacksize
			var quantity_calc = min(item.quantity + quantity, db_item.stacksize)
			item.quantity = quantity_calc
		else:
			if quantity > db_item.stacksize:
				remainder = quantity - db_item.stacksize
			var quantity_calc = min(quantity, db_item.stacksize)
			var inventory_db = get_inventory_db(inventory_uuid) as InventoryInventory
			for index in range(inventory_db.stacks):
				if not items[index].has("item_uuid"):
					items[index] = {"item_uuid": item_uuid, "quantity": quantity_calc}
					break
	else:
		create_inventory(inventory_uuid)
		if quantity > db_item.stacksize:
			remainder = quantity - db_item.stacksize
		var quantity_calc = min(quantity, db_item.stacksize)
		_data.inventories[inventory_uuid][0] = {"item_uuid": item_uuid, "quantity": quantity_calc}
	if save:
		save()
	emit_signal("inventory_changed", inventory_uuid)
	return remainder

func create_inventory(inventory_uuid:String) -> void:
	var inventory_db = get_inventory_db(inventory_uuid) as InventoryInventory
	var items = []
	for index in range(inventory_db.stacks):
		items.append({})
	_data.inventories[inventory_uuid] = items

func get_item_properties_by_name(item_name: String) -> Array:
	return _db.get_item_by_name(item_name).properties

func get_item_properties(item_uuid: String) -> Array:
	return _db.get_item_by_uuid(item_uuid).properties

func get_item_db(item_uuid: String) -> InventoryItem:
	return _db.get_item_by_uuid(item_uuid)

func get_type_db(type_uuid: String) -> InventoryType:
	return _db.get_type_by_uuid(type_uuid)

func get_inventory_db(inventory_uuid: String) -> InventoryInventory:
	return _db.get_inventory_by_uuid(inventory_uuid)

func remove_item_by_name(inventory_name: String, item_name: String, quantity: int = 1) -> void:
	var inventory = _db.get_inventory_by_name(inventory_name)
	var item = _db.get_inventory_by_name(item_name)
	remove_item(inventory.uuid, item.uuid, quantity)

func remove_item(inventory_uuid: String, item_uuid: String, quantity: int = 1, save = true) -> int:
	if(quantity < 0):
		printerr("Can't remove negative number of items")
	if _data.inventories.has(inventory_uuid):
		var items = _data.inventories[inventory_uuid]
		for index in range(items.size()):
			var item = items[index]
			if item.has("item_uuid") and item.item_uuid == item_uuid:
				if item.quantity > quantity:
					item.quantity -= quantity
				else:
					items[index] = {}
				if save:
					save()
				emit_signal("inventory_changed", inventory_uuid)
				return index
	return -1

func move_item_by_names(inventory_name_from: String, from_index: int, inventory_name_to: String, to_index: int) -> void:
	var inventory_from = _db.get_inventory_by_name(inventory_name_from)
	var inventory_to = _db.get_inventory_by_name(inventory_name_to)
	move_item(inventory_from.uuid, from_index, inventory_to.uuid, to_index)

func move_item(inventory_uuid_from: String, from_index: int, inventory_uuid_to: String, to_index: int) -> void:
	if not _data.inventories.has(inventory_uuid_to):
		create_inventory(inventory_uuid_to)
	if _data.inventories.has(inventory_uuid_from) and _data.inventories.has(inventory_uuid_to):
		if inventory_uuid_from == inventory_uuid_to:
			_move_in_same_inventory(inventory_uuid_from, from_index, to_index)
		else:
			_move_to_other_inventory(inventory_uuid_from, from_index, inventory_uuid_to, to_index)

func _move_in_same_inventory(inventory_uuid: String, from_index: int, to_index: int) -> void:
		var items = _data.inventories[inventory_uuid]
		var from = items[from_index]
		var to = items[to_index]
		items[to_index] = from
		items[from_index] = to
		emit_signal("inventory_changed", inventory_uuid)

func _move_to_other_inventory(inventory_uuid_from: String, from_index: int, inventory_uuid_to: String, to_index: int) -> void:
	var items_from = _data.inventories[inventory_uuid_from]
	var items_to = _data.inventories[inventory_uuid_to]
	var item_from = items_from[from_index]
	var item_to = items_to[to_index]

	if items_to[to_index].has("item_uuid"):
		items_to[to_index] = item_from
		items_from[from_index] = item_to
	else:
		items_to[to_index] = item_from
		items_from[from_index] = {}
	emit_signal("inventory_changed", inventory_uuid_from)
	emit_signal("inventory_changed", inventory_uuid_to)

func inventory_has_item_by_name(inventory_name: String, item_name: String) -> bool:
	return inventory_item_quantity_by_name(inventory_name, item_name) > 0

func inventory_has_item(inventory_uuid: String, item_uuid: String) -> bool:
	return inventory_item_quantity(inventory_uuid, item_uuid) > 0

func inventory_item_quantity_by_name(inventory_name: String, item_name: String) -> int:
	var inventory = _db.get_inventory_by_name(inventory_name)
	var item = _db.get_inventory_by_name(item_name)
	return inventory_item_quantity(inventory.uuid, item.uuid)

func inventory_item_quantity(inventory_uuid: String, item_uuid: String) -> int:
	var quantity = 0
	if _data.inventories.has(inventory_uuid):
		var items = _data.inventories[inventory_uuid]
		var item
		for index in range(items.size()):
			if items[index].has("item_uuid") and items[index].item_uuid == item_uuid:
				item = items[index]
				break
		if item and item.quantity:
			quantity = item.quantity
	return quantity

func has_item_by_name(item_name: String) -> bool:
	var item = _db.get_inventory_by_name(item_name)
	return has_item_quantity(item.uuid) > 0

func has_item(item_uuid: String) -> bool:
	return has_item_quantity(item_uuid) > 0

func has_item_quantity_by_name(item_name: String) -> int:
	var item = _db.get_inventory_by_name(item_name)
	return has_item_quantity(item.uuid)

func has_item_quantity(item_uuid: String) -> int:
	var quantity = 0
	for items in _data.inventories.values():
		var item
		for index in range(items.size()):
			if items[index].has("item_uuid") and items[index].item_uuid == item_uuid:
				item = items[index]
				break
		if item and item.quantity:
			quantity = item.quantity
	return quantity

func is_craft_possible(inventory_uuid, recipe_uuid) -> bool:
	var recipe_db = get_item_db(recipe_uuid)
	for ingridient in recipe_db.ingredients:
		if ingridient.quantity > inventory_item_quantity(inventory_uuid, ingridient.uuid):
			return false
	return true

func craft_item(inventory_uuid, recipe_uuid) -> void:
	var recipe_db = get_item_db(recipe_uuid)
	for ingridient in recipe_db.ingredients:
		remove_item(inventory_uuid, ingridient.uuid, ingridient.quantity, false)
	if inventory_has_item(inventory_uuid, recipe_db.item):
		add_item(inventory_uuid, recipe_db.item, 1, false)
		remove_item(inventory_uuid, recipe_db.uuid, 1)
	elif inventory_item_quantity(inventory_uuid, recipe_db.uuid) > 0:
		remove_item(inventory_uuid, recipe_db.uuid, 1, false)
		add_item(inventory_uuid, recipe_db.item, 1)
	else:
		var index = remove_item(inventory_uuid, recipe_db.uuid, 1)
		_data.inventories[inventory_uuid][index] = {"item_uuid": recipe_db.item, "quantity": 1}
	emit_signal("inventory_changed", inventory_uuid)
