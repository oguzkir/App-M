extends Node

# Singleton: HiringManager
# Handles weighted random rolls for managers

signal manager_hired(manager: ManagerResource)

const HIRE_COST_ISOTOPE = 50

var templates = [
	preload("res://resources/managers/templates/Common_Aris.tres"),
	preload("res://resources/managers/templates/Rare_Sarah.tres"),
	preload("res://resources/managers/templates/Epic_Rex.tres"),
	preload("res://resources/managers/templates/Legendary_Oracle.tres")
]

# Rarity Weights (Total: 1000)
var rarity_weights = {
	0: 700, # Common (T1)
	1: 200, # Rare (T2)
	2: 80,  # Epic (T3)
	3: 20   # Legendary (T4)
}

func hire_random_manager() -> bool:
	if EconomyManager.consume_resource("isotopes", HIRE_COST_ISOTOPE):
		var rolled_manager = _perform_roll()
		if rolled_manager:
			manager_hired.emit(rolled_manager)
			print("HiringManager: Successfully hired ", rolled_manager.manager_name)
			return true
	
	print("HiringManager: Not enough isotopes!")
	return false

func _perform_roll() -> ManagerResource:
	var total_weight = 0
	for weight in rarity_weights.values():
		total_weight += weight
		
	var roll = randi() % total_weight
	var selected_rarity = 0
	
	var current_sum = 0
	for rarity in rarity_weights:
		current_sum += rarity_weights[rarity]
		if roll < current_sum:
			selected_rarity = rarity
			break
			
	# Filter templates by selected rarity
	var eligible = templates.filter(func(t): return t.rarity_tier == selected_rarity)
	
	if eligible.is_empty():
		# Fallback to any common if specific rarity not found (shouldn't happen with our setup)
		eligible = templates.filter(func(t): return t.rarity_tier == 0)
		
	var template = eligible.pick_random()
	return _create_manager_from_template(template)

func _create_manager_from_template(template: ManagerTemplate) -> ManagerResource:
	var new_manager = ManagerResource.new()
	new_manager.manager_name = template.name
	new_manager.sector = template.character_sector as ManagerResource.Sector
	new_manager.tier = template.rarity_tier as ManagerResource.Tier
	new_manager.production_boost = template.base_production_boost
	new_manager.stress_resistance = template.base_stress_resistance
	new_manager.legacy_type = template.legacy_type
	new_manager.legacy_bonus_value = template.legacy_value
	
	# Initial Miracles for T4 (if legendary)
	if new_manager.tier >= ManagerResource.Tier.T4:
		new_manager.miracle_name = "The Oracle's Sight"
		new_manager.miracle_description = "Instantly clears all building wear."
		
	return new_manager
