extends Node2D
var scroll: float = 0.0
var rainbow: bool = false
var animation_time: float = 0.0

func _r(x: float, y: float, w: float, h: float, color: String) -> void:
	draw_rect(Rect2(roundf(x), roundf(y), ceilf(w), ceilf(h)), Color(color))

func _cloud(x: float, y: float, s: float) -> void:
	_r(x+12*s, y, 34*s, 9*s, "f4f4cf")
	_r(x, y+9*s, 67*s, 17*s, "f4f4cf")
	_r(x+8*s, y+26*s, 50*s, 5*s, "bfdaa2")
	_r(x+7*s, y+9*s, 14*s, 4*s, "fff9df")

func _mountain(x: float, y: float, w: float, h: float, color: String, light: String) -> void:
	var points = PackedVector2Array([Vector2(x,y+h),Vector2(x,y+h*.6),Vector2(x+w*.12,y+h*.6),Vector2(x+w*.12,y+h*.4),Vector2(x+w*.25,y+h*.4),Vector2(x+w*.25,y+h*.2),Vector2(x+w*.4,y+h*.2),Vector2(x+w*.4,y),Vector2(x+w*.57,y),Vector2(x+w*.57,y+h*.15),Vector2(x+w*.73,y+h*.15),Vector2(x+w*.73,y+h*.38),Vector2(x+w*.88,y+h*.38),Vector2(x+w*.88,y+h*.65),Vector2(x+w,y+h*.65),Vector2(x+w,y+h)])
	draw_colored_polygon(points, Color(color))
	_r(x+w*.4,y,w*.17,7,light)
	_r(x+w*.25,y+h*.2,w*.15,7,light)
	_r(x+w*.12,y+h*.4,w*.13,7,light)

func _tree(x: float, y: float, s: float) -> void:
	_r(x+11*s,y+28*s,6*s,26*s,"6b7950")
	_r(x+4*s,y+8*s,20*s,24*s,"70995b")
	_r(x,y+19*s,29*s,17*s,"70995b")
	_r(x+9*s,y,13*s,11*s,"70995b")
	_r(x+5*s,y+20*s,7*s,5*s,"8bb265")

func _mushroom(x: float, y: float, s: float) -> void:
	_r(x+20*s,y-5*s,14*s,51*s,"a1b776")
	_r(x+25*s,y-2*s,5*s,47*s,"b8c98b")
	var cap = PackedVector2Array([Vector2(x,y),Vector2(x,y-13*s),Vector2(x+7*s,y-13*s),Vector2(x+7*s,y-24*s),Vector2(x+16*s,y-24*s),Vector2(x+16*s,y-30*s),Vector2(x+38*s,y-30*s),Vector2(x+38*s,y-24*s),Vector2(x+47*s,y-24*s),Vector2(x+47*s,y-13*s),Vector2(x+54*s,y-13*s),Vector2(x+54*s,y)])
	draw_colored_polygon(cap,Color("d88758"))
	_r(x+s,y-4*s,52*s,6*s,"b76e48")
	_r(x+11*s,y-17*s,10*s,8*s,"efce8c")
	_r(x+32*s,y-24*s,8*s,6*s,"efce8c")
	_r(x+37*s,y-10*s,9*s,6*s,"efce8c")

func _draw() -> void:
	var g = RushConfig.GROUND
	_r(-20,-20,1000,660,"dfedb9")
	_r(0,0,960,140,"e5efc5")
	_r(0,140,960,90,"dceab2")
	_r(784,115,48,48,"f5e4a3")
	_r(790,109,36,6,"f5e4a3")
	_r(790,163,36,6,"f5e4a3")
	for i in range(-1,6):
		_cloud(i*260-fmod(scroll*.055,260)+25,158+posmod(i,2)*35,1.1)
	for i in range(-1,5):
		var x = i*330-fmod(scroll*.1,330)
		_mountain(x,255,360,160,"b1ce91","c0dba0")
		_mountain(x+160,285,230,131,"a3c588","bbd79a")
	for i in range(-1,5):
		var x = i*300-fmod(scroll*.22,300)
		_mountain(x,348,330,100,"8ab474","a5c783")
		_tree(x+155,349,.9)
		_r(x+90,399,9,13,"96be7e")
		_r(x+106,388,7,10,"96be7e")
	for i in range(-1,4):
		var x = i*570-fmod(scroll*.35,570)
		_mushroom(x+400,g-70,1.65)
		_mushroom(x+473,g-25,.8)
		_tree(x+175,g-54,1.15)
	_r(0,g-9,960,10,"749b50")
	_r(0,g-5,960,7,"bedb79")
	_r(0,g+2,960,12,"6f8e45")
	_r(0,g+14,960,600-g,"c1a475")
	_r(0,g+17,960,4,"d7bc87")
	for i in range(-1,23):
		var x = i*46-fmod(scroll,46)
		_r(x,g+1,5,8,"dcf397")
		_r(x+11,g+3,3,5,"87ad52")
		_r(x+25,g-3,4,7,"bedb79")
		_r(x+30,g+31,20,3,"b4976b")
		_r(x+7,g+51,11,3,"b4976b")
	for i in range(-1,7):
		var x = i*210-fmod(scroll*.8,210)
		_r(x+32,g-14,3,7,"527c3d")
		_r(x+29,g-12,3,3,"527c3d")
		_r(x+35,g-17,3,3,"edf0b9")
	if rainbow:
		draw_rect(Rect2(0,80,960,430),Color.from_hsv(fmod(animation_time*.2,1.0),.8,1.0,.09))
