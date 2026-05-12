extends Node

# Singleton: TimeManager
# Responsible for offline progress and time-based calculations

signal time_validated(is_valid: bool)
signal hour_passed(hour: int)
signal sol_passed(sol: int)

const TIME_API_URL = "https://worldtimeapi.org/api/timezone/Etc/UTC"
const SECONDS_PER_SOL = 480.0 # 8 minutes per game day
var last_save_time: int = 0
var is_cheat_detected: bool = false

var current_sol: int = 1
var current_hour: float = 8.0 # Start at 8 AM
var time_scale: float = 1.0

@onready var http_request = HTTPRequest.new()

func _ready():
	add_child(http_request)
	http_request.request_completed.connect(_on_time_received)
	
	last_save_time = load_time()
	validate_time_remotely()

func _process(delta):
	if is_cheat_detected: return
	
	# Update Game Time
	var hour_delta = (24.0 / SECONDS_PER_SOL) * delta * time_scale
	var prev_hour = int(current_hour)
	current_hour += hour_delta
	
	if int(current_hour) != prev_hour:
		hour_passed.emit(int(current_hour) % 24)
		
	if current_hour >= 24.0:
		current_hour = 0.0
		current_sol += 1
		sol_passed.emit(current_sol)
		print("TimeManager: Sol ", current_sol, " started.")

func get_solar_intensity() -> float:
	# Peak at 12:00, zero between 20:00 and 06:00
	if current_hour < 6.0 or current_hour > 20.0:
		return 0.0
	
	# Simple sine curve for daytime intensity
	var day_progress = (current_hour - 6.0) / 14.0 # 0.0 to 1.0
	return sin(day_progress * PI)

func validate_time_remotely():
	print("TimeManager: Validating server time...")
	var err = http_request.request(TIME_API_URL)
	if err != OK:
		print("TimeManager: Network error, falling back to offline validation.")
		_perform_offline_validation()

func _on_time_received(result, response_code, _headers, body):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json and json.has("unixtime"):
			var server_time = int(json["unixtime"])
			var local_time = int(Time.get_unix_time_from_system())
			
			if abs(local_time - server_time) > 300: # 5 min drift
				_trigger_cheat_detected()
				return
			
			print("TimeManager: Time validated successfully.")
			calculate_offline_progress()
			time_validated.emit(true)
			return
	
	_perform_offline_validation()

func _perform_offline_validation():
	var local_time = int(Time.get_unix_time_from_system())
	if local_time < last_save_time:
		_trigger_cheat_detected()
	else:
		calculate_offline_progress()
		time_validated.emit(true)

func _trigger_cheat_detected():
	is_cheat_detected = true
	print("!!! ANTI-CHEAT: Time manipulation detected !!!")
	time_validated.emit(false)
	# EconomyManager will check this flag to stop production

func save_time():
	if is_cheat_detected: return
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
	if is_cheat_detected: return
	var current_time: int = int(Time.get_unix_time_from_system())
	var elapsed_seconds = current_time - last_save_time
	
	if elapsed_seconds > 60:
		print("EconomyManager: Offline progress applied for ", elapsed_seconds, " seconds.")
		if has_node("/root/EconomyManager"):
			get_node("/root/EconomyManager").process_offline_production(elapsed_seconds)

func get_current_unix_time() -> int:
	return int(Time.get_unix_time_from_system())
