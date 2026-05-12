extends CanvasLayer

@onready var title = $Panel/VBoxContainer/Title
@onready var status = $Panel/VBoxContainer/Status
@onready var production = $Panel/VBoxContainer/ProductionLabel
@onready var consumption = $Panel/VBoxContainer/ConsumptionLabel
@onready var manager_label = $Panel/VBoxContainer/ManagerSection/Label
@onready var tier_label = $Panel/VBoxContainer/TierLabel
@onready var upgrade_button = $Panel/VBoxContainer/UpgradeButton
@onready var repair_button = $Panel/VBoxContainer/RepairButton
@onready var miracle_button = $Panel/VBoxContainer/ManagerSection/MiracleButton
@onready var logistics_section = $Panel/VBoxContainer/LogisticsSection
@onready var order_rover_button = $Panel/VBoxContainer/LogisticsSection/OrderRoverButton

var current_building: Node2D

func _ready():
	$Panel/VBoxContainer/CloseButton.pressed.connect(hide_panel)
	$Panel/VBoxContainer/ManagerSection/AssignButton.pressed.connect(_on_assign_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	repair_button.pressed.connect(_on_repair_pressed)
	miracle_button.pressed.connect(_on_miracle_pressed)
	order_rover_button.pressed.connect(_on_order_rover_pressed)
	
	# Connect to manager selection signal
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel:
		selection_panel.manager_selected.connect(_on_manager_selected)

func _on_miracle_pressed():
	if current_building and current_building.assigned_manager:
		EconomyManager.use_miracle(current_building.assigned_manager)
		show_building(current_building) # Refresh

func _on_repair_pressed():
	if current_building and current_building.has_method("repair"):
		if current_building.repair():
			show_building(current_building)

func _on_upgrade_pressed():
	if current_building and current_building.has_method("upgrade"):
		if current_building.upgrade():
			show_building(current_building) # Refresh

func _on_assign_pressed():
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel:
		selection_panel.show_panel()

func _on_manager_selected(manager: ManagerResource):
	if visible and current_building:
		current_building.assign_manager(manager)
		show_building(current_building) # Refresh panel

func _on_order_rover_pressed():
	if EconomyManager.consume_resource("credits", 2000):
		print("UI: Rover ordered!")
		MissionManager.request_supply_pod("rover", current_building.grid_position)
		hide_panel()
	else:
		print("UI: Not enough credits for Rover!")

func show_building(building: Node2D):
	current_building = building
	var data = building.data
	
	# Show logistics only for Landing Pad
	if logistics_section:
		logistics_section.visible = (data.building_name == "Landing Pad")
	
	title.text = data.building_name
	status.text = "Status: " + ("Operational" if building.is_operational else "Offline (Blackout)")
	tier_label.text = "Level: Tier " + str(building.current_tier)
	
	if building.current_tier < 5:
		upgrade_button.text = "Upgrade (Cost: " + str(building.get_upgrade_cost()) + ")"
		upgrade_button.disabled = false
	else:
		upgrade_button.text = "Max Level Reached"
		upgrade_button.disabled = true

	var prod_name = data.production_type.capitalize()
	if data.production_type == "water_terra": prod_name = "Planet Water"
	elif data.production_type == "temperature": prod_name = "Planet Heat"
	
	production.text = "Production: +" + str(snapped(building.get_effective_production(), 0.01)) + " " + prod_name
	
	# Condition & Repair
	var repair_text = "\nCondition: " + str(int(building.condition)) + "%"
	status.text = "Status: " + ("Operational" if building.is_operational else "Disabled") + repair_text
	
	var cons_text = "Consumption: "
	for res in data.input_resources:
		cons_text += "-" + str(building.get_consumption(res)) + " " + res.capitalize() + " "
	consumption.text = cons_text
	
	if building.assigned_manager:
		manager_label.text = "Manager: " + building.assigned_manager.manager_name + " (T" + str(building.assigned_manager.tier + 1) + ")"
		miracle_button.visible = building.assigned_manager.can_use_miracle()
		if miracle_button.visible:
			miracle_button.text = "ACTIVATE: " + building.assigned_manager.miracle_name
	else:
		manager_label.text = "Manager: None"
		miracle_button.visible = false
		
	visible = true

func hide_panel():
	visible = false
