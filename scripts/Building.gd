extends Node2D

# Building Instance Script
var data: BuildingResource
var grid_position: Vector2i

@onready var sprite = $Sprite2D
@onready var timer = $Timer

func setup(building_data: BuildingResource, pos: Vector2i):
	data = building_data
	grid_position = pos
	
func _ready():
	if data:
		# In a real game, you'd set the sprite texture here
		# sprite.texture = data.sprite
		
		# Start production timer
		timer.wait_time = 1.0 # Tick every second
		timer.timeout.connect(_on_production_tick)
		timer.start()

func _on_production_tick():
	# Production Formula: (Base * Legacy) * (Moral/100) * Booster
	# For now, just adding base production
	var legacy_bonus = 1.0 # Will be fetched from Building Manager / Legacy System later
	var amount = EconomyManager.calculate_production(data.production_amount, legacy_bonus)
	EconomyManager.add_resource(data.production_type, amount)
