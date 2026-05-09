extends Node

# Singleton: EconomyManager
# Based on Mars Tycoon Master Plan and GDD

signal economy_updated(new_state)
signal blackout_status_changed(is_blackout)

var resources = {
	"credits": 1000,
	"isotopes": 5,
	"oxygen": 100,
	"energy": 100,
	"water": 100,
	"food": 100,
	"metal": 50,
	"moral": 100
}

var active_buildings = []
var speed_booster: float = 1.0
var is_blackout: bool = false

func _ready():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_tick)
	add_child(timer)

func register_building(building_node):
	if not active_buildings.has(building_node):
		active_buildings.append(building_node)
		_recalculate_priorities()

func unregister_building(building_node):
	active_buildings.erase(building_node)
	_recalculate_priorities()

func _on_tick():
	_process_production_and_consumption()

func _process_production_and_consumption():
	var total_production = {}
	var total_consumption = {}
	
	# Reset temp production/consumption trackers
	for res in resources.keys():
		total_production[res] = 0.0
		total_consumption[res] = 0.0

	# 1. Calculate Potential Production and Required Consumption
	for building in active_buildings:
		if building.is_operational:
			var data = building.data
			# Add to production
			var amount = building.get_effective_production()
			total_production[data.production_type] = total_production.get(data.production_type, 0.0) + amount
			
			# Add to consumption
			for input_type in data.input_resources.keys():
				var cons_amount = building.get_consumption(input_type)
				total_consumption[input_type] = total_consumption.get(input_type, 0.0) + cons_amount

	# 2. Check Energy Balance (The core of Mars Tycoon)
	var net_energy = total_production.get("energy", 0.0) - total_consumption.get("energy", 0.0)
	
	# If energy is negative and batteries (if any) are empty, trigger Cascade Failure
	if resources["energy"] + net_energy < 0:
		if not is_blackout:
			_trigger_cascade_failure()
	else:
		if is_blackout:
			_recover_from_blackout()

	# 3. Apply changes (simplified for now, real system would be more complex)
	for res in resources.keys():
		if res == "moral": continue # Handled differently
		
		var change = total_production.get(res, 0.0) - total_consumption.get(res, 0.0)
		resources[res] = max(0, resources[res] + change)
	
	emit_signal("economy_updated", resources)

func _trigger_cascade_failure():
	is_blackout = true
	emit_signal("blackout_status_changed", true)
	print("!!! CASCADE FAILURE DETECTED !!!")
	
	# Sort buildings by priority (Priority 5 shuts down first)
	active_buildings.sort_custom(func(a, b): return a.data.priority_level < b.data.priority_level)
	
	for building in active_buildings:
		if building.data.priority_level > 1: # Keep Priority 1 (Life Support) running as long as possible
			building.set_operational(false)
			# Re-check energy after each shutdown if we want granular cascade
			# For now, let's just shut down non-essentials

func _recover_from_blackout():
	is_blackout = false
	emit_signal("blackout_status_changed", false)
	print("System Rebooting...")
	for building in active_buildings:
		building.set_operational(true)

func _recalculate_priorities():
	# Sort buildings for UI or internal logic
	pass

func add_resource(type: String, amount: float):
	if resources.has(type):
		resources[type] += amount
		emit_signal("economy_updated", resources)

func consume_resource(type: String, amount: float) -> bool:
	if resources.has(type) and resources[type] >= amount:
		resources[type] -= amount
		emit_signal("economy_updated", resources)
		return true
	return false

func calculate_production(base: float, legacy_bonus: float) -> float:
	return (base * legacy_bonus) * (resources["moral"] / 100.0) * speed_booster
