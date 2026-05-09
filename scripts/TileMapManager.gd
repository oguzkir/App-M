extends TileMapLayer

# Automatically fills a region with the base tile from the TileSet
@export var grid_width: int = 100
@export var grid_height: int = 100

func _ready():
	fill_world()

func fill_world():
	# Fills with the tile at atlas coordinates (0,0) from source 0
	for x in range(grid_width):
		for y in range(grid_height):
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
