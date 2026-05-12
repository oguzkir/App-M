extends Node

# Singleton: ResourceManager

signal resources_changed(new_resources)

var resources = {
	"energy": 100,
	"oxygen": 100,
	"water": 100,
	"food": 100,
	"isotopes": 50
}

func add_resource(type: String, amount: int):
	if resources.has(type):
		resources[type] += amount
		emit_signal("resources_changed", resources)

func consume_resource(type: String, amount: int) -> bool:
	if resources.has(type) and resources[type] >= amount:
		resources[type] -= amount
		emit_signal("resources_changed", resources)
		return true
	return false

func get_resource(type: String) -> int:
	if resources.has(type):
		return resources[type]
	return 0
