extends Node

# Singleton: TerraformingManager
# Tracks the 4 stages of Mars transformation

signal terraforming_updated(stats)
signal threshold_reached(parameter, value)

var stats = {
	"temperature": 0.0,
	"water": 0.0,
	"atmosphere": 0.0,
	"vegetation": 0.0
}

# Threshold flags to prevent multiple signals
var thresholds_met = {
	"atm_50": false,
	"atm_80": false,
	"temp_40": false,
	"water_40": false
}

func _ready():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.timeout.connect(_on_tick)
	add_child(timer)

func _on_tick():
	_apply_decay()
	_check_thresholds()
	terraforming_updated.emit(stats)

func add_progress(parameter: String, amount: float):
	if stats.has(parameter):
		# Vegetation needs Water and Temp > 40%
		if parameter == "vegetation":
			if stats["temperature"] < 40.0 or stats["water"] < 40.0:
				return # Cannot grow plants yet
				
		stats[parameter] = clamp(stats[parameter] + amount, 0.0, 100.0)

func _apply_decay():
	# Mars naturally reverts if not actively maintained
	# Temperature and Atmosphere decay slowly
	stats["temperature"] = clamp(stats["temperature"] - 0.001, 0.0, 100.0)
	stats["atmosphere"] = clamp(stats["atmosphere"] - 0.001, 0.0, 100.0)

func _check_thresholds():
	if stats["atmosphere"] >= 50.0 and not thresholds_met["atm_50"]:
		thresholds_met["atm_50"] = true
		threshold_reached.emit("atmosphere", 50)
		
	if stats["atmosphere"] >= 80.0 and not thresholds_met["atm_80"]:
		thresholds_met["atm_80"] = true
		threshold_reached.emit("atmosphere", 80)
		
	if stats["temperature"] >= 40.0 and not thresholds_met["temp_40"]:
		thresholds_met["temp_40"] = true
		threshold_reached.emit("temperature", 40)
		
	if stats["water"] >= 40.0 and not thresholds_met["water_40"]:
		thresholds_met["water_40"] = true
		threshold_reached.emit("water", 40)
