class_name IFS

const PRINT_ERRORS = false

const ACCURACY = 0.0000001

var systems = [] # array of contractions
var background_color = Color.WHITE
var delay = Global.DEFAULT_DELAY
var uniform_coloring = false
var reusing_last_point = false
var centered_view = false

# random ifs

static func random_ifs(centered = (randf() <= 0.5), len_systems = randi() % 5 + randi() % 5 + 1):
	var ifs = IFS.new()
	# systems
	for _i in len_systems:
		ifs.systems.append(Contraction.random_contraction())
	# rest
	ifs.background_color = Color.from_hsv(randf(), randf(), randf())
	if len(ifs.systems) == 1:
		ifs.delay = randi()%10
	else:
		ifs.delay = randi()%101
	ifs.uniform_coloring = (randf() <= 0.5)
	ifs.reusing_last_point = (randf() <= 0.5)
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
	ifs.delay = self.delay
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
	ifs.delay = self.delay
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

func calculate_fractal(start=point.new(), points=2000, this_delay=delay):
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

static func from_meta_data(meta_data_string) -> IFS:
	print("load ifs from meta data string:\n", meta_data_string, "\n")
	return IFS.new()
