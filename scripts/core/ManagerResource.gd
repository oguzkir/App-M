extends Resource
class_name ManagerResource

enum Tier { T1, T2, T3, T4, T5 }
enum Sector { INDUSTRIAL, CIVIL, LOGISTICS }

@export var manager_name: String = "Manager"
@export var portrait: Texture2D
@export var tier: Tier = Tier.T1
@export var sector: Sector = Sector.INDUSTRIAL

@export_group("Stats")
@export var production_boost: float = 1.1 # 10% boost
@export var stress_resistance: float = 1.0 # Multiplier for stress gain
@export var miracle_name: String = ""
@export var miracle_description: String = ""

@export_group("Legacy")
@export var legacy_type: String = "production" # production, energy_saving, etc.
@export var legacy_bonus_value: float = 0.05 # 5% permanent bonus

# Runtime variables
var current_stress: float = 0.0
var max_stress: float = 100.0
var is_retired: bool = false
var miracle_used: bool = false
var experience: float = 0.0
var experience_to_next_tier: float = 3600.0 # T1->T2: 1 Hour (3600s)

func add_stress(amount: float):
	current_stress = clamp(current_stress + (amount * (1.0 / stress_resistance)), 0, max_stress)
	if current_stress >= max_stress:
		retire(false) # Forced retirement due to stress

func add_experience(amount: float):
	if tier < Tier.T5:
		experience += amount
		if experience >= experience_to_next_tier:
			tier_up()

func tier_up():
	if tier < Tier.T5:
		tier = (tier + 1) as Tier
		experience = 0
		# Progression Wall Scaling: 1h, 6h, 48h, 14d
		match tier:
			Tier.T2: experience_to_next_tier = 21600.0 # 6 Hours
			Tier.T3: experience_to_next_tier = 172800.0 # 48 Hours
			Tier.T4: experience_to_next_tier = 1209600.0 # 14 Days
		
		production_boost += 0.05
		print(manager_name, " leveled up to T", tier + 1)

func retire(_with_miracle: bool = false):
	is_retired = true
	# Legacy logic will be handled by the building/EconomyManager
	print(manager_name, " has retired. Legacy: ", legacy_type, " +", legacy_bonus_value)

func can_use_miracle() -> bool:
	return tier == Tier.T5 and not miracle_used

func to_dict() -> Dictionary:
	return {
		"name": manager_name,
		"tier": int(tier),
		"sector": int(sector),
		"prod_boost": production_boost,
		"stress_res": stress_resistance,
		"miracle_name": miracle_name,
		"miracle_desc": miracle_description,
		"legacy_type": legacy_type,
		"legacy_val": legacy_bonus_value,
		"current_stress": current_stress,
		"experience": experience,
		"exp_to_next": experience_to_next_tier,
		"is_retired": is_retired,
		"miracle_used": miracle_used
	}

static func from_dict(dict: Dictionary) -> ManagerResource:
	var m = ManagerResource.new()
	m.manager_name = dict.get("name", "Manager")
	m.tier = dict.get("tier", 0) as Tier
	m.sector = dict.get("sector", 0) as Sector
	m.production_boost = dict.get("prod_boost", 1.1)
	m.stress_resistance = dict.get("stress_res", 1.0)
	m.miracle_name = dict.get("miracle_name", "")
	m.miracle_description = dict.get("miracle_desc", "")
	m.legacy_type = dict.get("legacy_type", "production")
	m.legacy_bonus_value = dict.get("legacy_val", 0.05)
	m.current_stress = dict.get("current_stress", 0.0)
	m.experience = dict.get("experience", 0.0)
	m.experience_to_next_tier = dict.get("exp_to_next", 3600.0)
	m.is_retired = dict.get("is_retired", false)
	m.miracle_used = dict.get("miracle_used", false)
	return m
