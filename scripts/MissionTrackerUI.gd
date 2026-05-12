extends CanvasLayer

@onready var mission_list = $Control/Panel/VBoxContainer/ScrollContainer/MissionList

func _ready():
	MissionManager.milestone_completed.connect(func(_id, _title): update_list())
	# For real-time terraforming updates, connect to EconomyManager
	EconomyManager.economy_updated.connect(func(_s): update_list())
	update_list()

func update_list():
	for child in mission_list.get_children():
		child.queue_free()
		
	for m_id in MissionManager.active_milestones.keys():
		var m = MissionManager.active_milestones[m_id]
		var label = Label.new()
		label.text = "• " + m.title + "\n  " + m.desc
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.add_theme_font_size_override("font_size", 14)
		mission_list.add_child(label)
