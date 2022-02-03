# EditorProperty as Item for InventoryEditor : MIT License
# @author Vladimir Petrenko
extends EditorProperty
class_name InventoryInspectorEditorItem

const Dropdown = preload("res://addons/inventory_editor/ui_extensions/dropdown/Dropdown.tscn")

var updating = false
var dropdown = Dropdown.instantiate()
var _data: InventoryData
var _object

func set_data(data: InventoryData, object) -> void:
	_data = data
	_object = object
	_data.type_added.connect(_update_dropdown)
	_data.type_removed.connect(_update_dropdown)
	_update_dropdown()
	
func _init():
	add_child(dropdown)
	add_focusable(dropdown)
	dropdown.selection_changed.connect(_on_selection_changed)

func _update_dropdown() -> void:
	dropdown.clear()
	for item in _data.all_items():
		if item != null and item.scene != null:
			var scene = load(item.scene).instantiate()
			var item_icon = null
			if item.icon != null and not item.icon.is_empty():
				item_icon = load(item.icon)
			var item_d = DropdownItem.new(item.name, item.uuid, item.name, item_icon)
			if _object is Item2D and scene is Node2D:
				dropdown.add_item(item_d)
			if _object is Item3D and scene is Node3D:
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
