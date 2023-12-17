class_name Procedural_Environment
extends Environemnt

@onready var tile_map : TileMap = $TileMap
@onready var decorations_root : Node2D = $Decorations
@onready var decoration_grass : PackedScene = preload("res://Scenes/Levels/shrub_1.tscn")
@export var map_dimensions : Vector2i
@export var world_bounds_min: Vector2
@export var world_bounds_max: Vector2

var player_tile : Vector2i = Vector2i.MAX
var noise : FastNoiseLite = FastNoiseLite.new()
var bounds_min : Vector2i
var bounds_max : Vector2i
var SPAWN_DECO_THRESHOLD : int = 60
var NOISE_SCALE : int = 100
var THRESHOLD_RATIO : float = 1.0 / float(SPAWN_DECO_THRESHOLD)

func _ready() -> void:
	tile_map.clear()
	noise.seed = randi()
	noise.frequency = 1
	noise.fractal_gain = 0
	print(THRESHOLD_RATIO)
	
func init(bounds: Vector2i) -> void:
	map_dimensions = bounds
	
func _process(_delta) -> void:
	var player_tile_position = tile_map.local_to_map(player.position)
	if(player_tile_position != player_tile):
		player_tile = player_tile_position
		update_tiles_around_player()
		
func update_tiles_around_player() -> void:
	bounds_min = Vector2i(player_tile.x - map_dimensions.x * 0.5, player_tile.y - map_dimensions.y * 0.5)
	bounds_max = Vector2i(player_tile.x + map_dimensions.x * 0.5, player_tile.y + map_dimensions.y * 0.5)
	world_bounds_min = tile_map.map_to_local(bounds_min)
	world_bounds_max = tile_map.map_to_local(bounds_max)
	
	var used_cells = tile_map.get_used_cells(0)
	
	for cell: Vector2i in used_cells:
		if(is_out_of_map_bounds(cell)):
			tile_map.erase_cell(0, cell)
			
	var decorations = decorations_root.get_children()
	for node in decorations:
		var map_node_poistion = tile_map.local_to_map((node as Node2D).position)
		if(is_out_of_map_bounds(map_node_poistion)):
			node.queue_free()
	
	for x in range(bounds_min.x, bounds_max.x):
		for y in range(bounds_min.y, bounds_max.y):
			var tile_position = Vector2i(x, y)
			if(tile_map.get_cell_tile_data(0, tile_position) != null):
				continue
			tile_map.set_cell(0, tile_position, 0, Vector2i(9,13))
			var noise_test = noise.get_noise_2d(x,y)
			var plant_test : int = noise_test * NOISE_SCALE
			plant_test = abs(plant_test)
			if(plant_test > SPAWN_DECO_THRESHOLD):
				spawn_deco_over_tile(tile_position, plant_test)

func spawn_deco_over_tile(map_position : Vector2i, noise: int) -> void:
	var local_position = tile_map.map_to_local(map_position)
	var deco = decoration_grass.instantiate() as AnimatedSprite2D
	decorations_root.add_child(deco)
	deco.position = local_position
	var animations = deco.sprite_frames.get_animation_names()
	var animation_count = animations.size()
	var animation_id = round(animation_count * THRESHOLD_RATIO * (noise - SPAWN_DECO_THRESHOLD))
	var animation_name = animations[animation_id]
	deco.play(animation_name)
		
func is_out_of_map_bounds(cell : Vector2i) -> bool:
	return cell.x < bounds_min.x || cell.y < bounds_min.y || cell.x >= bounds_max.x || cell.y >= bounds_max.y
