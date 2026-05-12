extends Node

# Singleton: ResearchManager
# Tracks unlocked technologies and applies global bonuses

signal tech_unlocked(tech_id)

var unlocked_techs: Array[String] = []
var tech_data: Dictionary = {}

func _ready():
	_init_tech_data()

func is_tech_unlocked(tech_id: String) -> bool:
	return unlocked_techs.has(tech_id)

func can_unlock_tech(tech_id: String) -> bool:
	if not tech_data.has(tech_id): return false
	if unlocked_techs.has(tech_id): return false
	
	var tech = tech_data[tech_id]
	for prereq in tech.prerequisites:
		if not unlocked_techs.has(prereq):
			return false
			
	return EconomyManager.resources["research"] >= tech.cost

func unlock_tech(tech_id: String) -> bool:
	if not tech_data.has(tech_id): return false
	var tech = tech_data[tech_id]
	
	if can_unlock_tech(tech_id):
		if EconomyManager.consume_resource("research", tech.cost):
			unlocked_techs.append(tech_id)
			_apply_tech_bonus(tech)
			tech_unlocked.emit(tech_id)
			print("ResearchManager: Unlocked ", tech_id)
			return true
	return false

func _apply_tech_bonus(tech: TechNodeResource):
	# Apply global modifiers based on tech
	match tech.bonus_type:
		"production_boost":
			# This would be handled by buildings checking for tech
			pass
		"new_building":
			# This would unlock buttons in BuildMenu
			pass
		"consumption_reduction":
			pass
	
	# Update all buildings to reflect potential new bonuses
	for building in EconomyManager.active_buildings:
		if building.has_method("_update_visual_state"):
			building._update_visual_state()

func _init_tech_data():
	# Industrial
	_add_tech("advanced_mining", "Gelismiş Madencilik", "Metal Madeni üretimi +%10", 500, "Industrial", [], Vector2(100, 100))
	_add_tech("concrete_poly", "Beton Polimerizasyonu", "Beton Extractor verimi +%15", 1200, "Industrial", ["advanced_mining"], Vector2(300, 100))
	_add_tech("auto_repair", "Otomatik Onarım Botları", "Bina aşınma hızı -%20", 5000, "Industrial", ["concrete_poly"], Vector2(500, 100))
	
	# Life Support
	_add_tech("water_vaporizers", "Nem Buharlaştırıcılar", "Moisture Vaporator üretimi +%15", 600, "Life Support", [], Vector2(100, 300))
	_add_tech("high_eff_moxie", "Yüksek Verimli MOXIE", "MOXIE su tüketimi -%10", 2500, "Life Support", ["water_vaporizers"], Vector2(300, 300))
	_add_tech("mars_greenhouses", "Mars Seraları", "Yeni Bina: Hydroponic Farm", 7500, "Life Support", ["high_eff_moxie"], Vector2(500, 300))
	
	# Energy
	_add_tech("graphene_batteries", "Grafen Bataryalar", "Batarya kapasitesi +%25", 800, "Energy", [], Vector2(100, 500))
	_add_tech("solar_coating", "Solar Panel Kaplama", "Kum fırtınası verim kaybı -%50", 3500, "Energy", ["graphene_batteries"], Vector2(300, 500))
	_add_tech("grid_opt", "Şebeke Optimizasyonu", "Kablolu iletim verimi artar", 10000, "Energy", ["solar_coating"], Vector2(500, 500))

func _add_tech(id, d_name, desc, cost, cat, prereqs, pos):
	var t = TechNodeResource.new()
	t.id = id
	t.display_name = d_name
	t.description = desc
	t.cost = cost
	t.category = cat
	var p_array: Array[String] = []
	for p in prereqs:
		p_array.append(p)
	t.prerequisites = p_array
	t.position = pos
	tech_data[id] = t
