extends Node2D

# GridVisualizer is now silenced to remove all lines, rulers, and artifacts.
# This ensures only the user's TileMap is visible.

func _draw():
	# No drawing code here = clean ground.
	pass

func _ready():
	queue_redraw()
