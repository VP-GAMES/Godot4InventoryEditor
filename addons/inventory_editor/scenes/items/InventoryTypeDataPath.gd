# Path UI LineEdit for InventoryEditor : MIT License
# @author Vladimir Petrenko
# Drag and drop not work just now, see Workaround -> InventoryTypeDataPut
# https://github.com/godotengine/godot/issues/30480
@tool
extends LineEdit

var _type: InventoryType
var _data: InventoryData

var _path_ui_style_resource: StyleBoxFlat

const InventoryTypeDataResourceDialogFile = preload("res://addons/inventory_editor/scenes/items/InventoryTypeDataResourceDialogFile.tscn")

func set_data(type: InventoryType, data: InventoryData) -> void:
	_type = type
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	_path_ui_style_resource = StyleBoxFlat.new()
	_path_ui_style_resource.set_bg_color(Color("#192e59"))

func _init_connections() -> void:
	if _type != null and not _type.icon_changed.is_connected(_on_icon_changed):
		assert(_type.icon_changed.connect(_on_icon_changed) == OK)
	if not focus_entered.is_connected(_on_focus_entered):
		assert(focus_entered.connect(_on_focus_entered) == OK)
	if not focus_exited.is_connected(_on_focus_exited):
		assert(focus_exited.connect(_on_focus_exited) == OK)
	if not text_changed.is_connected(_path_value_changed):
		assert(text_changed.connect(_path_value_changed) == OK)
	if not gui_input.is_connected(_on_gui_input):
		assert(gui_input.connect(_on_gui_input) == OK)

func _on_icon_changed() -> void:
	_draw_view()

func _draw_view() -> void:
	text = ""
	if _type != null and _type.icon != null:
		if has_focus():
			text = _type.icon
		else:
			text = _data.filename(_type.icon)
		_check_path_ui()

func _input(event) -> void:
	if (event is InputEventMouseButton) and event.pressed:
		if not get_global_rect().has_point(event.position):
			release_focus()

func _on_focus_entered() -> void:
	text = _type.icon

func _on_focus_exited() -> void:
	text = _data.filename(_type.icon)

func _path_value_changed(path_value) -> void:
	_type.set_icon(path_value)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				grab_focus()
				var file_dialog = InventoryTypeDataResourceDialogFile.instantiate()
				if _data.resource_exists(_type.icon):
					file_dialog.current_dir = _data.file_path(_type.icon)
					file_dialog.current_file = _data.filename(_type.icon)
				for extension in _data.SUPPORTED_IMAGE_RESOURCES:
					file_dialog.add_filter("*." + extension)
				var root = get_tree().get_root()
				root.add_child(file_dialog)
				assert(file_dialog.file_selected.connect(_path_value_changed) == OK)
				assert(file_dialog.popup_hide.connect(_on_popup_hide, [root, file_dialog]) == OK)
				file_dialog.popup_centered()

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()

func can_drop_data(position, data) -> bool:
	var path_value = data["files"][0]
	var path_extension = _data.file_extension(path_value)
	for extension in _data.supported_file_extensions():
		if path_extension == extension:
			return true
	return false

func drop_data(position, data) -> void:
	var path_value = data["files"][0]
	_path_value_changed(path_value)

func _check_path_ui() -> void:
	if _type.icon != null and not _data.resource_exists(_type.icon):
		set("custom_styles/normal", _path_ui_style_resource)
		hint_tooltip =  "Your resource path: \"" + _type.icon + "\" does not exists"
	else:
		set("custom_styles/normal", null)
		hint_tooltip =  ""
