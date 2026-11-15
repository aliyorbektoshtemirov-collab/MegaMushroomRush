class_name MechaBoss
extends Node2D
signal warning(message: String)
signal shoot(high: bool)
signal defeated
var state: String = "off"
var timer: float = 0.0
var remaining: float = 0.0
var cooldown: float = 0.0
var windup: float = 0.0
var high_shot: bool = false
var shot_number: int = 0
var animation_time: float = 0.0

func reset_boss() -> void:
	state = "off"
	position = Vector2(-160, RushConfig.GROUND-116)
	remaining = 0.0
	windup = 0.0
	queue_redraw()

func trigger() -> void:
	reset_boss()
	state = "warning"
	timer = 2.3
	remaining = RushConfig.BOSS_DURATION
	shot_number = 0
	cooldown = 0.45
	warning.emit("! MECHA BOSS YAQINLASHMOQDA!")

func simulate(delta: float) -> void:
	animation_time += delta
	match state:
		"warning":
			timer -= delta
			if timer <= 0:
				state = "enter"
				timer = 1.5
				warning.emit("12 SONIYA BARDOSH BER!")
		"enter":
			position.x += 95.0*delta
			timer -= delta
			if position.x >= -22.0 or timer <= 0:
				position.x = -22.0
				state = "attack"
		"attack":
			remaining -= delta
			if windup > 0:
				windup -= delta
				if windup <= 0:
					shoot.emit(high_shot)
					cooldown = 1.0
			else:
				cooldown -= delta
				if cooldown <= 0 and remaining > 1.2:
					shot_number += 1
					high_shot = shot_number % 2 == 0
					windup = 1.0
					warning.emit("BALAND OLOV - EGIL!" if high_shot else "PAST OLOV - SAKRA!")
			if remaining <= 0:
				state = "retreat"
				windup = 0.0
				defeated.emit()
		"retreat":
			position.x -= 120.0*delta
			if position.x < -180:
				state = "off"
	queue_redraw()

func _r(x: float,y: float,w: float,h: float,hex: String) -> void:
	draw_rect(Rect2(x,y,w,h),Color(hex))

func _draw() -> void:
	if state in ["off","warning"]:
		return
	_r(15,43,60,57,"334e49")
	_r(6,59,18,28,"516d5c")
	_r(0,72,16,12,"516d5c")
	_r(20,36,44,63,"668370")
	_r(34,45,27,49,"9caa7b")
	for y in [53,66,79]:
		_r(40,y,19,4,"657e60")
	_r(21,6,62,44,"344e47")
	_r(28,0,43,8,"47685a")
	_r(31,8,50,29,"688b74")
	_r(72,22,25,26,"415f51")
	_r(69,37,37,15,"263f39")
	_r(77,34,27,5,"f5dfb0")
	_r(78,39,5,6,"f5dfb0")
	_r(92,39,5,6,"f5dfb0")
	_r(47,14,22,12,"f49751" if windup>0 else "f4c76a")
	_r(58,17,7,8,"633c2d")
	_r(23,90,15,20,"456652")
	_r(56,90,15,20,"456652")
	var leg = 3 if sin(animation_time*15)>0 else 0
	_r(16,107-leg,26,9+leg,"2b443b")
	_r(49,104+leg,28,12-leg,"2b443b")
	_r(63,58,28,11,"3f5f50")
	_r(82,62,10,12,"79916b")
	for i in range(4):
		_r(15-i*3,19+i*16,9,9,"e1bd73")
		_r(11-i*3,22+i*16,6,5,"b19158")
	_r(28,53,7,7,"afbd8b")
	_r(27,76,7,7,"afbd8b")
	if windup>0:
		_r(96,33,12,10,"f4a353")
		_r(100,35,12,6,"ffe9a0")
		var lane = 61.0 if high_shot else 94.0
		draw_rect(Rect2(108,lane,960-position.x-108,20),Color(0.95,0.4,0.2,0.12))
	if state == "attack":
		_r(18,-13,78,5,"314737")
		_r(18,-13,78*remaining/RushConfig.BOSS_DURATION,5,"eeb76d")
