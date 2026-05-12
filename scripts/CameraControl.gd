extends Camera2D

# Camera Control Settings
var min_zoom = 0.5
var max_zoom = 3.0
var zoom_speed = 0.1
var pan_speed = 1.0

func _ready():
	# Initial Limits setup
	call_deferred("update_limits")

func update_limits():
	# Set camera boundaries to match map size
	var map_size = GridManager.get_map_world_size()
	limit_left = 0
	limit_top = 0
	limit_right = int(map_size.x)
	limit_bottom = int(map_size.y)
	
	# Clamp position immediately to stay within new limits
	position.x = clamp(position.x, limit_left, limit_right)
	position.y = clamp(position.y, limit_top, limit_bottom)

func _unhandled_input(event):
	# Mouse Zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_camera(zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_camera(-zoom_speed)
	
	# Pan Control
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_RIGHT or event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			# Apply movement and Godot's built-in limits will handle clamping
			position -= event.relative * (1.0 / zoom.x)

func zoom_camera(delta):
	var new_zoom = clamp(zoom.x + delta, min_zoom, max_zoom)
	zoom = Vector2(new_zoom, new_zoom)

# Screenshake logic
var shake_amount: float = 0.0
var default_offset: Vector2 = Vector2.ZERO

func apply_shake(duration: float, strength: float):
	shake_amount = strength
	var tween = create_tween()
	tween.tween_property(self, "shake_amount", 0.0, duration)

func _process(_delta):
	if shake_amount > 0:
		offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
	else:
		offset = default_offset
