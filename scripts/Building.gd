extends Node2D

# Building Instance Script
# Based on Mars Tycoon GDD: Event-Driven & Priority System

signal state_changed

var data: BuildingResource
var grid_position: Vector2i
var is_operational: bool = true
var current_tier: int = 1 # Simple 1-5 Tiers
var condition: float = 100.0 # 0.0 to 100.0
var is_power_connected: bool = false
var is_pipe_connected: bool = false

# Manager & Legacy System
var assigned_manager: ManagerResource
var legacy_bonuses: Dictionary = {
	"production": 1.0,
	"energy_saving": 0.0, # Reduction percentage
	"water_efficiency": 0.0, # Reduction percentage
	"moral_boost": 0.0,
	"maintenance_reduction": 0.0,
	"research_boost": 1.0
}

@onready var sprite = $Sprite2D
@onready var status_bars = $StatusBars
@onready var stress_bar = $StatusBars/StressBar
@onready var xp_bar = $StatusBars/XPBar

var power_icon: Sprite2D
var water_icon: Sprite2D
var shadow_sprite: Sprite2D

func setup(building_data: BuildingResource, pos: Vector2i):
	data = building_data
	grid_position = pos

func _ready():
	if data:
		EconomyManager.register_building(self)
		if data.sprite:
			sprite.texture = data.sprite
			# Scale down by 75% (set scale to 0.25)
			sprite.scale = Vector2(0.25, 0.25)
			
			# Setup Dynamic Shadow
			shadow_sprite = Sprite2D.new()
			shadow_sprite.texture = data.sprite
			shadow_sprite.modulate = Color(0, 0, 0, 0.4) 
			shadow_sprite.scale = sprite.scale
			shadow_sprite.show_behind_parent = true
			shadow_sprite.z_index = -1
			add_child(shadow_sprite)
		
		# Setup Power Icon
		power_icon = Sprite2D.new()
		power_icon.texture = load("res://assets/images/icons/electricity.png") 
		power_icon.modulate = Color(1, 0.2, 0.2) # Red for warning
		power_icon.scale = Vector2(0.2, 0.2)
		power_icon.position = Vector2(-16, -32)
		power_icon.visible = false
		power_icon.z_index = 5
		add_child(power_icon)

		# Setup Water Icon
		water_icon = Sprite2D.new()
		water_icon.texture = load("res://assets/images/icons/water.png")
		water_icon.modulate = Color(0.2, 0.6, 1.0) # Blue tint for water
		water_icon.scale = Vector2(0.2, 0.2)
		water_icon.position = Vector2(16, -32)
		water_icon.visible = false
		water_icon.z_index = 5
		add_child(water_icon)
		
		_setup_interaction()

func _process(_delta):
	_update_visual_bars()
	_update_shadow_logic()

func _update_shadow_logic():
	if not shadow_sprite: return
	
	var hour = TimeManager.current_hour
	var solar_intensity = TimeManager.get_solar_intensity()
	
	# Only show shadow during daylight (6:00 to 20:00)
	if hour < 6.0 or hour > 20.0:
		shadow_sprite.visible = false
		return
		
	shadow_sprite.visible = true
	
	# Calculate Sun Angle (Linear mapping for 2D perspective)
	# Map hour 6.0-20.0 to a sun angle range
	var sun_progress = (hour - 6.0) / 14.0 
	var angle = lerp(-PI * 0.6, PI * 0.6, sun_progress)
	
	# Shadow length: max at sunrise/sunset, min at noon
	var max_length = 30.0
	var length = abs(sin((sun_progress - 0.5) * PI)) * max_length
	
	# Depth correction at zenith
	if length < 6.0: length = 6.0
	
	# Apply offset: Shadow points away from the sun
	# Using sin/cos to create a 2.5D projection effect
	shadow_sprite.position = Vector2(sin(angle) * length, cos(angle) * length * 0.4)
	
	# Slight skew based on angle
	shadow_sprite.rotation = angle * 0.15
	shadow_sprite.modulate.a = 0.4 * solar_intensity

