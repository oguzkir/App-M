extends Node2D

# Building Instance Script
# Based on Mars Tycoon GDD: Event-Driven & Priority System

var data: BuildingResource
var grid_position: Vector2i
var is_operational: bool = true

@onready var sprite = $Sprite2D

func setup(building_data: BuildingResource, pos: Vector2i):
	data = building_data
	grid_position = pos
	
func _ready():
	if data:
		# Register with EconomyManager for centralized tick processing
		EconomyManager.register_building(self)
		
		# Visual Setup
		if data.sprite:
			sprite.texture = data.sprite

func _exit_tree():
	# Unregister when destroyed
	EconomyManager.unregister_building(self)

func set_operational(state: bool):
	is_operational = state
	# Visual feedback for shutdown
	if is_operational:
		modulate = Color(1, 1, 1, 1) # Normal
	else:
		modulate = Color(0.3, 0.3, 0.3, 1) # Darkened/Powered Off

func get_effective_production() -> float:
	if not is_operational: return 0.0
	# (Base * Legacy) * (Moral/100) * Booster
	# Legacy bonus to be integrated with Manager system
	return EconomyManager.calculate_production(data.production_amount, 1.0)
