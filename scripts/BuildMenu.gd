extends CanvasLayer

@onready var container = $Panel/ScrollContainer/HBoxContainer

# List of buildings available to build
var buildings = [
	preload("res://resources/buildings/SolarPanel.tres"),
	preload("res://resources/buildings/OxygenGenerator.tres")
]

func _ready():
	populate_menu()

func populate_menu():
	for building_data in buildings:
		var btn = Button.new()
		btn.text = building_data.building_name + "\nCost: " + str(building_data.base_cost)
		btn.custom_minimum_size = Vector2(180, 0)
		btn.pressed.connect(_on_building_button_pressed.bind(building_data))
		container.add_child(btn)

func _on_building_button_pressed(data: BuildingResource):
	print("Selected to build: ", data.building_name)
	BuildingManager.start_placement(data)
