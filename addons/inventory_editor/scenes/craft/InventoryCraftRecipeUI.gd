# Recipe UI for InventoryEditor : MIT License
# @author Vladimir Petrenko
@tool
extends MarginContainer

var _data: InventoryData
var _recipe: InventoryRecipe

var _ui_style_selected: StyleBoxFlat

@onready var _texture_ui = $HBox/Texture as TextureRect
@onready var _name_ui = $HBox/Name as LineEdit
@onready var _del_ui = $HBox/Del as Button

func set_data(recipe: InventoryRecipe, data: InventoryData):
	_recipe = recipe
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(_data.BACKGROUND_COLOR_SELECTED)

func _init_connections() -> void:
	if not _data.recipe_added.is_connected(_on_recipe_added):
		assert(_data.recipe_added.connect(_on_recipe_added) == OK)
	if not _data.recipe_removed.is_connected(_on_recipe_removed):
		assert(_data.recipe_removed.connect(_on_recipe_removed) == OK)
	if not _recipe.icon_changed.is_connected(_on_icon_changed):
		assert(_recipe.icon_changed.connect(_on_icon_changed) == OK)
	if not _data.recipe_selection_changed.is_connected(_on_recipe_selection_changed):
		assert(_data.recipe_selection_changed.connect(_on_recipe_selection_changed) == OK)
	if not _texture_ui.gui_input.is_connected(_on_gui_input):
		assert(_texture_ui.gui_input.connect(_on_gui_input) == OK)
	if not _name_ui.gui_input.is_connected(_on_gui_input):
		assert(_name_ui.gui_input.connect(_on_gui_input) == OK)
	if not _name_ui.focus_exited.is_connected(_on_focus_exited):
		assert(_name_ui.focus_exited.connect(_on_focus_exited) == OK)
	if not _name_ui.text_changed.is_connected(_on_text_changed):
		assert(_name_ui.text_changed.connect(_on_text_changed) == OK)
	if not _del_ui.pressed.is_connected(_del_pressed):
		assert(_del_ui.pressed.connect(_del_pressed) == OK)

func _on_recipe_added(recipe: InventoryRecipe) -> void:
	_draw_style()

func _on_recipe_removed(recipe: InventoryRecipe) -> void:
	_draw_style()

func _on_icon_changed() -> void:
	_draw_view()

func _on_recipe_selection_changed(recipe: InventoryRecipe) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_recipe() == _recipe:
					_data.select_recipe(_recipe)
					_del_ui.grab_focus()
				else:
					_name_ui.set("custom_styles/normal", null)
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER or event.scancode == KEY_KP_ENTER:
			if _name_ui.has_focus():
				_del_ui.grab_focus()

func _on_text_changed(new_text: String) -> void:
	_recipe.change_name(new_text)

func _del_pressed() -> void:
	_data.del_recipe(_recipe)

func _draw_view() -> void:
	_name_ui.text = _recipe.name
	_draw_texture()

func _draw_texture() -> void:
	var texture
	if _recipe.icon != null and not _recipe.icon.is_empty() and _data.resource_exists(_recipe.icon):
		texture = load(_recipe.icon)
		texture = _data.resize_texture(texture, Vector2(16, 16))
	else:
		texture = load("res://addons/inventory_editor/icons/Recipe.png")
	_texture_ui.texture = texture

func _draw_style() -> void:
	if _data.selected_recipe() == _recipe:
		_name_ui.set("custom_styles/normal", _ui_style_selected)
	else:
		_name_ui.set("custom_styles/normal", null)
