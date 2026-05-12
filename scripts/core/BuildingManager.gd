extends Node2D

## Singleton: BuildingManager
## Responsible for handling the placement of buildings and infrastructure (cables/pipes).
## Manages ghost visuals during placement and validates grid constraints.

# --- Preloads ---
var building_scene = load("res://scenes/Building.tscn")

# --- Placement State ---
var current_selected_building: BuildingResource
var is_placing: bool = false
var is_placing_infra: bool = false
var is_dragging_infra: bool = false
var infra_type: String = "" # "cable" or "pipe"
var ghost_building: Sprite2D
var last_placed_grid_pos: Vector2i = Vector2i(-999, -999)

## Starts the placement mode for a specific building or infrastructure.
func start_placement(building_data: BuildingResource):
	cancel_placement()
		
	current_selected_building = building_data
	
	# Determine if we are placing a standard building or infrastructure
	if building_data.building_name == "Kablo":
		is_placing_infra = true
		infra_type = "cable"
	elif building_data.building_name == "Boru":
		is_placing_infra = true
		infra_type = "pipe"
	else:
		is_placing = true
	
	# Create a ghost visual that follows the mouse
	ghost_building = Sprite2D.new()
	if building_data.sprite:
		ghost_building.texture = building_data.sprite
		# Scale down by 75% (set scale to 0.25) to match Building.gd
		ghost_building.scale = Vector2(0.25, 0.25)
	else:
		# Fallback visual for infrastructure without a defined sprite
		var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		ghost_building.texture = ImageTexture.create_from_image(img)
		
	ghost_building.modulate = Color(1, 1, 1, 0.5)
	ghost_building.z_index = 50
	add_child(ghost_building)

func _process(_delta):
	if (is_placing or is_placing_infra) and ghost_building:
		var mouse_pos = get_global_mouse_position()
		var grid_pos = GridManager.world_to_grid(mouse_pos)
		
		# Center ghost building based on footprint
		if is_placing:
			var size = current_selected_building.footprint
			var offset = Vector2(size.x - 1, size.y - 1) * (GridManager.tile_size / 2.0)
			ghost_building.global_position = GridManager.grid_to_world(grid_pos) + offset
		else:
			ghost_building.global_position = GridManager.grid_to_world(grid_pos)
		
		# Visual feedback for placement validity
		var can_place = true
		if is_placing:
			var size = current_selected_building.footprint
			if GridManager.is_area_occupied(grid_pos, size) or EconomyManager.resources["credits"] < current_selected_building.base_cost:
				can_place = false
		else: # Infrastructure cost check
			var cost = EconomyManager.get_infrastructure_cost(infra_type)
			if EconomyManager.resources["metal"] < cost:
				can_place = false
			elif GridManager.is_tile_occupied(grid_pos):
				can_place = false # Cannot place cable/pipe on a building tile
		
		ghost_building.modulate = Color(0, 1, 0, 0.5) if can_place else Color(1, 0, 0, 0.5)

func _unhandled_input(event):
	# Standard Building Placement
	if is_placing:
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				place_building(get_global_mouse_position())
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_placement()
				get_viewport().set_input_as_handled()
	
	# Infrastructure Placement (supports drag-to-build)
	elif is_placing_infra:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					is_dragging_infra = true
					place_infra(get_global_mouse_position())
				else:
					is_dragging_infra = false
					last_placed_grid_pos = Vector2i(-999, -999)
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				cancel_placement()
				get_viewport().set_input_as_handled()
		
		elif event is InputEventMouseMotion and is_dragging_infra:
			place_infra(get_global_mouse_position())

## Cancels placement mode and cleans up visuals.
func cancel_placement():
	is_placing = false
	is_placing_infra = false
	is_dragging_infra = false
	last_placed_grid_pos = Vector2i(-999, -999)
	if ghost_building:
		ghost_building.queue_free()
		ghost_building = null

## Places a single infrastructure tile (cable or pipe).
func place_infra(world_pos: Vector2):
	var grid_pos = GridManager.world_to_grid(world_pos)
	
	# Prevent redundant placement on the same tile during a single drag action
	if grid_pos == last_placed_grid_pos: return
	
	# Check if the tile already contains the requested infrastructure
	if infra_type == "cable" and GridManager.has_cable(grid_pos): return
	if infra_type == "pipe" and GridManager.has_pipe(grid_pos): return
	
	var cost = EconomyManager.get_infrastructure_cost(infra_type)
	if EconomyManager.consume_resource("metal", cost):
		if infra_type == "cable":
			GridManager.add_cable(grid_pos)
			MissionManager.check_infra_milestone("cable")
		else:
			GridManager.add_pipe(grid_pos)
			MissionManager.check_infra_milestone("pipe")
		
		last_placed_grid_pos = grid_pos
		# Recalculate power/pipe networks
		EconomyManager._update_grid_connectivity()
	else:
		print("BuildingManager: Not enough metal for infrastructure!")
		is_dragging_infra = false 

## Places a standard building at the specified location.
func place_building(world_pos: Vector2):
	var grid_pos = GridManager.world_to_grid(world_pos)
	var size = current_selected_building.footprint
	
	if GridManager.is_area_occupied(grid_pos, size):
		print("BuildingManager: Area occupied!")
		return
		
	if EconomyManager.consume_resource("credits", current_selected_building.base_cost):
		var new_building = building_scene.instantiate()
		new_building.setup(current_selected_building, grid_pos)
		
		# Center physical position based on footprint
		var offset = Vector2(size.x - 1, size.y - 1) * (GridManager.tile_size / 2.0)
		new_building.global_position = GridManager.grid_to_world(grid_pos) + offset
		
		var world = get_tree().root.find_child("World", true, false)
		if world:
			world.add_child(new_building)
			GridManager.set_area_occupied(grid_pos, size, new_building)
			# Notify mission system
			MissionManager.check_build_milestone(current_selected_building.building_name)
			print("BuildingManager: Placed ", current_selected_building.building_name, " with size ", size)
		else:
			print("BuildingManager Error: Could not find 'World' node!")
	else:
		print("BuildingManager: Not enough credits!")
