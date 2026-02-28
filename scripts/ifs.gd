class_name IFS

const PRINT_ERRORS = false

const ACCURACY = 0.0000001

var systems = [] # array of contractions
var background_color = Color.WHITE
var uniform_coloring = false
var reusing_last_point = true
var centered_view = false

var axis_color_x = Color.GREEN
var axis_color_y = Color.BLUE
var axis_color_z = Color.RED

var camera_rotation = Vector3.ZERO
var camera_position = Vector3(0,0,1)

# random ifs

static func random_ifs(centered = (randf() <= 0.5), len_systems = randi() % 5 + randi() % 5 + 2):
	var ifs = IFS.new()
	# systems
	for _i in len_systems:
		ifs.systems.append(Contraction.random_contraction())
	# rest
	ifs.background_color = Color.from_hsv(randf(), randf(), randf())
	ifs.uniform_coloring = (randf() <= 0.5)
	ifs.reusing_last_point = true#(randf() <= 0.5)
	ifs.centered_view = centered
	return ifs

# functions changing an ifs

## break fractal into parts

func break_contraction(index=0) -> IFS:
	# parse input
	if index == -1: # break last one
		index = len(self.systems)-1
	# break things
	var ifs = IFS.new()
	ifs.background_color = self.background_color
	ifs.uniform_coloring = self.uniform_coloring
	ifs.reusing_last_point = self.reusing_last_point
	ifs.centered_view = self.centered_view
	for i in len(self.systems):
		if i == index:
			var new_systems = self.systems[i].apply(self.systems)
			ifs.systems.append_array(new_systems)
		else:
			ifs.systems.append(self.systems[i])
	return ifs

func break_ifs() -> IFS:
	var ifs = IFS.new()
	ifs.background_color = self.background_color
	ifs.uniform_coloring = self.uniform_coloring
	ifs.reusing_last_point = self.reusing_last_point
	ifs.centered_view = self.centered_view
	for system in self.systems:
		var new_systems = system.apply(self.systems)
		ifs.systems.append_array(new_systems)
	return ifs

static func center_with_preserving_image(ifs) -> IFS:
	for i in len(ifs.systems):
		ifs.systems[i].center_with_preserving_image()
	return ifs

# calculate fractal

func random_walk(pos, length=1, distribution=[]):
	if length > 0:
		if len(distribution) == 0:
			var fs = systems[ randi_range(0, len(systems)-1) ]
			var result = point.new()
			result.position = fs.apply(pos.position)
			if uniform_coloring:
				result.color = fs.color
			else:
				result.color = fs.mix(pos.color)
			return random_walk(
				result,
				length - 1,
				distribution
			)
		else:
			var random = randf_range(0, distribution[-1])
			for i in len(distribution):
				if random <= distribution[i]:
					var result = point.new()
					result.position = systems[ i ].apply(pos.position)
					if uniform_coloring:
						result.color = systems[i].color
					else:
						result.color = systems[i].mix(pos.color)
					return random_walk(
						result,
						length - 1,
						distribution
					)
	else:
		return pos

func calculate_fractal(start=point.new(), points=2000, this_delay=Global.DEFAULT_DELAY):
	var result = []
	# check if system is empty
	if len(systems) > 0:
		# delay
		## to begin in the attractor
		start = random_walk(start, this_delay)
		# real points
		result.append(start)
		var distribution = get_distribution()
		for n in range(1, points+1):
			result.append( random_walk(
				result[n-1],
				1,
				distribution
			) )
	return result

func get_distribution():
	var sum = 0.0
	var distribution = []
	for function in systems:
		sum += max(abs(function.matrix.determinant()), 0.001)
		distribution.append(sum)
	return distribution

# meta data and url storage

