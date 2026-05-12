extends Resource
class_name SaveData

@export var app_version: String = "1.0.0"
@export var last_save_time: int = 0

# Economic Resources
@export var resources: Dictionary = {
	"isotopes": 500,
	"oxygen": 100,
	"energy": 100,
	"water": 100,
	"food": 100,
	"metal": 50,
	"concrete": 50,
	"moral": 100,
	"research": 0,
	"waste_rock": 0
}

# Player's Managers (Inventory)
@export var manager_inventory: Array[Dictionary] = [] # Array of serialized ManagerResource

# Map Data
@export var building_data: Array[Dictionary] = [] # Array of serialized building info
@export var cables: Dictionary = {}
@export var pipes: Dictionary = {}

# Research Data
@export var unlocked_techs: Array[String] = []

# Terraforming Data
@export var terraforming_stats: Dictionary = {
	"temperature": 0.0,
	"water": 0.0,
	"atmosphere": 0.0,
	"vegetation": 0.0
}

# Mission Data
@export var completed_milestones: Array[String] = []
@export var unlocked_breakthroughs: Array[String] = []
