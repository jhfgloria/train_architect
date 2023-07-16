extends StaticBody2D

var base_speed = 60
var pick_up = false
var speed = base_speed
	
func _physics_process(delta):
	var velocity = Vector2(speed, 0)
	
	if pick_up:
		move_toward(speed, 0, -1)
	else:
		move_and_collide(velocity * delta)


func _on_pickup_position_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	pick_up = true
	$Timer.start()


func _on_timer_timeout():
	pick_up = false
	speed = base_speed * 2


func _on_exit_position_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	self.queue_free()
