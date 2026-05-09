extends CanvasLayer

@onready var energy_label = $Panel/HBoxContainer/EnergyLabel
@onready var oxygen_label = $Panel/HBoxContainer/OxygenLabel
@onready var water_label = $Panel/HBoxContainer/WaterLabel
@onready var food_label = $Panel/HBoxContainer/FoodLabel
@onready var credits_label = $Panel/HBoxContainer/CreditsLabel
@onready var crystals_label = $Panel/HBoxContainer/CrystalsLabel

func _ready():
	# Assuming ResourceManager is an Autoload (Singleton) named 'GameManager' or similar
	# For now, we'll try to find it or wait for it to be registered.
	# In a real Godot setup, you'd register it in project.godot.
	update_ui(ResourceManager.resources)
	ResourceManager.resources_changed.connect(update_ui)

func update_ui(resources):
	energy_label.text = "Energy: " + str(resources["energy"])
	oxygen_label.text = "Oxygen: " + str(resources["oxygen"])
	water_label.text = "Water: " + str(resources["water"])
	food_label.text = "Food: " + str(resources["food"])
	credits_label.text = "Credits: " + str(resources["credits"])
	crystals_label.text = "Crystals: " + str(resources["mars_crystals"])
