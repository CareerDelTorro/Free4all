extends Node2D


func _draw():
	var char_body = get_parent()
	var radius = char_body.radius
	if char_body.is_being_dragged:
		draw_circle(Vector2.ZERO, radius * 1.2, Color(1, 0, 0, 0.4))
	else:
		draw_circle(Vector2.ZERO, radius, Color(1, 0, 0, 0.6)) 
