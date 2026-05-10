extends Node2D

# Building Instance Script
# Based on Mars Tycoon GDD: Event-Driven & Priority System

var data: BuildingResource
var grid_position: Vector2i
var is_operational: bool = true

func setup(building_data: BuildingResource, pos: Vector2i):
	data = building_data
	grid_position = pos

# Manager & Legacy System

var assigned_manager: ManagerResource
var legacy_bonuses: Dictionary = {
	"production": 1.0,
	"energy_saving": 1.0,
	"moral_boost": 0.0
}

@onready var sprite = $Sprite2D

func _ready():
	if data:
		EconomyManager.register_building(self)
		if data.sprite:
			sprite.texture = data.sprite
		
		# Add Area2D for clicking if not present
		_setup_interaction()

func _setup_interaction():
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(GridManager.tile_size, GridManager.tile_size)
	collision.shape = shape
	area.add_child(collision)
	add_child(area)
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	if not BuildingManager.is_placing:
		var tooltip = get_tree().root.find_child("BuildingTooltip", true, false)
		if tooltip:
			tooltip.show_tooltip(self)

func _on_mouse_exited():
	var tooltip = get_tree().root.find_child("BuildingTooltip", true, false)
	if tooltip:
		tooltip.hide_tooltip()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not BuildingManager.is_placing:
			# Signal or call BuildingInfoPanel
			get_tree().root.find_child("BuildingInfoPanel", true, false).show_building(self)

func assign_manager(manager: ManagerResource):
	# If building already had a manager, unregister them
	if assigned_manager:
		EconomyManager.unregister_assigned_manager(assigned_manager)
		
	assigned_manager = manager
	EconomyManager.register_assigned_manager(manager)
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
