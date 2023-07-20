extends Node

func min_axis(v1: Vector2, v2: Vector2):
	var min_x = minf(v1.x, v2.x)
	var min_y = minf(v1.y, v2.y)
	return { "x": min_x, "y": min_y }
	
func max_axis(v1: Vector2, v2: Vector2):
	var max_x = maxf(v1.x, v2.x)
	var max_y = maxf(v1.y, v2.y)
	return { "x": max_x, "y": max_y }
