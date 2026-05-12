extends Node

## Singleton: MissionManager
## Handles the progression of Milestones, spawning of Anomalies, 
## and the unlocking of game-changing Breakthroughs.

# --- Signals ---
signal milestone_completed(id, title)
signal anomaly_spawned(pos)
signal breakthrough_unlocked(id, title)

# --- State ---
var active_milestones: Dictionary = {}
var completed_milestones: Array[String] = []
var unlocked_breakthroughs: Array[String] = []

# --- Database: Milestones ---
var milestones_db = {
	"first_steps": {
		"title": "İlk Adımlar", 
		"desc": "3 Güneş Paneli kur.", 
		"req_type": "build_count", 
		"target": "Solar Panel", 
		"amount": 3, 
		"reward_isotopes": 20
	},
	"water_seeker": {
		"title": "Su Kaynağı", 
		"desc": "1 Su Pompası kur.", 
		"req_type": "build_count", 
		"target": "Water Pump", 
		"amount": 1, 
		"reward_credits": 1000
	},
	"atmosphere_breath": {
		"title": "Nefes Alabilir Mars", 
		"desc": "%5 Atmosfer seviyesine ulaş.", 
		"req_type": "terra_stat", 
		"target": "atmosphere", 
		"amount": 5.0, 
		"reward_isotopes": 50
	},
	"power_grid": {
		"title": "Enerji Ağı", 
		"desc": "10 Kablo döşe.", 
		"req_type": "infra_count", 
		"target": "cable", 
		"amount": 10, 
		"reward_credits": 500
	},
	"scientific_outpost": {
		"title": "Bilim Üssü",
		"desc": "Bir Araştırma Laboratuvarı inşa et.",
		"req_type": "build_count",
		"target": "Research Lab",
		"amount": 1,
		"reward_credits": 2000
	},
	"blue_mars": {
		"title": "Mavi Mars",
		"desc": "%10 Su seviyesine ulaş.",
		"req_type": "terra_stat",
		"target": "water",
		"amount": 10.0,
		"reward_isotopes": 100
	},
	"green_mars": {
		"title": "Yeşil Mars",
		"desc": "%10 Bitki Örtüsü seviyesine ulaş.",
		"req_type": "terra_stat",
		"target": "vegetation",
		"amount": 10.0,
		"reward_credits": 5000
	}
}

# --- Database: Breakthroughs ---
var breakthroughs_db = {
	"frictionless_composites": {
		"title": "Sürtünmesiz Kompozitler", 
		"desc": "Rüzgar türbinleri üretimi +%100.", 
		"bonus_type": "prod_mult", 
		"target": "Wind Turbine", 
		"val": 2.0
	},
	"hypersensitive_photo": {
		"title": "Hassas Fotovoltaikler", 
		"desc": "Güneş panelleri verimi +%100.", 
		"bonus_type": "prod_mult", 
		"target": "Solar Panel", 
		"val": 2.0
	},
	"magnetic_mining": {
		"title": "Manyetik Madencilik", 
		"desc": "Maden üretimi +%50.", 
		"bonus_type": "prod_mult", 
		"target": "metal", # Target can be building name or resource type
		"val": 1.5
	},
	"superior_pipes": {
		"title": "Üstün Borular", 
		"desc": "Altyapı döşeme maliyeti 0 Metal.", 
		"bonus_type": "cost_reduction", 
		"target": "infra", 
		"val": 0.0
	},
	"hull_polarization": {
		"title": "Gövde Polarizasyonu", 
		"desc": "Bina aşınma hızı -%25.", 
		"bonus_type": "wear_reduction", 
		"target": "global", 
		"val": 0.75
	}
}

func _ready():
	# Wait for core systems (Economy, Terraforming) to be ready
	await get_tree().process_frame
	_init_milestones()
	
	# Connect to economy updates to check terraforming milestones
	EconomyManager.economy_updated.connect(_check_milestones_terra)
	
	# Anomaly Spawner: Every 5 minutes, attempt to spawn an anomaly
	var timer = Timer.new()
	timer.wait_time = 300.0 
	timer.autostart = true
	timer.timeout.connect(spawn_random_anomaly)
	add_child(timer)

## Initializes the active milestones list from the database, skipping completed ones.
func _init_milestones():
	active_milestones.clear()
	for m_id in milestones_db.keys():
		if not completed_milestones.has(m_id):
			active_milestones[m_id] = milestones_db[m_id]

