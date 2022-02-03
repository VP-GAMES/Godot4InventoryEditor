# EditorProperty as Inventory for InventoryEditor : MIT License
# @author Vladimir Petrenko
extends EditorProperty
class_name InventoryInspectorEditorInventory

const Dropdown = preload("res://addons/inventory_editor/ui_extensions/dropdown/Dropdown.tscn")

var updating = false
var dropdown = Dropdown.instantiate()
var _data: InventoryData

func set_data(data: InventoryData) -> void:
	_data = data
	_data.inventory_added.connect(_update_dropdown)
	_data.inventory_removed.connect(_update_dropdown)
	_update_dropdown()

func _init():
	add_child(dropdown)
	add_focusable(dropdown)
	dropdown.selection_changed.connect(_on_selection_changed)

func _update_dropdown() -> void:
	dropdown.clear()
	for inventory in _data.inventories:
		var inventory_icon = null
		if inventory.icon != null and not inventory.icon.is_empty():
			inventory_icon = load(inventory.icon)
		var item_d = DropdownItem.new(inventory.name, inventory.uuid, inventory.name, inventory_icon)
		dropdown.add_item(item_d)

func _on_selection_changed(item: DropdownItem):
	if (updating):
		return
	emit_changed(get_edited_property(), item.value)

func _update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	dropdown.set_selected_by_value(new_value)
	updating = false
