# Inventory recipe for InventoryEditor: MIT License
# @author Vladimir Petrenko
@tool
extends InventoryItem
class_name InventoryRecipe

signal ingredient_added
signal ingredient_removed
signal ingredient_value_changed(ingredient)

@export var item: String
@export var ingredients: Array

func change_ingredient_value(ingredient, value, sendSignal = true) -> void:
	var old_value = ingredient.value
	if _undo_redo != null:
		_undo_redo.create_action("Change ingredient value")
		_undo_redo.add_do_method(self, "_change_ingredient_value", ingredient, value, sendSignal)
		_undo_redo.add_undo_method(self, "_change_ingredient_value", ingredient, old_value, true)
		_undo_redo.commit_action()
	else:
		_change_ingredient_value(ingredient, value, sendSignal)

func _change_ingredient_value(ingredient, value, sendSignal = true) -> void:
	ingredient.value = value
	if sendSignal:
		emit_signal("ingredient_value_changed", ingredient)

func add_ingredient() -> void:
	var ingredient = _create_ingredient()
	if _undo_redo != null:
		_undo_redo.create_action("Add ingredient")
		_undo_redo.add_do_method(self, "_add_ingredient", ingredient)
		_undo_redo.add_undo_method(self, "_del_ingredient", ingredient)
		_undo_redo.commit_action()
	else:
		_add_ingredient(ingredient)

func _create_ingredient() -> Dictionary:
	return {"uuid": UUID.v4(), "value": "", "quantity": 1}

func _add_ingredient(ingredient, position = ingredients.size()) -> void:
	ingredients.insert(position, ingredient)
	emit_signal("ingredient_added")

func del_ingredient(ingredient) -> void:
	if _undo_redo != null:
		var index = ingredients.find(ingredient)
		_undo_redo.create_action("Del ingredient")
		_undo_redo.add_do_method(self, "_del_ingredient", ingredient)
		_undo_redo.add_undo_method(self, "_add_ingredient", ingredient, index)
		_undo_redo.commit_action()
	else:
		_del_ingredient(ingredient)

func _del_ingredient(ingredient) -> void:
		ingredients.erase(ingredient)
		emit_signal("ingredient_removed")
