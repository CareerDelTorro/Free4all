extends TileMapLayer

@export var _seed: int = 322
@export var map_w: int = 250
@export var map_h: int = 250
@export var tile_size: int = 16
@export var noise_freq: float = 0.02

@export var is_island = true
@export var island_water_margin = 0.8
@export var island_sharpness = 4.0
@export var island_uplift = 0.0
@export var island_height_scale = 1.5

var noise: FastNoiseLite

var terrain_tiles_count = 5
var terrain_tiles: Array[Dictionary] = [
	{'row': 0, 'height': 0.95},		# mountain_snow
	{'row': 1, 'height': 0.85},		# mountain_rock
	{'row': 2, 'height': 0.50},		# forest
	{'row': 3, 'height': 0.35},		# grass
	{'row': 4, 'height': 0.25},		# sand
	{'row': 5, 'height': 0.15},		# shallow_water
	{'row': 6, 'height': 0.00},		# deep_water
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
			
			var fx = float(x)
			var fy = float(y)
			
			var noise_value = noise.get_noise_2d(fx, fy)
			var noise_norm = (noise_value + 1.0) / 2.0
			
			var noise_final = noise_norm
			
			if is_island:
				# center
				var cx = map_w / 2.0
				var cy = map_h / 2.0
				var cr = sqrt(cx*cx + cy*cy) * island_water_margin
				
				# distance from center
				var dx = fx - cx
				var dy = fy - cy
				var dist = sqrt(dx*dx + dy*dy) / cr
				
				# calculate fall
				var fall = 0
				fall = pow(dist, island_sharpness)
				noise_final = (noise_norm - fall + island_uplift) * island_height_scale
				noise_final = clamp(noise_final, 0.0, 1.0)
			
			var tile = get_tile_from_noise_value(noise_final)
			set_cell(Vector2i(x, y), source_id, tile)


func get_tile_from_noise_value(noise_value: float):
	for tile in terrain_tiles:
		if noise_value >= tile.height:
			return Vector2i(tile.row, randi_range(0, terrain_tiles_count - 1))
