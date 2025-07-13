extends Camera2D

@onready var tile_map_layer = get_parent().get_node('tile_map_layer')
@export var move_speed: float = 500
@export var camera_padding = 100
@export var edge_scroll_allow = false
@export var edge_scroll_margin = 10
@export var zoom_min = 0.005
@export var zoom_max = 5

var drag_start_mouse_pos = Vector2i.ZERO
var drag_start_camera_pos = Vector2i.ZERO
var is_dragging = false


func _ready():
	RenderingServer.set_default_clear_color(Color.DARK_GRAY)
	position = Vector2(
		tile_map_layer.map_w * tile_map_layer.tile_size / 2,
		tile_map_layer.map_h * tile_map_layer.tile_size / 2
	)
	
	# stuff for max zoomout based on map size
	var map_size = Vector2(
		tile_map_layer.map_w * tile_map_layer.tile_size + 2 * camera_padding,
		tile_map_layer.map_h * tile_map_layer.tile_size + 2 * camera_padding
	)
	var viewport_size = get_viewport().get_visible_rect().size
	zoom_min = 1 / max(map_size.x / viewport_size.x, map_size.y / viewport_size.y)


func _process(delta):
	handle_zoom()
	handle_arrow_move(delta)
	handle_click_and_drag()
	if edge_scroll_allow:
		handle_edge_scroll(delta)
	handle_clamp_camera_to_bounds()


func handle_zoom():
	var zoom_new = zoom
	if Input.is_action_just_pressed('camera_zoom_in'):
		zoom_new *= 1.1
	if Input.is_action_just_pressed('camera_zoom_out'):
		zoom_new *= 0.9
	
	zoom_new.x = clamp(zoom_new.x, zoom_min, zoom_max)
	zoom_new.y = clamp(zoom_new.y, zoom_min, zoom_max)
	
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_center = get_viewport().get_visible_rect().size / 2
	var mouse_offset = mouse_pos - viewport_center
	
	var world_pos_before = position + mouse_offset / zoom.x
	
	zoom = zoom_new
	
	var world_pos_after = position + mouse_offset / zoom.x
	position += world_pos_before - world_pos_after


func get_zoom_comp():
	return 1 / zoom.x


func handle_arrow_move(delta):
	var _move_speed = move_speed * delta * get_zoom_comp()
	if Input.is_action_pressed('camera_move_up'):
		position.y -= _move_speed
	if Input.is_action_pressed('camera_move_down'):
		position.y += _move_speed
	if Input.is_action_pressed('camera_move_left'):
		position.x -= _move_speed
	if Input.is_action_pressed('camera_move_right'):
		position.x += _move_speed


func handle_click_and_drag():
	if !is_dragging and Input.is_action_just_pressed('camera_pan'):
		drag_start_mouse_pos = get_viewport().get_mouse_position()
		drag_start_camera_pos = position
		is_dragging = true
		
	if is_dragging and Input.is_action_just_released('camera_pan'):
		is_dragging = false
		
	if is_dragging:
		var move_vector = get_viewport().get_mouse_position() - drag_start_mouse_pos
		position = drag_start_camera_pos - move_vector * get_zoom_comp()


func handle_edge_scroll(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var _move_speed = move_speed * delta * get_zoom_comp()
	
	if mouse_pos.x < edge_scroll_margin:
		position.x -= _move_speed
	elif mouse_pos.x > viewport_size.x - edge_scroll_margin:
		position.x += _move_speed
		
	if mouse_pos.y < edge_scroll_margin:
		position.y -= _move_speed
	elif mouse_pos.y > viewport_size.y - edge_scroll_margin:
		position.y += _move_speed


func handle_clamp_camera_to_bounds():
		
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_half_size = viewport_size / (2.0 * zoom)
	
	# Calculate map bounds
	var map_bounds = Rect2(
		Vector2(
			-camera_padding, 
			-camera_padding
		),
		Vector2(
			tile_map_layer.map_w * tile_map_layer.tile_size + 2 * camera_padding,
			tile_map_layer.map_h * tile_map_layer.tile_size + 2 * camera_padding
		)
	)
	
	position.x = clamp(
		position.x, 
		map_bounds.position.x + camera_half_size.x,
		map_bounds.position.x + map_bounds.size.x - camera_half_size.x
	)
	position.y = clamp(
		position.y, 
		map_bounds.position.y + camera_half_size.y,
		map_bounds.position.y + map_bounds.size.y - camera_half_size.y
	)
