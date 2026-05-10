extends TileMapLayer

# PASSIVE MODE: No tiles are placed automatically.
# This script only handles map dimensions for the Camera.
# PAINT EVERYTHING MANUALLY in the Godot Editor.

@export var grid_width: int = 250
@export var grid_height: int = 250

func _ready():
	# Sync dimensions with GridManager for camera limits
	GridManager.map_width = grid_width
	GridManager.map_height = grid_height
	
	print("TileMapManager: Passive mode active. Camera limits set to ", grid_width, "x", grid_height)
	# NO clear(), NO set_cell(). Total manual control.
