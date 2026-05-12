extends Resource
class_name TechNodeResource

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var cost: int = 100
@export var category: String = "Industrial" # Industrial, Life Support, Energy
@export var prerequisites: Array[String] = []
@export var position: Vector2 = Vector2.ZERO # For visual tree positioning

# Bonus data (can be expanded)
@export var bonus_type: String = "" # e.g., "production_boost", "new_building", "consumption_reduction"
@export var bonus_value: float = 0.0
@export var target_id: String = "" # e.g., "Metals Extractor"
