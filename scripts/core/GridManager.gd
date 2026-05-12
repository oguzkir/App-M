extends Node2D

# Singleton: GridManager
# Handles coordinate conversions and tile occupancy

@export var tile_size: int = 32
var map_width: int = 100
var map_height: int = 100
var occupied_tiles: Dictionary = {} # Key: Vector2i (Grid Coords), Value: Building Instance
var terrain_obstacles: Dictionary = {} # Key: Vector2i, Value: bool
var cables: Dictionary = {} # Vector2i -> bool
var pipes: Dictionary = {} # Vector2i -> bool

var astar: AStarGrid2D

func _ready():
	_setup_astar()

func _init_astar():
	astar = AStarGrid2D.new()
	astar.region = Rect2i(0, 0, map_width, map_height)
	astar.cell_size = Vector2(tile_size, tile_size)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()

func _setup_astar():
	_init_astar()
	# Initial update
	for pos in occupied_tiles.keys():
		astar.set_point_solid(pos, true)

func update_astar_tile(pos: Vector2i, solid: bool):
	if astar:
		astar.set_point_solid(pos, solid)
	if solid:
		terrain_obstacles[pos] = true
	else:
		terrain_obstacles.erase(pos)

func get_map_world_size() -> Vector2:
	return Vector2(map_width * tile_size, map_height * tile_size)

func add_cable(pos: Vector2i):
	cables[pos] = true
	_refresh_infrastructure_visuals()

func add_pipe(pos: Vector2i):
	pipes[pos] = true
	_refresh_infrastructure_visuals()

func has_cable(pos: Vector2i) -> bool:
	return cables.has(pos)

func has_pipe(pos: Vector2i) -> bool:
	return pipes.has(pos)

func _refresh_infrastructure_visuals():
	var layer = get_tree().root.find_child("InfrastructureLayer", true, false)
	if layer and layer.has_method("queue_redraw_infrastructure"):
		layer.queue_redraw_infrastructure()

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floor(world_pos.x / tile_size),
		floor(world_pos.y / tile_size)
	)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * tile_size + (tile_size / 2.0),
		grid_pos.y * tile_size + (tile_size / 2.0)
	)

func is_tile_occupied(grid_pos: Vector2i) -> bool:
	return occupied_tiles.has(grid_pos) or terrain_obstacles.has(grid_pos)

func is_area_occupied(grid_pos: Vector2i, size: Vector2i) -> bool:
	for x in range(size.x):
		for y in range(size.y):
			var check_pos = grid_pos + Vector2i(x, y)
			if occupied_tiles.has(check_pos) or terrain_obstacles.has(check_pos):
				return true
	return false

func set_tile_occupied(grid_pos: Vector2i, building: Node2D):
	occupied_tiles[grid_pos] = building

func set_area_occupied(grid_pos: Vector2i, size: Vector2i, building: Node2D):
	for x in range(size.x):
		for y in range(size.y):
			var pos = grid_pos + Vector2i(x, y)
			occupied_tiles[pos] = building
			update_astar_tile(pos, true)

func remove_tile_occupied(grid_pos: Vector2i):
	if occupied_tiles.has(grid_pos):
		occupied_tiles.erase(grid_pos)
		update_astar_tile(grid_pos, false)

func remove_area_occupied(grid_pos: Vector2i, size: Vector2i):
	for x in range(size.x):
		for y in range(size.y):
			var pos = grid_pos + Vector2i(x, y)
			if occupied_tiles.has(pos):
				occupied_tiles.erase(pos)
				update_astar_tile(pos, false)
