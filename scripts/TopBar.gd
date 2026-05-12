extends CanvasLayer

@onready var isotopes_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/IsotopesButton
@onready var energy_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/EnergyButton
@onready var oxygen_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/OxygenButton
@onready var water_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/WaterButton
@onready var food_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/FoodButton
@onready var metal_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/MetalButton
@onready var concrete_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/ConcreteButton
@onready var waste_button = $Panel/MarginContainer/VBoxContainer/ResourceRow/WasteButton

@onready var research_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/ResearchLabel
@onready var moral_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/MoralLabel

# Terraforming Labels
@onready var temp_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/TempLabel
@onready var water_terra_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/WaterTerraLabel
@onready var atmo_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/AtmoLabel
@onready var veg_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/VegLabel

@onready var sol_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/SolLabel
@onready var time_label = $Panel/MarginContainer/VBoxContainer/SecondaryRow/TimeLabel

var current_display_values: Dictionary = {}

func _ready():
	# Hide credits label if it exists
	var credits_node = get_node_or_null("Panel/MarginContainer/VBoxContainer/ResourceRow/CreditsLabel")
	if credits_node: credits_node.hide()
	
	# Initialize display values
	for res in EconomyManager.resources.keys():
		current_display_values[res] = float(EconomyManager.resources[res])
	
	update_ui(EconomyManager.resources)
	EconomyManager.economy_updated.connect(update_ui)
	
	# Connect to TimeManager
	TimeManager.hour_passed.connect(_on_hour_passed)
	TimeManager.sol_passed.connect(_on_sol_passed)
	_update_time_display()
	
	# Icon Loading with Debug
	var icons_to_load = {
		"electricity": energy_button,
		"water": water_button,
		"isotope": isotopes_button,
		"oxygen": oxygen_button,
		"food": food_button,
		"metal": metal_button,
		"concrete": concrete_button,
		"waste_rock": waste_button
	}
	
	for icon_name in icons_to_load:
		var path = "res://assets/images/icons/" + icon_name + ".png"
		var tex = load(path)
		if tex:
			var btn = icons_to_load[icon_name]
			btn.icon = tex
			btn.expand_icon = true
			btn.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
			print("UI: Loaded icon ", icon_name)
		else:
			push_error("UI ERROR: Could not load icon at " + path)
	
	# Energy breakdown click handler
	energy_button.pressed.connect(_on_energy_pressed)
	energy_button.mouse_entered.connect(_on_energy_mouse_entered)
	
	# Water breakdown click handler
	water_button.pressed.connect(_on_water_pressed)
	water_button.mouse_entered.connect(_on_water_mouse_entered)
	
	# Connect to Terraforming
	var tf_manager = get_node_or_null("/root/TerraformingManager")
	if tf_manager:
		tf_manager.terraforming_updated.connect(update_terraforming_ui)

func update_ui(target_resources):
	var tween = create_tween().set_parallel(true)
	
	for res in target_resources.keys():
		if not current_display_values.has(res):
			current_display_values[res] = 0.0
			
		tween.tween_method(
			func(val): _set_label_text(res, val),
			current_display_values[res],
			float(target_resources[res]),
			0.5 # Duration
		)
		current_display_values[res] = float(target_resources[res])
	
	# Update tooltip even if amount didn't change (e.g. production/consumption fluctuated)
	_update_energy_tooltip()
	_update_water_tooltip()

func _update_energy_tooltip():
	var stats = EconomyManager.last_energy_stats
	var tooltip_text = "⚡ ENERJİ ANALİZİ\n"
	tooltip_text += "Üretim: +" + str(int(stats["production"])) + "\n"
	tooltip_text += "Tüketim: -" + str(int(stats["consumption"])) + "\n"
	tooltip_text += "Net Akış: " + (str(int(stats["net"])) if stats["net"] <= 0 else "+" + str(int(stats["net"])))
	energy_button.tooltip_text = tooltip_text

func _on_energy_mouse_entered():
	_update_energy_tooltip()

