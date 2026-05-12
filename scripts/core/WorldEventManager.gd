extends Node

# Singleton: WorldEventManager
# Handles random Mars events like Sandstorms, Radiation, etc.

signal event_started(event_name, duration, effects)
signal event_ended(event_name)

enum EventType { NONE, SANDSTORM, RADIATION_FLARE, METEOR_SHOWER, SUPPLY_SHIP, COLD_WAVE, DUST_DEVIL }

var current_event: EventType = EventType.NONE

func _ready():
	var timer = Timer.new()
	timer.wait_time = 300.0 # Check for event every 5 minutes
	timer.autostart = true
	timer.timeout.connect(_roll_for_event)
	add_child(timer)

func _roll_for_event():
	if current_event != EventType.NONE: return
	
	var roll = randf()
	if roll < 0.2: # 20% chance
		var type = [
			EventType.SANDSTORM, 
			EventType.RADIATION_FLARE, 
			EventType.METEOR_SHOWER, 
			EventType.SUPPLY_SHIP,
			EventType.COLD_WAVE,
			EventType.DUST_DEVIL
		].pick_random()
		_start_event(type)

func _start_event(type: EventType):
	current_event = type
	var duration = randf_range(40.0, 150.0)
	var effects = {}
	var event_name = ""

	match type:
		EventType.SANDSTORM:
			event_name = "Kum Firtinasi"
			effects = {"solar_efficiency": 0.1, "building_wear": 3.0}
		EventType.RADIATION_FLARE:
			event_name = "Radyasyon Patlamasi"
			effects = {"manager_stress": 4.0, "moral_loss": 2.0}
		EventType.METEOR_SHOWER:
			event_name = "Meteor Yagmuru"
			effects = {"random_damage": 30.0}
			_start_meteor_sequence(duration)
		EventType.COLD_WAVE:
			event_name = "Soguk Dalgasi"
			effects = {"energy_consumption": 1.5, "freeze_water": true}
		EventType.DUST_DEVIL:
			event_name = "Toz Seytani"
			effects = {"local_wear": 50.0}
			_spawn_dust_devil_sequence(duration)
		EventType.SUPPLY_SHIP:
			event_name = "Ikmal Gemisi"
			effects = {"market_discount": 0.5, "free_isotopes": 10}
			EconomyManager.add_resource("isotopes", 10)

	event_started.emit(event_name, duration, effects)
	print("WORLD EVENT: ", event_name, " started.")
	
	get_tree().create_timer(duration).timeout.connect(func(): _end_event(event_name))

func _spawn_dust_devil_sequence(duration: float):
	# Dust Devils are moving entities. For now, we'll simulate hits.
	var timer = get_tree().create_timer(randf_range(10.0, 20.0))
	timer.timeout.connect(func():
		if current_event == EventType.DUST_DEVIL:
			_strike_dust_devil()
			_spawn_dust_devil_sequence(duration)
	)

func _strike_dust_devil():
	if EconomyManager.active_buildings.is_empty(): return
	var target = EconomyManager.active_buildings.pick_random()
	target.apply_wear(15.0) # Instant dirt/wear
	print("DUST DEVIL: Hit ", target.data.building_name, " for 15% wear!")

func _start_meteor_sequence(duration: float):
	var timer = get_tree().create_timer(randf_range(5.0, 10.0))
	timer.timeout.connect(func():
		if current_event == EventType.METEOR_SHOWER:
			_strike_meteor()
			_start_meteor_sequence(duration) # Repeat until event ends
	)

func _strike_meteor():
	if EconomyManager.active_buildings.is_empty(): return
	
	var target = EconomyManager.active_buildings.pick_random()
	var damage = randf_range(20.0, 50.0)
	target.condition = clamp(target.condition - damage, 0.0, 100.0)
	
	print("METEOR STRIKE: ", target.data.building_name, " hit for ", int(damage), "% damage!")
	
	# Trigger camera shake if camera exists
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("apply_shake"):
		camera.apply_shake(0.5, 15.0)

func _end_event(event_name: String):
	current_event = EventType.NONE
	event_ended.emit(event_name)
	print("WORLD EVENT: ", event_name, " ended.")
