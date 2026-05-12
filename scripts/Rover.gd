extends CharacterBody2D

var speed = 150.0
var path: Array[Vector2] = []
var target_anomaly: Node2D = null
var is_scanning: bool = false
var is_selected: bool = false

@onready var sprite = $Sprite2D
@onready var selection_ring = $SelectionRing

func _ready():
	selection_ring.visible = false
	input_pickable = true

func _input(event):
	if is_selected and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var mouse_pos = get_global_mouse_position()
			_move_to(mouse_pos)
			
			# Check if clicking on an anomaly
			_check_for_anomaly_at(mouse_pos)

func _move_to(world_pos: Vector2):
	var grid_start = GridManager.world_to_grid(global_position)
	var grid_end = GridManager.world_to_grid(world_pos)
	
	if GridManager.astar:
		var grid_path = GridManager.astar.get_id_path(grid_start, grid_end)
		path.clear()
		for p in grid_path:
			path.append(GridManager.grid_to_world(p))
		
		# If path is too long or no path, fallback to direct (if target is obstacle)
		if path.is_empty() and grid_start != grid_end:
			path = [world_pos]

func _check_for_anomaly_at(world_pos: Vector2):
	target_anomaly = null
	# Find anomaly at this position
	var world = get_parent()
	for child in world.get_children():
		if child.name.begins_with("Anomaly"):
			if child.global_position.distance_to(world_pos) < 32.0:
				target_anomaly = child
				print("ROVER: Targeted Anomaly at ", target_anomaly.grid_position)
				break

func _physics_process(delta):
	if is_scanning: return
	
	if not path.is_empty():
		var target = path[0]
		var direction = (target - global_position).normalized()
		velocity = direction * speed
		
		if global_position.distance_to(target) < 5.0:
			path.remove_at(0)
			if path.is_empty():
				velocity = Vector2.ZERO
				_on_reached_destination()
		
		move_and_slide()

func _on_reached_destination():
	if target_anomaly and global_position.distance_to(target_anomaly.global_position) < 64.0:
		_start_scanning()

func _start_scanning():
	if target_anomaly and target_anomaly.has_method("_start_scan"):
		is_scanning = true
		target_anomaly._start_scan()
		# Wait for anomaly to finish (anomaly queue_frees itself)
		target_anomaly.tree_exited.connect(func(): 
			is_scanning = false
			target_anomaly = null
		)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_set_selected(true)
		get_viewport().set_input_as_handled()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_set_selected(false)

func _set_selected(state: bool):
	is_selected = state
	selection_ring.visible = state
	if state:
		print("ROVER: Selected")
