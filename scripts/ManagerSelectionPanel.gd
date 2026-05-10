extends CanvasLayer

signal manager_selected(manager)

@onready var list_container = $Panel/VBoxContainer/ScrollContainer/ManagerList

# Mock player inventory for now
var available_managers = [
	preload("res://resources/managers/Stark.tres"),
	preload("res://resources/managers/Nova.tres")
]

func _ready():
	$Panel/VBoxContainer/CancelButton.pressed.connect(hide_panel)
	populate_list()

func populate_list():
	for manager in available_managers:
		var btn = Button.new()
		btn.text = manager.manager_name + " (T" + str(manager.tier + 1) + ")\nBoost: +" + str(int((manager.production_boost - 1.0) * 100)) + "%"
		btn.custom_minimum_size = Vector2(0, 80)
		btn.pressed.connect(_on_manager_btn_pressed.bind(manager))
		list_container.add_child(btn)

func _on_manager_btn_pressed(manager: ManagerResource):
	emit_signal("manager_selected", manager)
	hide_panel()

func show_panel():
	visible = true

func hide_panel():
	visible = false
