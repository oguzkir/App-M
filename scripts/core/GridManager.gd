extends Node2D

# Singleton: GridManager
# Handles coordinate conversions and tile occupancy

@export var tile_size: int = 32
var map_width: int = 100
var map_height: int = 100
var occupied_tiles: Dictionary = {} # Key: Vector2i (Grid Coords), Value: Building Instance

func get_map_world_size() -> Vector2:
	return Vector2(map_width * tile_size, map_height * tile_size)

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
	return occupied_tiles.has(grid_pos)

func set_tile_occupied(grid_pos: Vector2i, building: Node2D):
	occupied_tiles[grid_pos] = building

func remove_tile_occupied(grid_pos: Vector2i):
	if occupied_tiles.has(grid_pos):
		occupied_tiles.erase(grid_pos)
