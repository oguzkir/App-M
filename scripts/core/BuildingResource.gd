extends Resource
class_name BuildingResource

enum Sector { INDUSTRIAL, LIFE_SUPPORT, SCIENCE, LOGISTICS }

@export var building_name: String = "Building"
@export var description: String = ""
@export var sector: Sector = Sector.INDUSTRIAL
@export var construction_costs: Dictionary = {"metal": 50, "concrete": 0}
@export var maintenance_metal_cost: int = 10 # Cost to repair 10% condition
@export var construction_time: float = 10.0 # In seconds
@export_range(1, 5) var priority_level: int = 3 # 1 is most critical (Oxygen), 5 is least (Research)

@export_group("Production / Consumption")
@export var production_type: String = "energy"
@export var production_amount: float = 1.0
@export var waste_production: float = 0.0 # Amount of Waste Rock generated
@export var upgrade_cost_multiplier: float = 2.0
@export var required_tech_id: String = "" # Empty means available from start

@export var input_resources: Dictionary = {} # e.g., {"energy": 2.0, "water": 1.0}

@export_group("Footprint")
@export var footprint: Vector2i = Vector2i(1, 1) # Size in tiles (x, y)

@export_group("Visuals")
@export var icon: Texture2D
@export var sprite: Texture2D
