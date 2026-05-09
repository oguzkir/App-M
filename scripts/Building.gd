extends Node2D

# Building Instance Script
# Based on Mars Tycoon GDD: Event-Driven & Priority System

var data: BuildingResource
var grid_position: Vector2i
var is_operational: bool = true

# Manager & Legacy System
var assigned_manager: ManagerResource
var legacy_bonuses: Dictionary = {
	"production": 1.0,
	"energy_saving": 1.0,
	"moral_boost": 0.0
}

@onready var sprite = $Sprite2D

func setup(building_data: BuildingResource, pos: Vector2i):
	data = building_data
	grid_position = pos
	
func _ready():
	if data:
		EconomyManager.register_building(self)
		if data.sprite:
			sprite.texture = data.sprite

func assign_manager(manager: ManagerResource):
	assigned_manager = manager
	print("Manager ", manager.manager_name, " assigned to ", data.building_name)

func add_legacy(type: String, value: float):
	if legacy_bonuses.has(type):
		if type == "moral_boost":
			legacy_bonuses[type] += value
		else:
			legacy_bonuses[type] += value # Additive bonus (e.g., 1.0 + 0.05)

func get_effective_production() -> float:
	if not is_operational: return 0.0
	
	var manager_multiplier = 1.0
	if assigned_manager:
		manager_multiplier = assigned_manager.production_boost
		# Increase stress every tick
		assigned_manager.add_stress(0.1) 
	
	var total_multiplier = legacy_bonuses["production"] * manager_multiplier
	return EconomyManager.calculate_production(data.production_amount, total_multiplier)

func get_consumption(resource_type: String) -> float:
	if not is_operational: return 0.0
	var base_consumption = data.input_resources.get(resource_type, 0.0)
	# Apply energy saving legacy if applicable
	if resource_type == "energy":
		return base_consumption * (2.0 - legacy_bonuses["energy_saving"]) # e.g., 1.05 legacy -> 0.95 consumption
	return base_consumption
