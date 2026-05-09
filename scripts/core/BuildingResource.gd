extends Resource
class_name BuildingResource

@export var building_name: String = "Building"
@export var description: String = ""
@export var base_cost: int = 100
@export var construction_time: float = 10.0 # In seconds
@export_range(1, 5) var priority_level: int = 3 # 1 is most critical (Oxygen), 5 is least (Research)

@export_group("Production / Consumption")
@export var production_type: String = "credits"
@export var production_amount: float = 1.0

@export var input_resources: Dictionary = {} # e.g., {"energy": 2.0, "water": 1.0}

@export_group("Visuals")
@export var icon: Texture2D
@export var sprite: Texture2D
