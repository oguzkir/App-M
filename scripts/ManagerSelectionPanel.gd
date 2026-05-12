extends CanvasLayer

signal manager_selected(manager)

@onready var list_container = $Panel/VBoxContainer/ScrollContainer/ManagerList
@onready var hire_button = $Panel/VBoxContainer/HireButton

# Player inventory of managers
var available_managers: Array[ManagerResource] = []

func _ready():
	$Panel/VBoxContainer/CancelButton.pressed.connect(hide_panel)
	hire_button.pressed.connect(_on_hire_pressed)
	
	# Initial managers
	available_managers.append(preload("res://resources/managers/Stark.tres"))
	available_managers.append(preload("res://resources/managers/Nova.tres"))
	
	# Listen for new hires
	var hiring_manager = get_node_or_null("/root/HiringManager")
	if hiring_manager:
		hiring_manager.manager_hired.connect(_on_manager_hired)
		
	populate_list()

func _on_hire_pressed():
	var hiring_manager = get_node_or_null("/root/HiringManager")
	if hiring_manager:
		hiring_manager.hire_random_manager()

func _on_manager_hired(manager: ManagerResource):
	available_managers.append(manager)
	populate_list()
	print("UI: New manager added to list: ", manager.manager_name)

func populate_list():
	for child in list_container.get_children():
		child.queue_free()
		
	for manager in available_managers:
		var btn = Button.new()
		var rarity_names = ["Common", "Rare", "Epic", "Legendary"]
		var rarity_name = rarity_names[manager.tier] if manager.tier < rarity_names.size() else "Elite"
		
		# Find if assigned
		var assignment_text = ""
		var is_assigned = false
		for b in EconomyManager.active_buildings:
			if b.assigned_manager == manager:
				assignment_text = "\n[Atandi: " + b.data.building_name + "]"
				is_assigned = true
				break
		
		btn.text = manager.manager_name + " [" + rarity_name + "]" + assignment_text + "\nBoost: +" + str(int((manager.production_boost - 1.0) * 100)) + "%"
		btn.custom_minimum_size = Vector2(0, 100)
		
		# Affinity Check (If choosing for a specific building)
		var current_building = _get_current_info_panel_building()
		if current_building:
			var can_work = EconomyManager.can_manager_work_at(manager, current_building)
			if not can_work:
				btn.modulate = Color(1, 0.4, 0.4) # Reddish
				btn.text += "\n(UYUMSUZ SEKTOR)"
				btn.disabled = true
			elif is_assigned:
				btn.disabled = true # Already working elsewhere
		
		btn.pressed.connect(_on_manager_btn_pressed.bind(manager))
		list_container.add_child(btn)

func _get_current_info_panel_building() -> Node2D:
	var info_panel = get_tree().root.find_child("BuildingInfoPanel", true, false)
	if info_panel and info_panel.visible:
		return info_panel.current_building
	return null

func _on_manager_btn_pressed(manager: ManagerResource):
	emit_signal("manager_selected", manager)
	hide_panel()

func show_panel():
	populate_list() # Refresh list every time it opens
	visible = true

func hide_panel():
	visible = false
