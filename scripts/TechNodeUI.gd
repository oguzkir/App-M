extends Button

var tech_id: String
var data: TechNodeResource

@onready var name_label = $VBoxContainer/NameLabel
@onready var cost_label = $VBoxContainer/CostLabel

func setup(t_id: String, t_data: TechNodeResource):
	tech_id = t_id
	data = t_data
	update_ui()

func update_ui():
	name_label.text = data.display_name
	cost_label.text = str(data.cost) + " TP"
	
	var is_unlocked = ResearchManager.is_tech_unlocked(tech_id)
	var can_unlock = ResearchManager.can_unlock_tech(tech_id)
	
	if is_unlocked:
		modulate = Color(0.5, 1, 0.5) # Greenish
		disabled = true
		cost_label.text = "[ACILDI]"
	elif can_unlock:
		modulate = Color(1, 1, 1) # White
		disabled = false
	else:
		modulate = Color(0.5, 0.5, 0.5) # Grayish
		disabled = false # Still clickable to show requirements? Or disabled?
		# Let's keep it clickable to show why it's locked in a tooltip later.
		# For now, let's make it look locked.

func _pressed():
	if ResearchManager.unlock_tech(tech_id):
		get_parent().get_parent().get_parent().get_parent().get_parent().populate_tree()
