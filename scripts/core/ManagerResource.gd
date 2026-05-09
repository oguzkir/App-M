extends Resource
class_name ManagerResource

enum Tier { T1, T2, T3, T4, T5 }
enum Sector { INDUSTRIAL, CIVIL, LOGISTICS }

@export var manager_name: String = "Manager"
@export var tier: Tier = Tier.T1
@export var sector: Sector = Sector.INDUSTRIAL

@export_group("Stats")
@export var efficiency_bonus: float = 0.1 # 10% bonus
@export var miracle_desc: String = ""

@export_group("Legacy")
@export var legacy_bonus: float = 0.05 # Permanent bonus after retirement

@export_group("Visuals")
@export var portrait: Texture2D
