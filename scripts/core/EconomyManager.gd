extends Node

# Singleton: EconomyManager
# Based on Mars Tycoon Master Plan

signal economy_updated(new_state)

var resources = {
	"credits": 1000,
	"isotopes": 5,    # Premium Currency (Wait-or-Pay)
	"oxygen": 100,
	"energy": 100,
	"water": 100,
	"food": 100,
	"moral": 100     # Global Moral Multiplier
}

# Active boosters
var speed_booster: float = 1.0 # 2x multiplier from RVs etc.

func _ready():
	# Update loop for real-time production
	var timer = Timer.new()
	timer.wait_time = 1.0 # Process every second
	timer.autostart = true
	timer.timeout.connect(_on_tick)
	add_child(timer)

func _on_tick():
	# Real-time production logic would go here
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

# Master Plan Formula: Effective_Production = (Base * Legacy_Bonus) * (Moral / 100) * Active_Booster
func calculate_production(base: float, legacy_bonus: float) -> float:
	return (base * legacy_bonus) * (resources["moral"] / 100.0) * speed_booster

func process_offline_production(seconds: int):
	# Calculate total production while offline
	# This requires iterating through active buildings (to be implemented)
	print("Processing offline production for ", seconds, " seconds...")
	# Placeholder for actual building iteration logic