func apply_wear(amount: float):
	var wear_reduction = legacy_bonuses.get("maintenance_reduction", 0.0)
	var prev_condition = condition
	condition = clamp(condition - (amount * (1.0 - wear_reduction)), 0.0, 100.0)
	
	# If significant damage (like meteor), show flash
	if prev_condition - condition > 5.0:
		_flash_red()
		
	if condition <= 0:
		set_operational(false)

func _flash_red():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(10, 0, 0), 0.1) # Bright red
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.2)

func repair():
	var cost = data.maintenance_metal_cost
	if EconomyManager.consume_resource("metal", cost):
		condition = clamp(condition + 20.0, 0.0, 100.0) # Repair 20%
		if condition > 10.0 and not EconomyManager.is_blackout:
			set_operational(true)
		return true
	return false

func set_operational(state: bool):
	is_operational = state
	_update_visual_state()
	state_changed.emit()

func _update_visual_state():
	# Visual feedback for connection status is temporarily disabled.
	# The building will look the same regardless of power/water.
	modulate = Color(1, 1, 1, 1)
	if power_icon: power_icon.visible = false
	if water_icon: water_icon.visible = false

func _update_visual_bars():
	if assigned_manager and not assigned_manager.is_retired:
		status_bars.visible = true
		stress_bar.value = assigned_manager.current_stress
		xp_bar.value = (assigned_manager.experience / assigned_manager.experience_to_next_tier) * 100.0
	else:
		status_bars.visible = false

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
			get_tree().root.find_child("BuildingInfoPanel", true, false).show_building(self)

func assign_manager(manager: ManagerResource):
	if assigned_manager:
		EconomyManager.unregister_assigned_manager(assigned_manager)
	assigned_manager = manager
	EconomyManager.register_assigned_manager(manager)
	state_changed.emit()
	print("Manager ", manager.manager_name, " assigned to ", data.building_name)

func add_legacy(type: String, value: float):
	if legacy_bonuses.has(type):
		legacy_bonuses[type] += value
		state_changed.emit()

func get_effective_production() -> float:
	if not is_operational: return 0.0
	var manager_multiplier = 1.0
	if assigned_manager:
		manager_multiplier = assigned_manager.production_boost
		assigned_manager.add_stress(0.1) 
	
	# Tier Scaling: x1, x2, x4, x8, x16
	var tier_multiplier = pow(2, current_tier - 1)
	
	# Condition Penalty: 100% at cond>80, linear drop below 80
	var condition_mult = 1.0
	if condition < 80.0:
		condition_mult = condition / 80.0

	var total_multiplier = legacy_bonuses["production"] * manager_multiplier * tier_multiplier * condition_mult
	
	# Apply Sector Bonus from EconomyManager
	var sector_mult = EconomyManager.sector_bonuses.get(data.sector, 1.0)
	
	# Apply Breakthrough Multipliers
	var bt_mult = EconomyManager.get_global_multiplier(data.building_name) * EconomyManager.get_global_multiplier(data.production_type)
	
	return EconomyManager.calculate_production(data.production_amount, total_multiplier * sector_mult * bt_mult)

func get_consumption(resource_type: String) -> float:
	if not is_operational: return 0.0
	var base_consumption = data.input_resources.get(resource_type, 0.0)
	var tier_multiplier = pow(1.8, current_tier - 1)
	
	var final_cons = base_consumption * tier_multiplier
	
	if resource_type == "energy":
		var energy_save = legacy_bonuses.get("energy_saving", 0.0)
		return final_cons * (1.0 - energy_save)
	elif resource_type == "water":
		var water_save = legacy_bonuses.get("water_efficiency", 0.0)
		return final_cons * (1.0 - water_save)
		
	return final_cons

func upgrade():
	if current_tier < 5:
		var cost = get_upgrade_cost()
		if EconomyManager.consume_resource("credits", cost):
			current_tier += 1
			print(data.building_name, " upgraded to Tier ", current_tier)
			state_changed.emit()
			return true
	return false

func get_upgrade_cost() -> int:
	return int(data.base_cost * pow(data.upgrade_cost_multiplier, current_tier))
