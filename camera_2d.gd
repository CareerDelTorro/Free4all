extends Camera2D

@export var tilemap_layer: TileMapLayer
@export var move_speed: float = 1
@export var camera_padding = 100

var drag_start_mouse_pos = Vector2i.ZERO
var drag_start_camera_pos = Vector2i.ZERO
var is_dragging = false

func _ready():
	#RenderingServer.set_default_clear_color(Color.GRAY)
	if tilemap_layer:
		limit_left = 0 - camera_padding
		limit_top = 0 - camera_padding
		limit_right = tilemap_layer.map_w * tilemap_layer.tile_size + camera_padding
		limit_bottom = tilemap_layer.map_h * tilemap_layer.tile_size + camera_padding
		limit_smoothed = true
	pass
	
func _process(delta):
	handle_zoom()
	handle_arrow_move(delta)
	click_and_drag()
	
func handle_zoom():
	if Input.is_action_just_pressed('camera_zoom_in'):
		zoom *= 1.1
	if Input.is_action_just_pressed('camera_zoom_out'):
		zoom *= 0.9
	
func get_zoom_comp():
	return 1 / zoom.x
	
func handle_arrow_move(delta):
	var move_speed = move_speed * delta * 500 * get_zoom_comp()
	if Input.is_action_pressed('camera_move_up'):
		position.y -= move_speed
	if Input.is_action_pressed('camera_move_down'):
		position.y += move_speed
	if Input.is_action_pressed('camera_move_left'):
		position.x -= move_speed
	if Input.is_action_pressed('camera_move_right'):
		position.x += move_speed

func click_and_drag():
	if !is_dragging and Input.is_action_just_pressed('camera_pan'):
		drag_start_mouse_pos = get_viewport().get_mouse_position()
		drag_start_camera_pos = position
		is_dragging = true
		
	if is_dragging and Input.is_action_just_released('camera_pan'):
		is_dragging = false
		
	if is_dragging:
		var move_vector = get_viewport().get_mouse_position() - drag_start_mouse_pos
		position = drag_start_camera_pos - move_vector * get_zoom_comp()
