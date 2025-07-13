extends Node2D

@export var unit_scene: PackedScene
@export var camera: Camera2D
@export var tilemap_layer: TileMapLayer

var entities: Array[Node2D] = []


func _ready():
	pass


func _input(event):
	if Input.is_action_just_pressed('spawn_simple_entity'):
		spawn_unit_at_cursor()


func spawn_unit_at_cursor():	
	var mouse_pos = get_global_mouse_position()
	var unit = unit_scene.instantiate()
	add_child(unit)
	unit.global_position = mouse_pos
