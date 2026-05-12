extends CanvasLayer

@onready var tree_content = $Panel/VBoxContainer/ScrollContainer/TreeContent
@onready var connections = $Panel/VBoxContainer/ScrollContainer/TreeContent/Connections
@onready var nodes_container = $Panel/VBoxContainer/ScrollContainer/TreeContent/Nodes
@onready var close_button = $Panel/VBoxContainer/CloseButton

var node_scene = preload("res://ui/TechNode.tscn")

func _ready():
	close_button.pressed.connect(func(): visible = false)
	visibility_changed.connect(_on_visibility_changed)
	populate_tree()
	
	# Handle custom drawing for connections
	connections.draw.connect(_on_connections_draw)

func _on_visibility_changed():
	if visible:
		populate_tree()

func populate_tree():
	# Clear existing nodes
	for child in nodes_container.get_children():
		child.queue_free()
		
	# 1. Instantiate standard tech nodes
	for tech_id in ResearchManager.tech_data.keys():
		var tech_data = ResearchManager.tech_data[tech_id]
		var node = node_scene.instantiate()
		nodes_container.add_child(node)
		node.setup(tech_id, tech_data)
		node.position = tech_data.position
	
	# 2. Instantiate Breakthrough nodes (at the bottom row)
	var bt_count = 0
	for bt_id in MissionManager.unlocked_breakthroughs:
		if MissionManager.breakthroughs_db.has(bt_id):
			var bt_data = MissionManager.breakthroughs_db[bt_id]
			var node = node_scene.instantiate()
			nodes_container.add_child(node)
			
			# Reuse TechNodeResource structure for Breakthroughs
			var dummy_tech = TechNodeResource.new()
			dummy_tech.display_name = "[BT] " + bt_data.title
			dummy_tech.description = bt_data.desc
			dummy_tech.cost = 0 # Free
			
			node.setup(bt_id, dummy_tech)
			# Position breakthroughs in a row at Y=750 (adjusting based on current tech grid)
			node.position = Vector2(50 + (bt_count * 250), 750)
			node.modulate = Color(1, 0.8, 0.2) # Golden/Breakthrough color
			bt_count += 1

	connections.queue_redraw()

func _on_connections_draw():
	for tech_id in ResearchManager.tech_data.keys():
		var tech_data = ResearchManager.tech_data[tech_id]
		for prereq_id in tech_data.prerequisites:
			if ResearchManager.tech_data.has(prereq_id):
				var prereq_data = ResearchManager.tech_data[prereq_id]
				
				# Calculate start and end points for the line
				var start = prereq_data.position + Vector2(200, 50) # Right side of prereq
				var end = tech_data.position + Vector2(0, 50) # Left side of current tech
				
				var color = Color(0.3, 0.3, 0.5)
				if ResearchManager.is_tech_unlocked(prereq_id):
					color = Color(0.5, 0.8, 1.0)
					
				connections.draw_line(start, end, color, 3.0, true)
