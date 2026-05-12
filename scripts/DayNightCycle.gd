extends CanvasModulate

# Handles visual day/night transition
# Blue/Dark for night, Orange/Bright for Mars day

var night_color = Color("#1a1a3a") # Deep Space Blue
var day_color = Color("#ffffff")   # Normal
var sunset_color = Color("#ff8c42") # Mars Sunset Orange

func _process(_delta):
	var solar_intensity = TimeManager.get_solar_intensity()
	var hour = TimeManager.current_hour
	
	if hour >= 6.0 and hour <= 18.0:
		# Daytime
		color = night_color.lerp(day_color, solar_intensity)
		# Add sunset tint
		if hour > 16.0:
			var sunset_progress = (hour - 16.0) / 2.0
			color = color.lerp(sunset_color, sunset_progress)
	else:
		# Nighttime
		color = night_color
