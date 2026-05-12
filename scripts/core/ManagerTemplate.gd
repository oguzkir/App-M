extends Resource
class_name ManagerTemplate

@export var name: String = "Candidate"
@export var portrait: Texture2D
@export var character_sector: int = 0 # Matches ManagerResource.Sector
@export var rarity_tier: int = 0 # Matches ManagerResource.Tier

@export_group("Base Stats")
@export var base_production_boost: float = 1.05
@export var base_stress_resistance: float = 1.0

@export_group("Legacy Potential")
@export var legacy_type: String = "production"
@export var legacy_value: float = 0.05
