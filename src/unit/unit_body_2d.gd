extends CharacterBody2D

# render stuff
@export var radius = 12
var unit_texture: Node2D
var line_to_target: Line2D

# idle wanter stuff
@export var wander_speed = 30.0
@export var wander_close_enough = 0.5
@export var wander_range = 100.0 
var wander_pause_range = Vector2i(2, 8)
var wander_pause_timer = wander_pick_pause_time()
var wander_target: Vector2

# drag and drop stuff
var is_being_dragged = false
var drag_offset = Vector2.ZERO


func _ready():
	unit_texture = get_node('unit_texture')
	line_to_target = get_node('line_to_target')
	# wait for the node to render so it actually has global_position that is not (0, 0)
	await get_tree().process_frame
	wander_reset_target_and_timer(true)
	#print(
		#'! ready',
		#' unit_pos: '			, global_position,		
		#' wander_target: '		, wander_target, 
		#' dist_to_target: '		, wander_get_distance_to_target(),
		#' wander_pause_timer: '	, wander_pause_timer,
	#)


func _input(event):
	drag_and_drop_with_mouse(event)


func _process(delta):
	if is_being_dragged:
		global_position = get_global_mouse_position() + drag_offset
	else:
		wander(delta)


func drag_and_drop_with_mouse(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = get_global_mouse_position()
				var distance = global_position.distance_to(mouse_pos)
				if distance <= radius:
					is_being_dragged = true
					drag_offset = global_position - mouse_pos
					unit_texture.queue_redraw()
					get_viewport().set_input_as_handled()	# handles overlapping units
			else:
				is_being_dragged = false
				unit_texture.queue_redraw()


func wander_pick_pause_time():
	return randf_range(wander_pause_range.x, wander_pause_range.y)


func wander_reset_target_and_timer(init=false):
	## todo: check if on map / ground / traversable tarrain
	var offset_vector = Vector2(
		randf_range(-wander_range, wander_range),
		randf_range(-wander_range, wander_range)
	)
	if init:
		offset_vector = Vector2(0, 0)
	wander_target = global_position + offset_vector
	
	wander_pause_timer = wander_pick_pause_time()
	
	#print(
		#'! new',
		#' global_position: '	, global_position,
		#' offset_vector: '		, offset_vector,
		#' wander_target: '		, wander_target,
		#' wander_pause_timer: '	, wander_pause_timer,
	#)


func wander_get_distance_to_target():
	return global_position.distance_to(wander_target)


func wander_draw_line_to_target():
	# draw line to target
	line_to_target.clear_points()
	line_to_target.add_point(Vector2.ZERO)
	line_to_target.add_point(to_local(wander_target))


var count = 0
func wander(delta):
	
	#count += 1
	#if count % 50 == 0:
		#print(
			#' unit_pos: '			, global_position,		
			#' wander_target: '		, wander_target, 
			#' dist_to_target: '		, wander_get_distance_to_target(),
			#' wander_pause_timer: '	, wander_pause_timer,
		#)
	
	if wander_get_distance_to_target() < wander_close_enough:
		if wander_pause_timer > 0:
			wander_pause_timer -= delta
		else:
			wander_reset_target_and_timer()
	
	if wander_get_distance_to_target() > wander_close_enough:
		wander_draw_line_to_target()
		var direction = (wander_target - global_position).normalized()
		global_position += direction * wander_speed * delta
