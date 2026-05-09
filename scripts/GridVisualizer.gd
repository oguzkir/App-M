extends Node2D

func _draw():
	var tile_size = GridManager.tile_size
	var grid_color = Color(1, 1, 1, 0.1) # Very faint white
	var line_width = 1.0
	
	# Draw a large enough grid (e.g., 50x50 tiles)
	var grid_width = 50
	var grid_height = 80
	
	for x in range(grid_width + 1):
		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, grid_height * tile_size), grid_color, line_width)
	
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * tile_size), Vector2(grid_width * tile_size, y * tile_size), grid_color, line_width)

func _ready():
	# Redraw if tile_size changes (though it shouldn't at runtime here)
	queue_redraw()
