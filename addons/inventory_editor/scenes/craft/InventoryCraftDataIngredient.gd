# Inventory recipe data for InventoryEditor: MIT License
# @author Vladimir Petrenko
@tool
extends HBoxContainer

var _ingredient
var _recipe: InventoryRecipe
var _data: InventoryData

@onready var _dropdown_ui = $Dropdown
@onready var _quantity_ui = $Quantity
@onready var _del_ui = $Del

func set_data(ingredient, recipe: InventoryRecipe, data: InventoryData) -> void:
	_ingredient = ingredient
	_recipe = recipe
	_data = data
	_dropdown_ui_init()
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _data.item_added.is_connected(_on_item_added):
		assert(_data.item_added.connect(_on_item_added) == OK)
	if not _data.item_removed.is_connected(_on_item_removed):
		assert(_data.item_removed.connect(_on_item_removed) == OK)
	if not _quantity_ui.text_changed.is_connected(_on_quantity_text_changed):
		assert(_quantity_ui.text_changed.connect(_on_quantity_text_changed) == OK)
	if not _del_ui.pressed.is_connected(_on_del_pressed):
		assert(_del_ui.pressed.connect(_on_del_pressed) == OK)

func _on_item_added(_item) -> void:
	_dropdown_item_update()
	
func _on_item_removed(_item) -> void:
	_dropdown_item_update()

func _dropdown_ui_init() -> void:
	_dropdown_ui.selection_changed.connect(_on_dropdown_item_selection_changed)

func _dropdown_item_update() -> void:
	if _dropdown_ui:
		_dropdown_ui.clear()
		for item in _data.all_items():
			var item_d = DropdownItem.new(item.name, item.uuid, item.name, load(item.icon))
			_dropdown_ui.add_item(item_d)
		_dropdown_ui.set_selected_by_value(_ingredient.uuid)

func _on_dropdown_item_selection_changed(item: DropdownItem):
	_ingredient.uuid = item.value

func _on_quantity_text_changed(new_text: String) -> void:
	_ingredient.quantity = new_text.to_int()

func _on_del_pressed() -> void:
	_recipe.del_ingredient(_ingredient)

func _draw_view() -> void:
	_draw_view_quantity()
	_dropdown_item_update()

func _draw_view_quantity() -> void:
	_quantity_ui.text = str(_ingredient.quantity)
