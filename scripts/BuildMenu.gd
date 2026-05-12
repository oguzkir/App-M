extends CanvasLayer

@onready var tree_content = $Panel/VBoxContainer/ScrollContainer/TreeContent
@onready var connections = $Panel/VBoxContainer/ScrollContainer/TreeContent/Connections
@onready var nodes_container = $Panel/VBoxContainer/ScrollContainer/TreeContent/Nodes
@onready var construction_button = $BottomBar/Panel/HBoxContainer/ConstructionButton
@onready var managers_button = $BottomBar/Panel/HBoxContainer/ManagersButton
@onready var tech_button = $BottomBar/Panel/HBoxContainer/TechButton
@onready var shop_button = $BottomBar/Panel/HBoxContainer/ShopButton
@onready var close_button = $Panel/VBoxContainer/CloseButton

var node_scene = preload("res://ui/BuildingNode.tscn")

# Building Data & Tree Structure
var tree_config = {
	"Solar Panel": {"pos": Vector2(50, 100), "prereqs": [], "cat": "Enerji"},
	"Wind Turbine": {"pos": Vector2(300, 50), "prereqs": ["Solar Panel"], "cat": "Enerji"},
	"Power Accumulator": {"pos": Vector2(300, 150), "prereqs": ["Solar Panel"], "cat": "Enerji"},
	
	"Oxygen Generator": {"pos": Vector2(50, 350), "prereqs": [], "cat": "Hava"},
	"Oxygen Tank": {"pos": Vector2(300, 350), "prereqs": ["Oxygen Generator"], "cat": "Hava"},
	"Electrolyzer": {"pos": Vector2(550, 350), "prereqs": ["Oxygen Tank"], "cat": "Hava"},
	
	"Water Pump": {"pos": Vector2(50, 600), "prereqs": [], "cat": "Su"},
	"Water Tower": {"pos": Vector2(300, 600), "prereqs": ["Water Pump"], "cat": "Su"},
	"Moisture Vaporator": {"pos": Vector2(550, 600), "prereqs": ["Water Tower"], "cat": "Su"},
	
	"Metal Mine": {"pos": Vector2(50, 850), "prereqs": [], "cat": "Sanayi"},
	"Concrete Plant": {"pos": Vector2(300, 850), "prereqs": ["Metal Mine"], "cat": "Sanayi"},
	"Dumping Site": {"pos": Vector2(550, 800), "prereqs": ["Concrete Plant"], "cat": "Sanayi"},
	"Universal Depot": {"pos": Vector2(550, 900), "prereqs": ["Concrete Plant"], "cat": "Sanayi"},
	"Landing Pad": {"pos": Vector2(800, 850), "prereqs": ["Universal Depot"], "cat": "Sanayi"},
	
	"Research Lab": {"pos": Vector2(50, 1100), "prereqs": [], "cat": "Bilim"},
	
	"Kablo": {"pos": Vector2(50, 1350), "prereqs": [], "cat": "Altyapı", "is_infra": true, "type": "cable"},
	"Boru": {"pos": Vector2(300, 1350), "prereqs": [], "cat": "Altyapı", "is_infra": true, "type": "pipe"},

	"Mars Farm": {
		"pos": Vector2(900, 500), 
		"prereqs": ["Electrolyzer", "Moisture Vaporator", "Universal Depot"], 
		"cat": "Yaşam",
		"tf_req": {"water": 10.0, "temperature": 10.0}
	}
}

var buildings_resources = {}

