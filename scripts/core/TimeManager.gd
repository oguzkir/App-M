extends Node

# Singleton: TimeManager
# Responsible for offline progress and time-based calculations

var last_save_time: int = 0

func _ready():
	last_save_time = load_time()
	calculate_offline_progress()

func save_time():
	# Use int() to avoid narrowing conversion warnings
	var current_time: int = int(Time.get_unix_time_from_system())
	var config = ConfigFile.new()
	config.set_value("time", "last_unix", current_time)
	config.save("user://time_data.cfg")

func load_time() -> int:
	var config = ConfigFile.new()
	var err = config.load("user://time_data.cfg")
	if err == OK:
		return int(config.get_value("time", "last_unix", int(Time.get_unix_time_from_system())))
	return int(Time.get_unix_time_from_system())

func calculate_offline_progress():
	var current_time: int = int(Time.get_unix_time_from_system())
	var elapsed_seconds = current_time - last_save_time
	
	if elapsed_seconds > 60: # Only trigger if away for more than a minute
		print("Welcome back! You were away for ", elapsed_seconds, " seconds.")
		# Trigger EconomyManager to calculate resource production
		if has_node("/root/EconomyManager"):
			get_node("/root/EconomyManager").process_offline_production(elapsed_seconds)

func get_current_unix_time() -> int:
	return int(Time.get_unix_time_from_system())
