extends Node2D

# Only draws the grid lines now, no background!
# This allows the TileMapLayer beneath it to be visible.

func _draw():
	var tile_size = GridManager.tile_size
	var grid_width = 100
	var grid_height = 100
	
	# Draw Subtle Grid Lines
	var grid_color = Color(0, 0, 0, 0.1)
	for x in range(grid_width + 1):
		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, grid_height * tile_size), grid_color, 1.0)
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * tile_size), Vector2(grid_width * tile_size, y * tile_size), grid_color, 1.0)

func _ready():
	queue_redraw()
