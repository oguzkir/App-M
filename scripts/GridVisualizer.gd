extends Node2D

# Advanced Grid & Terrain Visualizer
# Draws a textured-like Mars surface and a clear grid

func _draw():
	var tile_size = GridManager.tile_size
	var grid_width = 100
	var grid_height = 100
	
	# 1. Draw "Mars-y" Base with Noise-like pattern
	# Instead of a flat rect, we draw multiple tinted rects for "texture"
	draw_rect(Rect2(0, 0, grid_width * tile_size, grid_height * tile_size), Color(0.65, 0.25, 0.15))
	
	var rng = RandomNumberGenerator.new()
	rng.seed = 42 # Constant seed for consistent "terrain"
	
	# Draw some "craters" and "rocks" (simple circles and rects for now)
	for i in range(200):
		var pos = Vector2(rng.randf_range(0, grid_width * tile_size), rng.randf_range(0, grid_height * tile_size))
		var size = rng.randf_range(10, 50)
		var color_tint = Color(0.5, 0.2, 0.1, 0.3)
		draw_circle(pos, size, color_tint)
		
	# 2. Draw Sharp Grid
	var grid_color = Color(0, 0, 0, 0.2)
	for x in range(grid_width + 1):
		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, grid_height * tile_size), grid_color, 1.5)
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * tile_size), Vector2(grid_width * tile_size, y * tile_size), grid_color, 1.5)

func _ready():
	queue_redraw()
