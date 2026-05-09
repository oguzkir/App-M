extends Resource
class_name BuildingResource

@export var building_name: String = "Building"
@export var description: String = ""
@export var base_cost: int = 100
@export var construction_time: float = 10.0 # In seconds

@export_group("Production")
@export var production_type: String = "credits"
@export var production_amount: float = 1.0 # Base production per tick

@export_group("Visuals")
@export var icon: Texture2D
@export var sprite: Texture2D
