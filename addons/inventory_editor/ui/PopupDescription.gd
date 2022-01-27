# Example implementation for inventory item popup to demonstrate functionality of InventoryEditor : MIT License
# @author Vladimir Petrenko
extends Popup
var _localization_manager_name = "LocalizationManager"
var _localization_manager

@onready var _label = $Label as RichTextLabel

func _ready() -> void:
	if not _localization_manager:
		if get_tree().get_root().has_node(_localization_manager_name):
			_localization_manager = get_tree().get_root().get_node(_localization_manager_name)

func update_item_data(item: InventoryItem) -> void:
	var text = item.description
	if _localization_manager:
		text = _localization_manager.tr(text)
	_label.bbcode_text = text
