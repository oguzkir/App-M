extends CanvasLayer

@onready var energy_label = $Panel/HBoxContainer/EnergyLabel
@onready var oxygen_label = $Panel/HBoxContainer/OxygenLabel
@onready var water_label = $Panel/HBoxContainer/WaterLabel
@onready var food_label = $Panel/HBoxContainer/FoodLabel
@onready var credits_label = $Panel/HBoxContainer/CreditsLabel
@onready var crystals_label = $Panel/HBoxContainer/CrystalsLabel

func _ready():
	update_ui(EconomyManager.resources)
	EconomyManager.economy_updated.connect(update_ui)

func update_ui(resources):
	energy_label.text = "Energy: " + str(int(resources["energy"]))
	oxygen_label.text = "Oxygen: " + str(int(resources["oxygen"]))
	water_label.text = "Water: " + str(int(resources["water"]))
	food_label.text = "Food: " + str(int(resources["food"]))
	credits_label.text = "Credits: " + str(int(resources["credits"]))
	crystals_label.text = "Isotopes: " + str(int(resources["isotopes"]))
