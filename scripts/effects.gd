extends Node2D
var particles: Array[Dictionary] = []
var floaters: Array[Dictionary] = []
var trails: Array[Dictionary] = []
var animation_time: float = 0.0
var random = RandomNumberGenerator.new()

func clear_effects() -> void:
	particles.clear()
	floaters.clear()
	trails.clear()
	queue_redraw()

func burst(point: Vector2, color: Color, count: int = 12) -> void:
	for i in range(count):
		if particles.size()>=160:
			break
		particles.append({"point":point,"velocity":Vector2(random.randf_range(-180,180),random.randf_range(-250,20)),"life":random.randf_range(.3,.7),"color":color,"size":random.randf_range(2,6)})

func text(message: String, point: Vector2, color: Color = Color("203f2c")) -> void:
	if floaters.size()>16:
		floaters.pop_front()
	floaters.append({"text":message,"point":point,"life":0.9,"color":color})

func trail(point: Vector2, height: float) -> void:
	if trails.size()>16:
		trails.pop_front()
	trails.append({"point":point,"height":height,"life":0.3,"hue":fmod(animation_time*.3+trails.size()*.05,1.0)})

func simulate(delta: float, speed: float) -> void:
	animation_time += delta
	for p in particles:
		p.life -= delta
		p.point += p.velocity*delta
		p.velocity.y += 850*delta
	particles = particles.filter(func(p): return p.life>0)
	for f in floaters:
		f.life -= delta
		f.point.y -= 40*delta
	floaters = floaters.filter(func(f): return f.life>0)
	for t in trails:
		t.life -= delta
		t.point.x -= speed*delta*.6
	trails = trails.filter(func(t): return t.life>0)
	queue_redraw()

func _draw() -> void:
	for t in trails:
		draw_rect(Rect2(t.point-Vector2(0,t.height),Vector2(32,t.height)),Color.from_hsv(t.hue,.75,1,t.life*.75))
	for p in particles:
		var c = p.color as Color
		c.a = minf(1.0,p.life*3)
		draw_rect(Rect2(p.point,Vector2.ONE*p.size),c)
	for f in floaters:
		var c = f.color as Color
		c.a = minf(1.0,f.life*3)
		draw_string(ThemeDB.fallback_font,f.point,f.text,HORIZONTAL_ALIGNMENT_CENTER,-1,16,c)
