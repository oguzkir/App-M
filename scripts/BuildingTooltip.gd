extends CanvasLayer

@onready var panel = $Panel
@onready var name_label = $Panel/VBox/NameLabel
@onready var status_label = $Panel/VBox/StatusLabel
@onready var prod_label = $Panel/VBox/ProductionLabel

func _ready():
	hide_tooltip()

func _process(_delta):
	if visible:
		# Follow mouse with offset
		panel.global_position = get_viewport().get_mouse_position() + Vector2(20, 20)

func show_tooltip(building: Node2D):
	var data = building.data
	name_label.text = data.building_name
	
	if building.is_operational:
		status_label.text = "Operational"
		status_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		status_label.text = "Offline"
		status_label.add_theme_color_override("font_color", Color.RED)
		
	prod_label.text = "+" + str(building.get_effective_production()) + " " + data.production_type.capitalize()
	visible = true

func hide_tooltip():
	visible = false
