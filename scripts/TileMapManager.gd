extends TileMapLayer

## TileMapManager
## Responsible for generating the Martian terrain using noise 
## and handling visual terraforming transitions.

@export var grid_width: int = 100
@export var grid_height: int = 100
@export var ground_tile_coords: Vector2i = Vector2i(0, 0) 

var base_soil_color = Color("#964514") # Mars Red-Brown
var lush_grass_color = Color("#9BA385") # Surviving Mars Sage Green

var noise: FastNoiseLite

func _ready():
	# Sync dimensions with GridManager
	GridManager.map_width = grid_width
	GridManager.map_height = grid_height
	
	_setup_noise()
	_fill_ground()
	
	# Connect to Terraforming updates to shift soil color
	var tf = get_node_or_null("/root/TerraformingManager")
	if tf:
		tf.terraforming_updated.connect(_on_terraforming_updated)

func _setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.05
	noise.fractal_octaves = 3

func _on_terraforming_updated(stats: Dictionary):
	# Calculate global vegetation/water influence (0.0 to 1.0)
	var progress = (stats["vegetation"] + stats["water"]) / 200.0
	var current_color = base_soil_color.lerp(lush_grass_color, progress)
	modulate = current_color

func _fill_ground():
	clear()
	for x in range(grid_width):
		for y in range(grid_height):
			var n_val = noise.get_noise_2d(x, y)
			
			# Logic for topography:
			# - Hills: Noise > 0.4
			# - Craters: Noise < -0.4
			# - Flat: Otherwise
			
			var tile_pos = ground_tile_coords # Default flat
			
			if n_val > 0.45:
				# Simulation of Hills: We could use a different tile here
				# For now, we tell GridManager this is an obstacle
				GridManager.update_astar_tile(Vector2i(x, y), true)
			elif n_val < -0.45:
				# Simulation of Craters
				GridManager.update_astar_tile(Vector2i(x, y), true)
			
			set_cell(Vector2i(x, y), 0, tile_pos)
			
			# Apply slight local variation for more "organic" 2D look
			var variation = 1.0 + (n_val * 0.1)
			# (In a real TileMap we might use alternative tiles, 
			# but here we can use per-cell modulation in Godot 4 if using custom drawing, 
			# but TileMapLayer doesn't support easy per-cell modulation without individual nodes.
			# So we'll stick to a clean flat look with obstacle logic).
	
	print("TileMapManager: Martian topography generated (", grid_width, "x", grid_height, ")")
