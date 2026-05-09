extends Node2D

# Advanced Procedural Mars Terrain
# Uses FastNoiseLite to generate textures like the reference images

var noise = FastNoiseLite.new()

func _ready():
	noise.seed = randi()
	noise.frequency = 0.05
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	queue_redraw()

func _draw():
	var tile_size = GridManager.tile_size
	var grid_width = 100
	var grid_height = 100
	
	# Draw base Mars color
	draw_rect(Rect2(0, 0, grid_width * tile_size, grid_height * tile_size), Color(0.6, 0.25, 0.15))

	# Procedurally draw terrain variations (rocks, craters, shadows)
	# This mimics the "Surviving Mars" ground texture
	for x in range(0, grid_width * tile_size, 16):
		for y in range(0, grid_height * tile_size, 16):
			var val = noise.get_noise_2d(x, y)
			if val > 0.2: # Highlights / Rocks
				draw_rect(Rect2(x, y, 16, 16), Color(0.7, 0.35, 0.2, 0.15))
			elif val < -0.2: # Shadows / Depressions
				draw_rect(Rect2(x, y, 16, 16), Color(0.4, 0.15, 0.1, 0.2))

	# Draw Subtle Grid Lines
	var grid_color = Color(0, 0, 0, 0.1)
	for x in range(grid_width + 1):
		draw_line(Vector2(x * tile_size, 0), Vector2(x * tile_size, grid_height * tile_size), grid_color, 1.0)
	for y in range(grid_height + 1):
		draw_line(Vector2(0, y * tile_size), Vector2(grid_width * tile_size, y * tile_size), grid_color, 1.0)