## Checks milestones related to terraforming progress.
func _check_milestones_terra(_stats):
	for m_id in active_milestones.keys():
		var m = active_milestones[m_id]
		if m.req_type == "terra_stat":
			if TerraformingManager.stats.get(m.target, 0.0) >= m.amount:
				complete_milestone(m_id)

## Checks milestones triggered by building construction.
func check_build_milestone(building_name: String):
	for m_id in active_milestones.keys():
		var m = active_milestones[m_id]
		if m.req_type == "build_count" and m.target == building_name:
			var count = 0
			for b in EconomyManager.active_buildings:
				if b.data.building_name == building_name: count += 1
			
			if count >= m.amount:
				complete_milestone(m_id)

## Checks milestones related to infrastructure (cables/pipes) counts.
func check_infra_milestone(type: String):
	for m_id in active_milestones.keys():
		var m = active_milestones[m_id]
		if m.req_type == "infra_count" and m.target == type:
			var count = GridManager.cables.size() if type == "cable" else GridManager.pipes.size()
			if count >= m.amount:
				complete_milestone(m_id)

## Finalizes a milestone, grants rewards, and emits the completion signal.
func complete_milestone(id: String):
	if not active_milestones.has(id): return
	var m = active_milestones[id]
	
	# Grant Rewards
	if m.has("reward_isotopes"): EconomyManager.add_resource("isotopes", m.reward_isotopes)
	if m.has("reward_credits"): EconomyManager.add_resource("credits", m.reward_credits)
	
	completed_milestones.append(id)
	active_milestones.erase(id)
	milestone_completed.emit(id, m.title)
	print("MISSION: Milestone Completed! ", m.title)

## Spawns a new anomaly at a random empty location on the grid.
func spawn_random_anomaly():
	var found = false
	var pos = Vector2i.ZERO
	for i in range(50): # Increased search attempts
		pos = Vector2i(randi_range(10, 90), randi_range(10, 90))
		if not GridManager.is_tile_occupied(pos) and not GridManager.has_cable(pos) and not GridManager.has_pipe(pos):
			found = true
			break
	
	if found:
		_create_anomaly_node(pos)

func _create_anomaly_node(pos: Vector2i):
	var anomaly_scene = load("res://scenes/Anomaly.tscn")
	var instance = anomaly_scene.instantiate()
	var world = get_tree().root.find_child("World", true, false)
	if world:
		world.add_child(instance)
		instance.global_position = GridManager.grid_to_world(pos)
		instance.grid_position = pos
		anomaly_spawned.emit(pos)

## Unlocks a breakthrough and applies its global effect.
func unlock_breakthrough(id: String):
	if breakthroughs_db.has(id) and not unlocked_breakthroughs.has(id):
		unlocked_breakthroughs.append(id)
		breakthrough_unlocked.emit(id, breakthroughs_db[id].title)
		_apply_breakthrough_effect(id)
		
		# Refresh Tech Tree if visible
		var tech_tree = get_tree().root.find_child("TechnologyTree", true, false)
		if tech_tree and tech_tree.visible:
			tech_tree.populate_tree()

## Applies the specific logic associated with a breakthrough to the game state.
func _apply_breakthrough_effect(id: String):
	var b = breakthroughs_db[id]
	print("BREAKTHROUGH ACTIVE: ", b.title)
	
	# Integrate with EconomyManager global multipliers
	if b.bonus_type == "prod_mult":
		EconomyManager.add_global_multiplier(b.target, b.val)
	elif b.bonus_type == "cost_reduction":
		EconomyManager.add_cost_reduction(b.target, b.val)
	elif b.bonus_type == "wear_reduction":
		# This will be checked in Building.gd apply_wear
		pass

## Requests a supply pod from Earth to land at a specific grid position.
func request_supply_pod(item_type: String, grid_pos: Vector2i):
	print("MISSION: Supply pod requested for ", item_type, " at ", grid_pos)
	# Simulate landing time (10 seconds)
	get_tree().create_timer(10.0).timeout.connect(func():
		if item_type == "rover":
			_spawn_rover(grid_pos)
	)

func _spawn_rover(grid_pos: Vector2i):
	var rover_scene = load("res://scenes/Rover.tscn")
	var instance = rover_scene.instantiate()
	var world = get_tree().root.find_child("World", true, false)
	if world:
		world.add_child(instance)
		# Spawn slightly offset from the pad center
		instance.global_position = GridManager.grid_to_world(grid_pos) + Vector2(64, 64)
		print("MISSION: Rover deployed at ", grid_pos)
