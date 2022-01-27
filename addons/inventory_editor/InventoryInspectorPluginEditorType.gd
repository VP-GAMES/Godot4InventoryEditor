# EditorProperty as Type for InventoryEditor : MIT License
# @author Vladimir Petrenko
extends EditorProperty
class_name InventoryInspectorEditorType

const Dropdown = preload("res://addons/inventory_editor/ui_extensions/dropdown/Dropdown.tscn")
const TypeIconPath = "res://addons/inventory_editor/icons/Type.png"
const TypeIcon = preload(TypeIconPath)

var updating = false
var hBox = HBoxContainer.new()
var textureRect = TextureRect.new()
var dropdown = Dropdown.instance()
var _data: InventoryData
var _items: Array

func set_data(data: InventoryData) -> void:
	_data = data
	_items = _data.types
	
func _init():
	textureRect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	hBox.add_child(textureRect)
	hBox.add_child(dropdown)
	add_child(hBox)
	add_focusable(dropdown)
	dropdown.connect("gui_input", self, "_on_gui_input")
	dropdown.connect("selection_changed", self, "_on_selection_changed")

func _on_gui_input(event: InputEvent) -> void:
	_items = _data.types
	dropdown.clear()
	dropdown.add_item({"text": "Any", "value": null, "icon": TypeIconPath })
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
	var item_icon = TypeIcon
	if item:
		if item.icon:
			item_icon = load(item.icon)
		if item.text:
			dropdown.text = item.text
	item_icon = _data.resize_texture(item_icon, Vector2(16, 16))
	textureRect.texture = item_icon
	updating = false

func item_by_uuid(uuid) -> Dictionary:
	for item in _items:
		if item.uuid == uuid:
			return {"text": item.name, "value": item.uuid, "icon": item.icon }
	return {"text": "Any", "value": null, "icon": TypeIconPath }
