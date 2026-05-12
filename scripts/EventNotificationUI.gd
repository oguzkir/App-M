extends CanvasLayer

@onready var banner = $Control/Banner
@onready var title_label = $Control/Banner/VBoxContainer/EventTitle
@onready var desc_label = $Control/Banner/VBoxContainer/EventDesc
@onready var overlay = $Control/Overlay

func _ready():
	var event_manager = get_node_or_null("/root/WorldEventManager")
	if event_manager:
		event_manager.event_started.connect(_on_event_started)
		event_manager.event_ended.connect(_on_event_ended)
	
	banner.visible = false
	overlay.color.a = 0.0

func _on_event_started(event_name: String, duration: float, _effects: Dictionary):
	title_label.text = "UYARI: " + event_name.to_upper()
	
	# Set description based on event type (passed in effects or name)
	match event_name:
		"Kum Firtinasi":
			desc_label.text = "Güneş panelleri verimi düştü. Rüzgar türbinleri hızlandı!"
			_animate_overlay(Color(0.8, 0.4, 0.1, 0.4), 2.0)
		"Radyasyon Patlamasi":
			desc_label.text = "Yöneticiler stres altında. Moral kaybı hızlandı!"
			_animate_overlay(Color(0.5, 0.0, 1.0, 0.2), 2.0)
		"Meteor Yagmuru":
			desc_label.text = "Gökten taş yağıyor! Binalar hasar alabilir."
			_animate_overlay(Color(1, 0, 0, 0.1), 0.5)
			_shake_screen(duration)
		"Ikmal Gemisi":
			desc_label.text = "Dünya'dan yardim geldi! Market indirimleri aktif."
			title_label.text = "MÜJDE: " + event_name.to_upper()
			title_label.add_theme_color_override("font_color", Color(0, 0.8, 1))
			_animate_overlay(Color(0, 0.5, 1.0, 0.15), 1.0)

	_show_banner()

func _on_event_ended(event_name: String):
	_hide_banner()
	_animate_overlay(Color(0, 0, 0, 0), 3.0)
	print("UI: Event ", event_name, " ended.")

func show_custom_notification(title: String, description: String, color: Color = Color.WHITE):
	title_label.text = title
	desc_label.text = description
	title_label.add_theme_color_override("font_color", color)
	_show_banner()

func _show_banner():
	banner.visible = true
	banner.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(banner, "modulate:a", 1.0, 0.5)
	tween.tween_interval(5.0)
	tween.tween_property(banner, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): banner.visible = false)

func _hide_banner():
	# Optionally show a "Cleared" message
	pass

func _animate_overlay(target_color: Color, time: float):
	var tween = create_tween()
	tween.tween_property(overlay, "color", target_color, time)

func _shake_screen(duration: float):
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("apply_shake"):
		camera.apply_shake(duration, 10.0)
