extends Node2D

# Singleton: BuildingManager
# Handles building placement logic

var building_scene = preload("res://scenes/Building.tscn")
var current_selected_building: BuildingResource
var is_placing: bool = false
var ghost_building: Node2D

func start_placement(building_data: BuildingResource):
	current_selected_building = building_data
	is_placing = true
	
	# Create ghost
	ghost_building = Sprite2D.new()
	# ghost_building.texture = building_data.sprite
	ghost_building.modulate = Color(1, 1, 1, 0.5) # Semi-transparent
	add_child(ghost_building)

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
	if is_placing and event.is_action_pressed("ui_accept"): # Simplified for now
		var mouse_pos = get_global_mouse_position()
		place_building(mouse_pos)

func place_building(world_pos: Vector2):
	var grid_pos = GridManager.world_to_grid(world_pos)
	
	if GridManager.is_tile_occupied(grid_pos):
		print("Tile occupied!")
		return
		
	if EconomyManager.consume_resource("credits", current_selected_building.base_cost):
		var new_building = building_scene.instantiate()
		new_building.setup(current_selected_building, grid_pos)
		new_building.global_position = GridManager.grid_to_world(grid_pos)
		
		# Add to World (Need to find world node)
		get_tree().root.find_child("World", true, false).add_child(new_building)
		GridManager.set_tile_occupied(grid_pos, new_building)
		
		# End placement if desired (or keep placing)
		# is_placing = false
		# ghost_building.queue_free()
	else:
		print("Not enough credits!")
