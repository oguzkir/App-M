extends CanvasLayer

@onready var title = $Panel/VBoxContainer/Title
@onready var status = $Panel/VBoxContainer/Status
@onready var production = $Panel/VBoxContainer/ProductionLabel
@onready var consumption = $Panel/VBoxContainer/ConsumptionLabel
@onready var manager_label = $Panel/VBoxContainer/ManagerSection/Label

var current_building: Node2D

func _ready():
	$Panel/VBoxContainer/CloseButton.pressed.connect(hide_panel)
	$Panel/VBoxContainer/ManagerSection/AssignButton.pressed.connect(_on_assign_pressed)
	
	# Connect to manager selection signal
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel:
		selection_panel.manager_selected.connect(_on_manager_selected)

func _on_assign_pressed():
	var selection_panel = get_tree().root.find_child("ManagerSelectionPanel", true, false)
	if selection_panel:
		selection_panel.show_panel()

func _on_manager_selected(manager: ManagerResource):
	if visible and current_building:
		current_building.assign_manager(manager)
		show_building(current_building) # Refresh panel

func show_building(building: Node2D):
	current_building = building
	var data = building.data
	title.text = data.building_name
	status.text = "Status: " + ("Operational" if building.is_operational else "Offline (Blackout)")
	production.text = "Production: +" + str(building.get_effective_production()) + " " + data.production_type.capitalize()
	
	var cons_text = "Consumption: "
	for res in data.input_resources:
		cons_text += "-" + str(building.get_consumption(res)) + " " + res.capitalize() + " "
	consumption.text = cons_text
	
	if building.assigned_manager:
		manager_label.text = "Manager: " + building.assigned_manager.manager_name + " (T" + str(building.assigned_manager.tier + 1) + ")"
	else:
		manager_label.text = "Manager: None"
		
	visible = true

func hide_panel():
	visible = false
