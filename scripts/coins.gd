extends Node2D
var coins: Array[Dictionary] = []
var animation_time: float = 0.0

func _draw() -> void:
	for coin in coins:
		var point: Vector2 = coin.point
		if point.x>1000 or point.x< -30:
			continue
		var width = 8.0+absf(cos(animation_time*5.0+coin.phase))*7.0
		draw_rect(Rect2(point+Vector2((15-width)/2,0),Vector2(width,18)),Color("b68b2e"))
		draw_rect(Rect2(point+Vector2((15-width)/2,0),Vector2(width-2,15)),Color("f2c94f"))
		if width>10:
			draw_rect(Rect2(point+Vector2(6,3),Vector2(3,9)),Color("ffe98c"))
