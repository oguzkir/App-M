extends Button

var data: BuildingResource
var build_menu: CanvasLayer

@onready var name_label = $VBoxContainer/NameLabel
@onready var cost_label = $VBoxContainer/CostLabel
@onready var status_label = $VBoxContainer/StatusLabel

func setup(b_data: BuildingResource, menu: CanvasLayer):
	data = b_data
	build_menu = menu
	update_ui()

func update_ui():
	if not data:
		name_label.text = "Error"
		cost_label.text = "N/A"
		status_label.text = "[HATA]"
		return
		
	name_label.text = data.building_name
	cost_label.text = str(data.base_cost) + " 💰"
	
	var is_unlocked = build_menu.is_building_unlocked(data.building_name)
	var can_afford = EconomyManager.resources["credits"] >= data.base_cost
	
	if is_unlocked:
		if can_afford:
			modulate = Color(1, 1, 1) # Normal
			status_label.text = "[INSA EDILEBILIR]"
			disabled = false
		else:
			modulate = Color(1, 0.6, 0.6) # Reddish (No money)
			status_label.text = "[KREDI YETERSIZ]"
			disabled = false # Still clickable to show error? Or disabled?
	else:
		modulate = Color(0.4, 0.4, 0.4) # Dark gray (Locked)
		status_label.text = "[KILITLI]"
		disabled = false # Let's keep it clickable to show requirements?

func _pressed():
	var is_unlocked = build_menu.is_building_unlocked(data.building_name)
	if not is_unlocked:
		print("UI: Prerequisite buildings or terraforming levels not met!")
		return
		
	if EconomyManager.resources["credits"] < data.base_cost:
		print("UI: Not enough credits!")
		return
		
	build_menu.on_building_selected(data)
