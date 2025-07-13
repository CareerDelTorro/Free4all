extends Node2D

@onready var map_layer = get_node('tile_map_layer')
@onready var ui = get_node('ui')


func _ready():
	create_regen_reroll_button()
	create_fps_label()


func _process(delta):
	update_fps_label(delta)


func create_fps_label():
	var fps_label = Label.new()
	fps_label.name = 'fps_label'
	fps_label.text = "fps: 0"
	fps_label.position = Vector2(20, 10)
	
	ui.add_child(fps_label)


func update_fps_label(delta):
	var fps = Engine.get_frames_per_second()
	var fps_label = ui.get_node('fps_label')
	fps_label.text = 'fps: %d' % fps


func create_regen_reroll_button():
	var btn_map_reroll = Button.new()
	btn_map_reroll.text = 'Re-roll Map'
	btn_map_reroll.position = Vector2(20, 40)
	btn_map_reroll.pressed.connect(_on_regen_btn_map_reroll_pressed)
	
	ui.add_child(btn_map_reroll)


func _on_regen_btn_map_reroll_pressed():
	var new_seed = randi()
	map_layer._seed = new_seed
	map_layer.setup_noise()
	map_layer.generate_terrain()
