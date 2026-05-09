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

# Runtime variables (not exported)
var current_stress: float = 0.0
var max_stress: float = 100.0
var is_retired: bool = false
var miracle_used: bool = false

func add_stress(amount: float):
	current_stress = clamp(current_stress + (amount * (1.0 / stress_resistance)), 0, max_stress)

func can_use_miracle() -> bool:
	return tier == Tier.T5 and not miracle_used
