extends TileMapLayer

@export var _seed: int = 322
@export var map_w: int = 100
@export var map_h: int = 100
@export var tile_size: int = 16
@export var noise_freq: float = 0.1

var noise: FastNoiseLite

var terrain_tiles: Array[Dictionary] = [
	{'coord': Vector2i(0, 0), 'weight': 0.4},		# grass
	{'coord': Vector2i(0, 4), 'weight': 0.1},		# sand
	{'coord': Vector2i(0, 2), 'weight': 0.1},		# water
	{'coord': Vector2i(0, 1), 'weight': 0.1},		# forest
	{'coord': Vector2i(0, 3), 'weight': 0.1},		# mountain
]
var source_id = 0

func _ready():
	setup_noise()
	generate_terrain()

func setup_noise():
	noise = FastNoiseLite.new()
	noise.seed = _seed
	noise.frequency = noise_freq
	noise.noise_type = FastNoiseLite.TYPE_PERLIN

func generate_terrain():
	clear()
	
	for x in range(map_w):
		for y in range(map_h):
			var noise_value = noise.get_noise_2d(x, y)
			var tile = get_tile_from_noise_value(noise_value)
			var sprite_coords = terrain_tiles[tile].coord
			set_cell(Vector2i(x, y), source_id, sprite_coords)

func get_tile_from_noise_value(noise_value: float):
	var norm = (noise_value + 1.0) / 2.0
	
	var c_weight = 0.0
	var ranges = []
	for tt in terrain_tiles:
		c_weight += tt.weight
		ranges.append(c_weight)
	
	for i in range(ranges.size()):
		if norm <= (ranges[i] / c_weight):
			return i
