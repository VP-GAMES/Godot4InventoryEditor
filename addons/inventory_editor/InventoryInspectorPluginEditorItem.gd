# EditorProperty as Item for InventoryEditor : MIT License
# @author Vladimir Petrenko
extends EditorProperty
class_name InventoryInspectorEditorItem

const Dropdown = preload("res://addons/inventory_editor/ui_extensions/dropdown/Dropdown.tscn")
const ItemIcon = preload("res://addons/inventory_editor/icons/Item.png")

var updating = false
var hBox = HBoxContainer.new()
var textureRect = TextureRect.new()
var dropdown = Dropdown.instantiate()
var _data: InventoryData
var _items: Array
var _object

func set_data(data: InventoryData, object) -> void:
	_data = data
	_object = object
	_update_items()

func _update_items() -> void:
	_items = []
	for item in _data.all_items():
		if item and item.scene:
			var scene = load(item.scene).instantiate()
			if _object is Item2D and scene is Node2D:
				_items.append(item)
			if _object is Item3D and scene is Node3D:
				_items.append(item)
	
func _init():
	textureRect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	hBox.add_child(textureRect)
	hBox.add_child(dropdown)
	add_child(hBox)
	add_focusable(dropdown)
	dropdown.selection_changed.connect(_on_selection_changed)

func _on_gui_input(event: InputEvent) -> void:
	_update_items()
	dropdown.clear()
	for item in _items:
		var item_d = {"text": item.name, "value": item.uuid, "icon": item.icon }
		dropdown.add_item(item_d)

func _on_selection_changed(item: Dictionary):
	if (updating):
		return
	emit_changed(get_edited_property(), item.value)

func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	var item = item_by_uuid(new_value)
	var item_icon = ItemIcon
	if item:
		if item.icon:
			item_icon = load(item.icon)
		if item.text:
			dropdown.text = item.text
	item_icon = _data.resize_texture(item_icon, Vector2(16, 16))
	textureRect.texture = item_icon
	updating = false

func item_by_uuid(uuid: String) -> Dictionary:
	for item in _items:
		if item.uuid == uuid:
			return {"text": item.name, "value": item.uuid, "icon": item.icon }
	return {"text": null, "value": null, "icon": null }
