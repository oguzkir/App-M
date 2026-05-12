extends Node2D

func _draw():
	# Draw Cables (Yellow/Orange)
	for pos in GridManager.cables.keys():
		var center = GridManager.grid_to_world(pos)
		draw_rect(Rect2(center - Vector2(4, 4), Vector2(8, 8)), Color(1, 0.7, 0))
		
		# Draw connections to neighbors
		for dir in [Vector2i.RIGHT, Vector2i.DOWN]:
			var neighbor = pos + dir
			if GridManager.has_cable(neighbor):
				var n_center = GridManager.grid_to_world(neighbor)
				draw_line(center, n_center, Color(1, 0.7, 0), 2.0)

	# Draw Pipes (Blue Tinted Texture)
	var pipe_tex = preload("res://assets/images/buildings/pipe.png")
	for pos in GridManager.pipes.keys():
		var center = GridManager.grid_to_world(pos)
		draw_texture_rect(pipe_tex, Rect2(center - Vector2(8, 8), Vector2(16, 16)), false, Color(0.4, 0.7, 1.0))
		
		# Draw connections to neighbors
		for dir in [Vector2i.RIGHT, Vector2i.DOWN]:
			var neighbor = pos + dir
			if GridManager.has_pipe(neighbor):
				var n_center = GridManager.grid_to_world(neighbor)
				draw_line(center, n_center, Color(0, 0.5, 1.0), 3.0)

func queue_redraw_infrastructure():
	queue_redraw()
