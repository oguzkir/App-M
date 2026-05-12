extends Node

# Singleton: EconomyManager
# Handles production, consumption, blackout, miracles, and STORAGE

signal economy_updated(new_state)
signal blackout_status_changed(is_blackout)

var resources = {
	"credits": 1000,
	"isotopes": 50,
	"oxygen": 100,
	"energy": 100,
	"water": 100,
	"food": 100,
	"metal": 50,
	"concrete": 50,
	"waste_rock": 0,
	"moral": 100,
	"research": 0
}

var max_capacities = {
	"energy": 100.0,
	"oxygen": 50.0,
	"water": 50.0,
	"food": 500.0,
	"metal": 200.0,
	"concrete": 200.0,
	"waste_rock": 50.0
}

var active_buildings = []
var speed_booster: float = 1.0
var is_blackout: bool = false

# Breakthrough Multipliers
var global_multipliers: Dictionary = {} # e.g. {"Solar Panel": 2.0, "metal": 1.5}
var cost_reductions: Dictionary = {} # e.g. {"infra": 0.0}

func add_global_multiplier(target: String, val: float):
	global_multipliers[target] = val

func add_cost_reduction(target: String, val: float):
	cost_reductions[target] = val

func get_global_multiplier(target: String) -> float:
	return global_multipliers.get(target, 1.0)

var assigned_managers: Array[ManagerResource] = []
var active_event_effects: Dictionary = {}
var auto_save_timer: float = 0.0

var last_energy_stats = {
	"production": 0.0,
	"consumption": 0.0,
	"net": 0.0
}

var last_water_stats = {
	"production": 0.0,
	"consumption": 0.0,
	"net": 0.0
}

# --- Cached Rates ---
var cached_production = {}
var cached_consumption = {}
var cached_tf_rates = {"temperature": 0.0, "water": 0.0, "atmosphere": 0.0, "vegetation": 0.0}

var sector_bonuses: Dictionary = {
	BuildingResource.Sector.INDUSTRIAL: 1.0,
	BuildingResource.Sector.LIFE_SUPPORT: 1.0,
	BuildingResource.Sector.SCIENCE: 1.0,
	BuildingResource.Sector.LOGISTICS: 1.0
}

# Mapping sectors to building names for Affinity System
var sector_to_buildings: Dictionary = {
	ManagerResource.Sector.INDUSTRIAL: ["Solar Panel", "Large Solar Panel", "Solar Array", "Wind Turbine", "Power Accumulator", "Metals Extractor", "Concrete Extractor", "Dumping Site"],
	ManagerResource.Sector.CIVIL: ["MOXIE", "Electrolyzer", "Moisture Vaporator", "Water Extractor", "Hydroponic Farm", "Oxygen Tank", "Water Tower"],
	ManagerResource.Sector.LOGISTICS: ["Research Lab", "Universal Depot", "Landing Pad"]
}

func can_manager_work_at(manager: ManagerResource, building: Node2D) -> bool:
	var allowed_buildings = sector_to_buildings.get(manager.sector, [])
	return building.data.building_name in allowed_buildings

func _ready():
	# Initialize cached dictionaries
	for res in resources.keys():
		cached_production[res] = 0.0
		cached_consumption[res] = 0.0
	
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_tick)
	add_child(timer)
	
	# Listen for World Events
	var event_manager = get_node_or_null("/root/WorldEventManager")
	if event_manager:
		event_manager.event_started.connect(_on_world_event_started)
		event_manager.event_ended.connect(_on_world_event_ended)

func _on_world_event_started(_name, _duration, effects):
	active_event_effects = effects
	recalculate_economy_rates()

func _on_world_event_ended(_name):
	active_event_effects = {}
	recalculate_economy_rates()

func register_building(building_node):
	if not active_buildings.has(building_node):
		active_buildings.append(building_node)
		_update_grid_connectivity()

func unregister_building(building_node):
	active_buildings.erase(building_node)
	_update_grid_connectivity()

