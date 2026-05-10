extends TileMapLayer

# FINAL FIX FOR PERSISTENCE
# This script will NOT clear the map if use_procedural is false.

@export var use_procedural: bool = false # ENSURE THIS IS FALSE IN INSPECTOR
@export var grid_width: int = 250
@export var grid_height: int = 250

# Tileset coordinates (Used ONLY if use_procedural is true)
var flat_tiles = [Vector2i(13, 7), Vector2i(45, 8)]
var cracked_tile = Vector2i(21, 8)
var rocky_tiles = [Vector2i(33, 8), Vector2i(39, 8)]

var noise = FastNoiseLite.new()

func _ready():
	# Sync dimensions with GridManager
	GridManager.map_width = grid_width
	GridManager.map_height = grid_height
	
	if use_procedural:
		print("TileMapManager: Procedural mode ACTIVE. Clearing and generating...")
		noise.seed = randi()
		noise.frequency = 0.05
		noise.noise_type = FastNoiseLite.TYPE_PERLIN
		noise.fractal_octaves = 4
		fill_world_procedural()
	else:
		print("TileMapManager: Manual mode active. KEEEPING existing tiles.")

func fill_world_procedural():
	clear() # Only clears if we explicitly want procedural generation
	var rng = RandomNumberGenerator.new()
	rng.seed = noise.seed
	
	for x in range(grid_width):
		for y in range(grid_height):
			var noise_val = noise.get_noise_2d(x, y)
			var target_tile: Vector2i
			
			if noise_val > 0.35:
				target_tile = rocky_tiles[rng.randi() % rocky_tiles.size()]
			elif noise_val < -0.3:
				target_tile = cracked_tile
			else:
				if rng.randf() > 0.8:
					target_tile = flat_tiles[1]
				else:
					target_tile = flat_tiles[0]
					
			set_cell(Vector2i(x, y), 0, target_tile)
