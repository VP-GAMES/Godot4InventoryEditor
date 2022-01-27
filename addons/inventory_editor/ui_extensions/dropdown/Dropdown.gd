# UI Extension Filter Dropdown : MIT License
# @author Vladimir Petrenko
@tool
extends LineEdit

signal selection_changed(item)

var selected = -1
@export var popup_maxheight = 0

var _group = ButtonGroup.new()
var _filter: String = ""
var _items = [] # item {"text": null, "value": null, "icon": null }

@onready var _popup_panel: PopupPanel= $PopupPanel
@onready var _popup_panel_vbox: VBoxContainer= $PopupPanel/Scroll/VBox

const DropdownCheckBox = preload("DropdownCheckBox.tscn")

func clear() -> void:
	_items.clear()

func items() -> Array[String]:
	return _items

func add_item(item: Dictionary) -> void:
	_items.append(item)

func get_selected() -> int:
	return selected

func set_selected(index: int) -> void:
	selected = index
	text = _items[selected].text

func set_selected_by_value(value) -> void:
	text = ""
	for index in range(_items.size()):
		if _items[index].value == value:
			selected = index
			text = _items[selected].text

func _ready() -> void:
	_group.resource_local_to_scene = false
	_init_connections()

func _init_connections() -> void:
	if gui_input.connect(_line_edit_gui_input) != OK:
		push_warning("_popup_panel gui_input not connected")
	if text_changed.connect(_on_text_changed) != OK:
		push_warning("_popup_panel text_changed not connected")
 
func _popup_panel_focus_entered() -> void:
	grab_focus()

func _popup_panel_index_pressed(index: int) -> void:
	var text = _popup_panel.get_item_text(index)
	text = text
	_filter = text
	selected = _items.find(text)

func _line_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_update_popup_view()

func _on_text_changed(filter: String) -> void:
	_filter = filter
	_update_popup_view(_filter)

func _update_popup_view(filter = "") -> void:
	_update_items_view(filter)
	var rect = get_global_rect()
	var position =  Vector2(rect.position.x, rect.position.y + rect.size.y)
	var size = Vector2(rect.size.x, popup_maxheight)
	_popup_panel.popup(Rect2(position, size))
	grab_focus()

func _update_items_view(filter = "") -> void:
	for child in _popup_panel_vbox.get_children():
		_popup_panel_vbox.remove_child(child)
		child.queue_free()
	for index in range(_items.size()):
		if filter.empty():
			_popup_panel_vbox.add_child(_init_check_box(index))
		else:
			if filter in _items[index].text:
				_popup_panel_vbox.add_child(_init_check_box(index))

func _init_check_box(index: int) -> CheckBox:
	var check_box = DropdownCheckBox.instance()
	check_box.set_button_group(_group)
	check_box.text = _items[index].text
	if _items[index].has("icon") and _items[index].icon:
		var item_icon = load(_items[index].icon)
		item_icon = resize_texture(item_icon, Vector2(16, 16))
		check_box.icon = item_icon
	if index == selected:
		check_box.set_pressed(true)
	check_box.connect("pressed", self, "_on_selection_changed", [index])
	return check_box

func _on_selection_changed(index: int) -> void:
	if selected != index:
		selected = index
		_filter = _items[selected].text
		text = _filter
		emit_signal("selection_changed", _items[selected])
	_popup_panel.hide()
	
func resize_texture(t: Texture, size: Vector2):
	var itex = t
	if itex:
		var texture = t.get_data()
		if size.x > 0 && size.y > 0:
			texture.resize(size.x, size.y)
		itex = ImageTexture.new()
		itex.create_from_image(texture)
	return itex
