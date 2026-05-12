extends Node

# Singleton: SaveManager
# Handles encrypted saving and loading of game state

const SAVE_PATH = "user://mars_tycoon.save"
const SECRET_KEY = "MARS_SECRET_PROT_99"

var current_save: SaveData

func _ready():
	# Wait a bit for other managers to initialize
	await get_tree().process_frame
	load_game()

func save_game():
	if not current_save:
		current_save = SaveData.new()
	
	current_save.resources = EconomyManager.resources.duplicate()
	current_save.last_save_time = int(Time.get_unix_time_from_system())
	
	_pack_buildings()
	_pack_managers()
	_pack_research()
	_pack_terraforming()
	
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, SECRET_KEY)
	if file:
		var json_string = JSON.stringify(_to_dict(current_save))
		file.store_string(json_string)
		file.close()
		print("SaveManager: Game Saved Successfully.")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: No save file found. Starting fresh.")
		current_save = SaveData.new()
		return

	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, SECRET_KEY)
	if file:
		var json_string = file.get_as_text()
		var data_dict = JSON.parse_string(json_string)
		if data_dict:
			_from_dict(data_dict)
			_unpack_all()
			print("SaveManager: Game Loaded.")
			_process_offline_time()
		file.close()
	else:
		print("SaveManager Error: Could not decrypt or read save file.")
		current_save = SaveData.new()

func _pack_buildings():
	current_save.building_data.clear()
	for building in EconomyManager.active_buildings:
		var b_info = {
			"res_path": building.data.resource_path,
			"pos_x": building.grid_position.x,
			"pos_y": building.grid_position.y,
			"tier": building.current_tier,
			"condition": building.condition,
			"legacy": building.legacy_bonuses,
			"manager": building.assigned_manager.to_dict() if building.assigned_manager else null
		}
		current_save.building_data.append(b_info)

	current_save.cables = GridManager.cables.duplicate()
	current_save.pipes = GridManager.pipes.duplicate()

func _pack_managers():
	current_save.manager_inventory.clear()
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel:
		for manager in selection_panel.available_managers:
			current_save.manager_inventory.append(manager.to_dict())

func _pack_research():
	current_save.unlocked_techs = ResearchManager.unlocked_techs.duplicate()
	current_save.completed_milestones = MissionManager.completed_milestones.duplicate()
	current_save.unlocked_breakthroughs = MissionManager.unlocked_breakthroughs.duplicate()

func _pack_terraforming():
	current_save.terraforming_stats = TerraformingManager.stats.duplicate()

func _unpack_all():
	# 1. Resources
	EconomyManager.resources = current_save.resources.duplicate()
	
	# 2. Research & Missions
	ResearchManager.unlocked_techs = current_save.unlocked_techs.duplicate()
	MissionManager.completed_milestones = current_save.completed_milestones.duplicate()
	MissionManager.unlocked_breakthroughs = current_save.unlocked_breakthroughs.duplicate()
	MissionManager._init_milestones() # Refresh active list

	# 3. Terraforming
	TerraformingManager.stats = current_save.terraforming_stats.duplicate()
	
	# 4. Infrastructure
	GridManager.cables = current_save.cables.duplicate()
	GridManager.pipes = current_save.pipes.duplicate()
	GridManager._refresh_infrastructure_visuals()

	# 5. Managers Inventory
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel:
		selection_panel.available_managers.clear()
		for m_dict in current_save.manager_inventory:
			selection_panel.available_managers.append(ManagerResource.from_dict(m_dict))
		selection_panel.populate_list()
	
	# 5. Buildings
	_reconstruct_buildings()

func _reconstruct_buildings():
	# Clear existing buildings
	var buildings_to_remove = EconomyManager.active_buildings.duplicate()
	for b in buildings_to_remove:
		GridManager.occupied_tiles.erase(b.grid_position)
		EconomyManager.unregister_building(b)
		b.queue_free()
	
	# Instantiate saved buildings
	var world = get_tree().root.find_child("World", true, false)
	if not world: return
	
	var building_scene = load("res://scenes/Building.tscn")
	
	for b_info in current_save.building_data:
		var res = load(b_info["res_path"])
		if res:
			var new_building = building_scene.instantiate()
			var pos = Vector2i(b_info["pos_x"], b_info["pos_y"])
			new_building.setup(res, pos)
			new_building.global_position = GridManager.grid_to_world(pos)
			new_building.current_tier = b_info["tier"]
			new_building.condition = b_info["condition"]
			new_building.legacy_bonuses = b_info["legacy"]
			
			if b_info["manager"]:
				var m = ManagerResource.from_dict(b_info["manager"])
				new_building.assign_manager(m)
			
			world.add_child(new_building)
			GridManager.set_tile_occupied(pos, new_building)

func _process_offline_time():
	var now = Time.get_unix_time_from_system()
	var diff = now - current_save.last_save_time
	
	if diff < 0:
		print("SaveManager WARNING: Time travel detected!")
		return
		
	if diff > 60:
		print("SaveManager: Processing ", diff, " seconds of offline time.")
		EconomyManager.process_offline_production(int(diff))

func _to_dict(res: SaveData) -> Dictionary:
	return {
		"version": res.app_version,
		"time": res.last_save_time,
		"resources": res.resources,
		"buildings": res.building_data,
		"inventory": res.manager_inventory,
		"research": res.unlocked_techs,
		"terraforming": res.terraforming_stats
	}

func _from_dict(dict: Dictionary):
	current_save = SaveData.new()
	current_save.app_version = dict.get("version", "1.0.0")
	current_save.last_save_time = int(dict.get("time", 0))
	current_save.resources = dict.get("resources", current_save.resources)
	
	var b_data = dict.get("buildings", [])
	current_save.building_data.clear()
	for b in b_data:
		current_save.building_data.append(b as Dictionary)
		
	var m_data = dict.get("inventory", [])
	current_save.manager_inventory.clear()
	for m in m_data:
		current_save.manager_inventory.append(m as Dictionary)
		
	var r_data = dict.get("research", [])
	current_save.unlocked_techs.clear()
	for r in r_data:
		current_save.unlocked_techs.append(r as String)
		
	current_save.terraforming_stats = dict.get("terraforming", current_save.terraforming_stats)