func recalculate_economy_rates():
	_recalculate_max_capacities()
	
	# Reset Caches
	for res in resources.keys():
		cached_production[res] = 0.0
		cached_consumption[res] = 0.0
	for key in cached_tf_rates.keys():
		cached_tf_rates[key] = 0.0
	
	var solar_mult = active_event_effects.get("solar_efficiency", 1.0)
	var day_night_mult = TimeManager.get_solar_intensity()
	var energy_cons_mult = active_event_effects.get("energy_consumption", 1.0)
	var is_frozen = active_event_effects.get("freeze_water", false)
	var is_waste_full = resources.get("waste_rock", 0.0) >= max_capacities.get("waste_rock", 50.0)

	for building in active_buildings:
		if building.is_operational and (building.is_power_connected or building.data.production_type == "energy"):
			var data = building.data
			if is_waste_full and data.waste_production > 0: continue
			if is_frozen and ("Water" in data.building_name or "Lake" in data.building_name):
				continue

			var amount = building.get_effective_production()
			
			if data.production_type == "energy":
				if "Solar" in data.building_name:
					amount *= (solar_mult * day_night_mult)
				elif "Wind" in data.building_name:
					if solar_mult < 1.0: amount *= 1.2
				
			if data.production_type in ["temperature", "water_terra", "atmosphere", "vegetation"]:
				var tf_type = "water" if data.production_type == "water_terra" else data.production_type
				cached_tf_rates[tf_type] += amount
			else:
				cached_production[data.production_type] += amount
			
			if data.waste_production > 0:
				cached_production["waste_rock"] += data.waste_production
			
			for input_type in data.input_resources.keys():
				var cons = building.get_consumption(input_type)
				if input_type == "energy":
					cons *= energy_cons_mult
				cached_consumption[input_type] += cons

	last_energy_stats["production"] = cached_production.get("energy", 0.0)
	last_energy_stats["consumption"] = cached_consumption.get("energy", 0.0)
	last_energy_stats["net"] = last_energy_stats["production"] - last_energy_stats["consumption"]

	last_water_stats["production"] = cached_production.get("water", 0.0)
	last_water_stats["consumption"] = cached_consumption.get("water", 0.0)
	last_water_stats["net"] = last_water_stats["production"] - last_water_stats["consumption"]

func _update_grid_connectivity():
	for building in active_buildings:
		building.is_power_connected = false
		building.is_pipe_connected = false

	var power_producers = []
	for building in active_buildings:
		if building.data.production_type == "energy" or building.data.production_type == "energy_storage":
			power_producers.append(building)
			building.is_power_connected = true

	for producer in power_producers:
		var queue = [producer.grid_position]
		var visited = {producer.grid_position: true}
		while queue.size() > 0:
			var curr = queue.pop_front()
			for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var next = curr + dir
				if visited.has(next): continue
				if GridManager.has_cable(next):
					visited[next] = true
					queue.append(next)
				if GridManager.occupied_tiles.has(next):
					var b = GridManager.occupied_tiles[next]
					b.is_power_connected = true
					visited[next] = true
					queue.append(next)

	var life_producers = []
	for building in active_buildings:
		if building.data.production_type in ["water", "oxygen", "water_terra", "water_storage", "oxygen_storage"]:
			life_producers.append(building)
			building.is_pipe_connected = true

	for producer in life_producers:
		var queue = [producer.grid_position]
		var visited = {producer.grid_position: true}
		while queue.size() > 0:
			var curr = queue.pop_front()
			for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var next = curr + dir
				if visited.has(next): continue
				if GridManager.has_pipe(next):
					visited[next] = true
					queue.append(next)
				if GridManager.occupied_tiles.has(next):
					var b = GridManager.occupied_tiles[next]
					b.is_pipe_connected = true
					visited[next] = true
					queue.append(next)

	_update_sector_bonuses()

	for building in active_buildings:
		building._update_visual_state()
		if not is_blackout and building.condition > 10.0:
			building.set_operational(true) 
	
	recalculate_economy_rates()

func _update_sector_bonuses():
	for s in sector_bonuses.keys():
		sector_bonuses[s] = 1.0
	var sector_counts = {}
	for building in active_buildings:
		if building.is_operational:
			var s = building.data.sector
			sector_counts[s] = sector_counts.get(s, 0) + 1
	for s in sector_counts:
		if sector_counts[s] >= 3:
			sector_bonuses[s] = 1.25

func register_assigned_manager(manager: ManagerResource):
	if not assigned_managers.has(manager):
		assigned_managers.append(manager)
		recalculate_economy_rates()

func unregister_assigned_manager(manager: ManagerResource):
	assigned_managers.erase(manager)
	recalculate_economy_rates()

func is_manager_assigned(manager: ManagerResource) -> bool:
	return assigned_managers.has(manager)

func _on_tick():
	if TimeManager.is_cheat_detected: return
	_apply_cached_economy()
	_update_managers()
	_update_building_wear()
	if Engine.get_frames_drawn() % 60 == 0:
		recalculate_economy_rates()
	auto_save_timer += 1.0
	if auto_save_timer >= 30.0:
		auto_save_timer = 0.0
		var sm = get_node_or_null("/root/SaveManager")
		if sm: sm.save_game()

func _apply_cached_economy():
	var tf_manager = get_node_or_null("/root/TerraformingManager")
	if tf_manager:
		for type in cached_tf_rates.keys():
			if cached_tf_rates[type] > 0:
				tf_manager.add_progress(type, cached_tf_rates[type])

	var net_energy = cached_production.get("energy", 0.0) - cached_consumption.get("energy", 0.0)
	if resources["energy"] + net_energy <= 0:
		if not is_blackout:
			_trigger_cascade()
	elif is_blackout and net_energy > 0:
		_recover_from_blackout()

	for res in resources.keys():
		if res == "moral" or res == "credits" or res == "isotopes":
			if res == "moral":
				var loss = active_event_effects.get("moral_loss", 1.0)
				resources[res] = clamp(resources[res] - (0.01 * loss), 0, 100)
			continue
		var change = cached_production.get(res, 0.0) - cached_consumption.get(res, 0.0)
		var max_cap = max_capacities.get(res, 99999.0)
		resources[res] = clamp(resources[res] + change, 0, max_cap)
	emit_signal("economy_updated", resources)

