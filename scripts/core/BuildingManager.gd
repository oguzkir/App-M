extends Node2D

# Singleton: BuildingManager
# Handles building placement logic

var building_scene = preload("res://scenes/Building.tscn")
var current_selected_building: BuildingResource
var is_placing: bool = false
var ghost_building: Sprite2D

func start_placement(building_data: BuildingResource):
	# Clean up old ghost if exists
	if ghost_building:
		ghost_building.queue_free()
		
	current_selected_building = building_data
	is_placing = true
	
	# Create ghost visual
	ghost_building = Sprite2D.new()
	ghost_building.texture = building_data.sprite
	ghost_building.modulate = Color(1, 1, 1, 0.5) # Semi-transparent
	ghost_building.z_index = 50 # Ensure it's on top
	add_child(ghost_building)
	print("BuildingManager: Placement started for ", building_data.building_name)

func _process(_delta):
	if is_placing and ghost_building:
		var mouse_pos = get_global_mouse_position()
		var grid_pos = GridManager.world_to_grid(mouse_pos)
		ghost_building.global_position = GridManager.grid_to_world(grid_pos)
		
		# Validation Visual
		if GridManager.is_tile_occupied(grid_pos) or not EconomyManager.resources["credits"] >= current_selected_building.base_cost:
			ghost_building.modulate = Color(1, 0, 0, 0.5) # Red for invalid
		else:
			ghost_building.modulate = Color(0, 1, 0, 0.5) # Green for valid

func _unhandled_input(event):
	if is_placing:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				place_building(get_global_mouse_position())
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				cancel_placement()

func cancel_placement():
	is_placing = false
	if ghost_building:
		ghost_building.queue_free()
		ghost_building = null
	print("BuildingManager: Placement cancelled.")

func place_building(world_pos: Vector2):
	var grid_pos = GridManager.world_to_grid(world_pos)
	
	if GridManager.is_tile_occupied(grid_pos):
		print("BuildingManager: Tile occupied!")
		return
		
	if EconomyManager.consume_resource("credits", current_selected_building.base_cost):
		var new_building = building_scene.instantiate()
		new_building.setup(current_selected_building, grid_pos)
		new_building.global_position = GridManager.grid_to_world(grid_pos)
		
		# Find World node and add building
		var world = get_tree().root.find_child("World", true, false)
		if world:
			world.add_child(new_building)
			GridManager.set_tile_occupied(grid_pos, new_building)
			print("BuildingManager: Placed ", current_selected_building.building_name)
		else:
			print("BuildingManager Error: Could not find 'World' node!")
	else:
		print("BuildingManager: Not enough credits!")
