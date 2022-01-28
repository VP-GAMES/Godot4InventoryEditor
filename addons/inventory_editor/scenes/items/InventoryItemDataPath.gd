# Path UI LineEdit for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends LineEdit

var _item: InventoryItem
var _data: InventoryData

var _path_ui_style_resource: StyleBoxFlat

func set_data(item: InventoryItem, data: InventoryData) -> void:
	_item = item
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	_path_ui_style_resource = StyleBoxFlat.new()
	_path_ui_style_resource.set_bg_color(Color("#192e59"))

func _init_connections() -> void:
	if not _item.icon_changed.is_connected(_on_icon_changed):
		assert(_item.icon_changed.connect(_on_icon_changed) == OK)
	if not focus_entered.is_connected(_on_focus_entered):
		assert(focus_entered.connect(_on_focus_entered) == OK)
	if not focus_exited.is_connected(_on_focus_exited):
		assert(focus_exited.connect(_on_focus_exited) == OK)
	if not text_changed.is_connected(_path_value_changed):
		assert(text_changed.connect(_path_value_changed) == OK)

func _on_icon_changed() -> void:
	_draw_view()

func _draw_view() -> void:
	text = ""
	if _item.icon:
		if has_focus():
			text = _item.icon
		else:
			text = _data.filename(_item.icon)
		_check_path_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _item.icon

func _on_focus_exited() -> void:
	text = _data.filename(_item.icon)

func _path_value_changed(path_value) -> void:
	_item.set_icon(path_value)

func _can_drop_data(position, data) -> bool:
	var path_value = data["files"][0]
	var path_extension = _data.file_extension(path_value)
	for extension in _data.SUPPORTED_IMAGE_RESOURCES:
		if path_extension == extension:
			return true
	return false

func _drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_path_value_changed(path_value)

func _check_path_ui() -> void:
	if _item.icon != null and not _data.resource_exists(_item.icon):
		set("custom_styles/normal", _path_ui_style_resource)
		hint_tooltip =  "Your resource path: \"" + _item.icon + "\" does not exists"
	else:
		set("custom_styles/normal", null)
		hint_tooltip =  ""