func _update_managers():
	var stress_mult = active_event_effects.get("manager_stress", 1.0)
	for building in active_buildings:
		var manager = building.assigned_manager
		if manager and not manager.is_retired:
			manager.add_stress(0.05 * stress_mult)
			manager.add_experience(1.0)
			if manager.is_retired:
				_apply_legacy(building, manager)
				building.assigned_manager = null
				unregister_assigned_manager(manager)

func _apply_legacy(building, manager):
	var legacy_type = ""
	var legacy_value = manager.legacy_bonus_value
	match manager.sector:
		ManagerResource.Sector.INDUSTRIAL:
			legacy_type = ["production", "energy_saving"].pick_random()
		ManagerResource.Sector.CIVIL:
			legacy_type = ["water_efficiency", "moral_boost"].pick_random()
		ManagerResource.Sector.LOGISTICS:
			legacy_type = ["maintenance_reduction", "research_boost"].pick_random()
	building.add_legacy(legacy_type, legacy_value)

func _update_building_wear():
	var wear_mult = active_event_effects.get("building_wear", 1.0)
	for building in active_buildings:
		building.apply_wear(0.01 * wear_mult) 

func _recalculate_max_capacities():
	max_capacities["energy"] = 50.0
	max_capacities["oxygen"] = 25.0
	max_capacities["water"] = 25.0
	max_capacities["metal"] = 50.0
	max_capacities["concrete"] = 50.0
	max_capacities["food"] = 50.0
	max_capacities["waste_rock"] = 50.0
	for building in active_buildings:
		if building.is_operational:
			match building.data.production_type:
				"energy_storage": max_capacities["energy"] += building.get_effective_production()
				"oxygen_storage": max_capacities["oxygen"] += building.get_effective_production()
				"water_storage": max_capacities["water"] += building.get_effective_production()
				"universal_storage":
					var amt = building.get_effective_production()
					max_capacities["metal"] += amt
					max_capacities["concrete"] += amt
					max_capacities["food"] += amt
				"waste_storage":
					max_capacities["waste_rock"] += building.get_effective_production()

func _trigger_cascade():
	is_blackout = true
	emit_signal("blackout_status_changed", true)
	var sorted = active_buildings.duplicate()
	sorted.sort_custom(func(a,b): return a.data.priority_level > b.data.priority_level)
	for b in sorted:
		if b.data.priority_level > 1: b.set_operational(false)
	recalculate_economy_rates()

func _recover_from_blackout():
	is_blackout = false
	emit_signal("blackout_status_changed", false)
	for b in active_buildings: 
		if b.condition > 10.0:
			b.set_operational(true)
	recalculate_economy_rates()

func add_resource(type: String, amount: float):
	if resources.has(type): resources[type] += amount

func consume_resource(type: String, amount: float) -> bool:
	if resources.has(type) and resources[type] >= amount:
		resources[type] -= amount
		return true
	return false

func calculate_production(base: float, legacy_bonus: float) -> float:
	return (base * legacy_bonus) * (resources["moral"] / 100.0) * speed_booster

func use_miracle(manager: ManagerResource):
	if not manager.can_use_miracle(): return
	manager.miracle_used = true
	match manager.sector:
		ManagerResource.Sector.INDUSTRIAL:
			add_resource("metal", 200)
			_recover_from_blackout()
		ManagerResource.Sector.CIVIL:
			resources["moral"] = 100.0
		ManagerResource.Sector.LOGISTICS:
			add_resource("isotopes", 50)
	manager.add_stress(50.0)

func get_infrastructure_cost(_type: String) -> int:
	var base_cost = 1
	if cost_reductions.has("infra"):
		return int(base_cost * cost_reductions["infra"])
	return base_cost

func process_offline_production(seconds: int):
	recalculate_economy_rates()
	for res in resources.keys():
		if res in ["moral", "credits", "isotopes"]: continue
		var change = (cached_production.get(res, 0.0) - cached_consumption.get(res, 0.0)) * seconds
		var max_cap = max_capacities.get(res, 99999.0)
		resources[res] = clamp(resources[res] + change, 0, max_cap)
	var tf_manager = get_node_or_null("/root/TerraformingManager")
	if tf_manager:
		for res in cached_tf_rates.keys():
			var decay = 0.001 if res in ["temperature", "atmosphere"] else 0.0
			tf_manager.add_progress(res, (cached_tf_rates[res] - decay) * seconds)
	emit_signal("economy_updated", resources)