func _ready():
	_load_resources()
	construction_button.pressed.connect(func(): visible = !visible)
	managers_button.pressed.connect(_on_managers_pressed)
	tech_button.pressed.connect(_on_tech_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	close_button.pressed.connect(func(): visible = false)
	
	connections.draw.connect(_on_connections_draw)
	visibility_changed.connect(_on_visibility_changed)
	
	populate_tree()

func _load_resources():
	var paths = {
		"Solar Panel": "res://resources/buildings/SolarPanel.tres",
		"Wind Turbine": "res://resources/buildings/WindTurbine.tres",
		"Power Accumulator": "res://resources/buildings/BatteryUnit.tres",
		"Oxygen Generator": "res://resources/buildings/OxygenGenerator.tres",
		"Oxygen Tank": "res://resources/buildings/OxygenTank.tres",
		"Electrolyzer": "res://resources/buildings/Electrolyzer.tres",
		"Water Pump": "res://resources/buildings/WaterPump.tres",
		"Water Tower": "res://resources/buildings/WaterTower.tres",
		"Moisture Vaporator": "res://resources/buildings/WaterExtractor.tres", # Vaporator path?
		"Metal Mine": "res://resources/buildings/MetalsExtractor.tres",
		"Concrete Plant": "res://resources/buildings/ConcreteExtractor.tres",
		"Dumping Site": "res://resources/buildings/DumpingSite.tres",
		"Universal Depot": "res://resources/buildings/UniversalDepot.tres",
		"Research Lab": "res://resources/buildings/ResearchLab.tres",
		"Mars Farm": "res://resources/buildings/MarsFarm.tres"
	}
	for b_name in paths:
		if FileAccess.file_exists(paths[b_name]):
			buildings_resources[b_name] = load(paths[b_name])

func _on_visibility_changed():
	if visible:
		populate_tree()

func populate_tree():
	for child in nodes_container.get_children():
		child.queue_free()
		
	for b_name in tree_config.keys():
		var config = tree_config[b_name]
		
		if config.has("is_infra"):
			# Special handling for Cable/Pipe
			var infra_node = node_scene.instantiate()
			nodes_container.add_child(infra_node)
			
			# Create a dummy resource for UI display
			var dummy = BuildingResource.new()
			dummy.building_name = b_name
			dummy.construction_costs = {"metal": 1} # 1 Metal
			infra_node.setup(dummy, self)
			infra_node.position = config["pos"]
			continue

		if not buildings_resources.has(b_name): continue
		
		var node = node_scene.instantiate()
		nodes_container.add_child(node)
		node.setup(buildings_resources[b_name], self)
		node.position = config["pos"]
		
	connections.queue_redraw()

func is_building_unlocked(b_name: String) -> bool:
	if not tree_config.has(b_name): return true
	var config = tree_config[b_name]
	
	# 1. Check Prerequisite buildings constructed
	for prereq in config["prereqs"]:
		var found = false
		for building in EconomyManager.active_buildings:
			if building.data.building_name == prereq:
				found = true
				break
		if not found: return false
		
	# 2. Check Terraforming Requirements
	if config.has("tf_req"):
		var reqs = config["tf_req"]
		for stat in reqs:
			if TerraformingManager.stats.get(stat, 0.0) < reqs[stat]:
				return false
				
	return true

func on_building_selected(data: BuildingResource):
	BuildingManager.start_placement(data)
	visible = false

func _on_connections_draw():
	for b_name in tree_config.keys():
		var config = tree_config[b_name]
		for prereq_name in config["prereqs"]:
			if tree_config.has(prereq_name):
				var prereq_config = tree_config[prereq_name]
				
				var start = prereq_config["pos"] + Vector2(220, 55)
				var end = config["pos"] + Vector2(0, 55)
				
				# Actually, the path is open if the PREREQUISITE building is BUILT.
				var prereq_built = false
				for building in EconomyManager.active_buildings:
					if building.data.building_name == prereq_name:
						prereq_built = true
						break
				
				var color = Color(0.5, 0.8, 1.0) if prereq_built else Color(0.3, 0.3, 0.3)
				connections.draw_line(start, end, color, 4.0, true)

func _on_managers_pressed():
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel: selection_panel.show_panel()

func _on_tech_pressed():
	var tech_panel = get_tree().root.find_child("TechnologyTree", true, false)
	if tech_panel: tech_panel.visible = !tech_panel.visible

func _on_shop_pressed():
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel: selection_panel.show_panel()
