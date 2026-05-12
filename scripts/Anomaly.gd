extends Node2D

var grid_position: Vector2i
var is_scanning: bool = false
var scan_progress: float = 0.0
const SCAN_TIME = 20.0 # Seconds

@onready var sprite = $Sprite2D
@onready var progress_bar = $ProgressBar

func _ready():
	progress_bar.visible = false
	# Pulse animation
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "modulate:a", 0.3, 1.0)
	tween.tween_property(sprite, "modulate:a", 1.0, 1.0)

func _process(delta):
	if is_scanning:
		scan_progress += delta
		progress_bar.value = (scan_progress / SCAN_TIME) * 100.0
		if scan_progress >= SCAN_TIME:
			_complete_scan()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("ANOMALY: Needs a Rover to scan this location!")

func _start_scan():
	if is_scanning: return
	if EconomyManager.resources["research"] >= 50:
		EconomyManager.consume_resource("research", 50)
		is_scanning = true
		progress_bar.visible = true
		print("ANOMALY: Scanning started at ", grid_position)
	else:
		print("ANOMALY: Not enough Research points to scan!")

func _complete_scan():
	is_scanning = false
	# Determine reward
	var roll = randf()
	if roll < 0.3: # 30% Breakthrough
		var b_id = MissionManager.breakthrough_db.keys().pick_random()
		MissionManager.unlock_breakthrough(b_id)
	elif roll < 0.7: # 40% Resources
		EconomyManager.add_resource("isotopes", 15)
		EconomyManager.add_resource("metal", 50)
		print("ANOMALY: Resource cache found!")
	else: # 30% Science boost
		EconomyManager.add_resource("research", 200)
		print("ANOMALY: Data boost found!")
	
	queue_free()