func _update_water_tooltip():
	var stats = EconomyManager.last_water_stats
	var tooltip_text = "💧 SU ANALİZİ\n"
	tooltip_text += "Üretim: +" + str(int(stats["production"])) + "\n"
	tooltip_text += "Tüketim: -" + str(int(stats["consumption"])) + "\n"
	tooltip_text += "Net Akış: " + (str(int(stats["net"])) if stats["net"] <= 0 else "+" + str(int(stats["net"])))
	water_button.tooltip_text = tooltip_text

func _on_water_mouse_entered():
	_update_water_tooltip()

func update_terraforming_ui(stats: Dictionary):
	temp_label.text = "🌡️ " + str(snapped(stats["temperature"], 0.01)) + "%"
	water_terra_label.text = "🌊 " + str(snapped(stats["water"], 0.01)) + "%"
	atmo_label.text = "☁️ " + str(snapped(stats["atmosphere"], 0.01)) + "%"
	veg_label.text = "🌿 " + str(snapped(stats["vegetation"], 0.01)) + "%"

func _on_energy_pressed():
	var stats = EconomyManager.last_energy_stats
	var title = "ENERJI ANALIZI"
	var desc = "Üretim: +" + str(int(stats["production"])) + " | "
	desc += "Tüketim: -" + str(int(stats["consumption"])) + "\n"
	desc += "Net Akış: " + (str(int(stats["net"])) if stats["net"] <= 0 else "+" + str(int(stats["net"])))
	
	var event_ui = get_tree().root.find_child("EventNotification", true, false)
	if event_ui and event_ui.has_method("show_custom_notification"):
		var color = Color(0, 0.8, 1) if stats["net"] >= 0 else Color(1, 0.3, 0.3)
		event_ui.show_custom_notification(title, desc, color)
	else:
		print("⚡ " + title + ": " + desc)

func _on_water_pressed():
	var stats = EconomyManager.last_water_stats
	var title = "SU ANALİZİ"
	var desc = "Üretim: +" + str(int(stats["production"])) + " | "
	desc += "Tüketim: -" + str(int(stats["consumption"])) + "\n"
	desc += "Net Akış: " + (str(int(stats["net"])) if stats["net"] <= 0 else "+" + str(int(stats["net"])))
	
	var event_ui = get_tree().root.find_child("EventNotification", true, false)
	if event_ui and event_ui.has_method("show_custom_notification"):
		var color = Color(0, 0.5, 1.0) if stats["net"] >= 0 else Color(1, 0.3, 0.3)
		event_ui.show_custom_notification(title, desc, color)
	else:
		print("💧 " + title + ": " + desc)

func _update_time_display():
	sol_label.text = "SOL " + str(TimeManager.current_sol)
	var hours = int(TimeManager.current_hour)
	var mins = int((TimeManager.current_hour - hours) * 60)
	time_label.text = "%02d:%02d" % [hours, mins]

func _on_hour_passed(_hour):
	_update_time_display()

func _on_sol_passed(_sol):
	_update_time_display()

func _set_label_text(type: String, value: float):
	var label = null
	var prefix = ""
	var hud_blue = Color("#00AEEF")
	
	match type:
		"isotopes": 
			isotopes_button.text = str(int(value))
			return
		"energy": 
			energy_button.text = str(int(value))
			return
		"oxygen": 
			oxygen_button.text = str(int(value))
			return
		"water": 
			water_button.text = str(int(value))
			return
		"food": 
			food_button.text = str(int(value))
			return
		"metal":
			metal_button.text = str(int(value))
			return
		"concrete":
			concrete_button.text = str(int(value))
			return
		"waste_rock":
			waste_button.text = str(int(value))
			return
		"research":
			label = research_label
			prefix = "🔬 "
		"moral":
			label = moral_label
			prefix = "😊 "
	
	if label:
		label.text = prefix + str(int(value))
		label.add_theme_color_override("font_color", hud_blue)