func to_meta_data() -> String:
	# 0. version
	var string = "v0"
	
	# 1. constants
	string += "|" + str(int(uniform_coloring)) + "," + str(int(reusing_last_point)) + "," + str(int(centered_view))
	
	# 2. colors
	string += "|" + background_color.to_html()
	string += "," + axis_color_x.to_html() + "," + axis_color_y.to_html() + "," + axis_color_z.to_html()
	
	# 3. camera
	string += "|" + str(camera_rotation.x) + "," + str(camera_rotation.y) + "," + str(camera_rotation.z)
	string += "," + str(camera_position.x) + "," + str(camera_position.y) + "," + str(camera_position.z)
	
	# 4. systems
	for contraction in systems:
		string += "|"
		string += str(contraction.translation.x) + "," + str(contraction.translation.y) + "," + str(contraction.translation.z) + ","
		string += str(contraction.matrix.x.x) + "," + str(contraction.matrix.x.y) + "," + str(contraction.matrix.x.z) + ","
		string += str(contraction.matrix.y.x) + "," + str(contraction.matrix.y.y) + "," + str(contraction.matrix.y.z) + ","
		string += str(contraction.matrix.z.x) + "," + str(contraction.matrix.z.y) + "," + str(contraction.matrix.z.z) + ","
		string += contraction.color.to_html(false)
	return string

static func from_meta_data(meta_data) -> IFS:
	if meta_data:
		# get version
		if meta_data[0] == "v":
			meta_data.trim_prefix("v")
			var version = int(meta_data.split("|", false)[0])
			return from_meta_data_version(meta_data, version)
		else:
			return from_meta_data_version(meta_data, 0)
	else:
		print("ERROR in ifs.gd: unhandable meta_data = ", meta_data)
		return IFS.new()

static func from_meta_data_version(meta_data, version) -> IFS:
	var ifs = IFS.new()
	match version:
		_: # uniform coloring / current version
			# split into units (separated by "|")
			## 0. version
			## 1. constants ( uniform_coloring, reusing_last_point, centered_view )
			## 2. colors ( background color, x axis light, y axis light & z axis light colors )
			## 3. camera ( rotation, zoom )
			## rest: systems
			
			var units = meta_data.split("|", false)
			
			if len(units) > 0:
				
				# 0. version
				units.remove_at(0)
				
				# 1. constants
				var subunits = units[0].split(",", false)
				units.remove_at(0)
				
				## uniform coloring
				ifs.uniform_coloring = (int(subunits[0]) == 1)
				
				## reusing_last_point
				ifs.reusing_last_point = (int(subunits[1]) == 1)
				
				## centered_view
				ifs.centered_view = (int(subunits[2]) == 1)
				
				# 2. colors
				
				subunits = units[0].split(",", false)
				units.remove_at(0)
				
				## background color
				ifs.background_color = Color.from_string(subunits[0], Color.WHITE)
				
				## axis colors
				ifs.axis_color_x = Color.from_string(subunits[1], Color.WHITE)
				ifs.axis_color_y = Color.from_string(subunits[2], Color.WHITE)
				ifs.axis_color_z = Color.from_string(subunits[3], Color.WHITE)
				
				# 3. camera
				
				subunits = units[0].split(",", false)
				units.remove_at(0)
				
				## rotation
				ifs.camera_rotation = Vector3(
					float(subunits[0]),
					float(subunits[1]),
					float(subunits[2])
				)
				## position
				ifs.camera_position = Vector3(
					float(subunits[3]),
					float(subunits[4]),
					float(subunits[5])
				)
				
				# Rest
				
				# functions
				var meta_ifs_systems = []
				for i in len(units):
					var entries = units[i].split(",", false)
					if len(entries) < 6: # someone messed up the url! >:(
						return
					var contraction = Contraction.new()
					contraction.translation = Vector3(
						float(entries[0]), float(entries[1]), float(entries[2])
					)
					contraction.matrix = Basis(
						Vector3(float(entries[3]), float(entries[4]), float(entries[5])),
						Vector3(float(entries[6]), float(entries[7]), float(entries[8])),
						Vector3(float(entries[9]), float(entries[10]), float(entries[11]))
					)
					
					contraction.color = Color.from_string(entries[12], Color.BLACK) # black is default
					meta_ifs_systems.append(contraction)
				ifs.systems = meta_ifs_systems
			
	return ifs
