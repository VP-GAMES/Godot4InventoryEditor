extends UnitTest
class_name TestInventoryInventories

func _get_class_name() -> String:
	return "InventoryInventories"

func _test_create_InventoryInventories() -> void:
	var inventoryInventories: InventoryInventories = InventoryInventories.new()
	assertNotNull(inventoryInventories)
	assertNotNull(inventoryInventories.inventories)
	assertTrue(inventoryInventories.inventories.is_empty())
