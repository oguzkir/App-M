extends Camera2D

# Camera Control Settings
var min_zoom = 0.5
var max_zoom = 2.0
var zoom_speed = 0.1
var pan_speed = 1.0

func _unhandled_input(event):
	# Mouse Zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_speed)
	
	# Pan Control (Right Mouse Click or Touch Drag)
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_RIGHT or event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			position -= event.relative * (1.0 / zoom.x)

func zoom_camera(delta):
	var new_zoom = clamp(zoom.x + delta, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)
