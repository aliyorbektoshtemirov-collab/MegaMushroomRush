extends Node2D
## Scene owner: fixed-step gameplay, spawning, contacts, menus and persistence.
const EnemyScene = preload("res://scenes/enemy.tscn")
var mode: String = "menu"
var score: float = 0.0
var coins: int = 0
var combo: int = 0
var best_combo: int = 0
var star_time: float = 0.0
var star_count: int = 0
var elapsed: float = 0.0
var speed: float = RushConfig.BASE_SPEED
var next_boss_score: int = RushConfig.BOSS_INTERVAL
var spawn_wait: float = 1.2
var wave_count: int = 0
var high_score: int = 0
var run_high_score: int = 0
var lifetime_coins: int = 0
var touch_down: bool = false
var touch_fingers: Dictionary = {}
var help_open: bool = false
var help_was_running: bool = false
var persistence_enabled: bool = true
var shake: float = 0.0
var hud_timer: float = 0.0
var trail_timer: float = 0.0
var random = RandomNumberGenerator.new()
@onready var player: RunnerPlayer = $Player
@onready var actors: Node2D = $Actors
@onready var background: Node2D = $Background
@onready var boss: MechaBoss = $MechaBoss
@onready var effects: Node2D = $Effects
@onready var coin_layer: Node2D = $Coins
@onready var sound: Node = $Sound
@onready var hud: CanvasLayer = $HUD
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	random.randomize()
	_bind_inputs()
	_load_save()
	player.jumped.connect(func(): sound.play("jump"); effects.burst(player.position,Color("e8f1b6"),5))
	player.landed.connect(_landed)
	boss.warning.connect(func(message): hud.notify(message,1.7,true))
	boss.shoot.connect(_boss_fire)
	boss.defeated.connect(_boss_survived)
	hud.start_requested.connect(start_run)
	hud.restart_requested.connect(start_run)
	hud.menu_requested.connect(show_main_menu)
	hud.resume_requested.connect(resume_run)
	hud.pause_requested.connect(pause_run)
	hud.jump_requested.connect(request_jump)
	hud.duck_changed.connect(func(held): touch_down=held)
	hud.mute_requested.connect(toggle_sound)
	hud.help_requested.connect(open_help)
	hud.help_closed.connect(close_help)
	boss.reset_boss()
	hud.show_menu()
	_update_hud()

func _bind_inputs() -> void:
	var bindings = {"jump":[KEY_SPACE,KEY_W,KEY_UP],"duck":[KEY_S,KEY_DOWN],"pause_run":[KEY_P,KEY_ESCAPE],"restart_run":[KEY_R],"mute_run":[KEY_M],"fullscreen_run":[KEY_F]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event = InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action,event):
				InputMap.action_add_event(action,event)

func _load_save() -> void:
	var save = ConfigFile.new()
	if save.load(RushConfig.SAVE_PATH) == OK:
		high_score = maxi(0,int(save.get_value("records","high_score",0)))
		lifetime_coins = maxi(0,int(save.get_value("records","coins",0)))
		sound.muted = bool(save.get_value("settings","muted",false))

func _save() -> void:
	if not persistence_enabled:
		return
	var save = ConfigFile.new()
	save.set_value("records","high_score",high_score)
	save.set_value("records","coins",lifetime_coins)
	save.set_value("settings","muted",sound.muted)
	var error = save.save(RushConfig.SAVE_PATH)
	if error != OK:
		push_warning("Rekordni saqlab bo‘lmadi: "+error_string(error))

func _clear_actors() -> void:
	for enemy in actors.get_children():
		actors.remove_child(enemy)
		enemy.queue_free()

func reset_run() -> void:
	_clear_actors()
	coin_layer.coins.clear()
	effects.clear_effects()
	player.reset_runner()
	boss.reset_boss()
	score=0.0
	coins=0
	combo=0
	best_combo=0
	star_time=0.0
	star_count=0
	elapsed=0.0
	speed=RushConfig.BASE_SPEED
	next_boss_score=RushConfig.BOSS_INTERVAL
	spawn_wait=1.2
	wave_count=0
	shake=0.0
	run_high_score=high_score
	background.scroll=0.0
	background.rainbow=false
	hud.banner.text=""
	hud.star_label.text=""
	hud.star_bar.hide()
	_clear_input()
	_update_hud()

func start_run() -> void:
	if help_open:
		return
	reset_run()
	mode="playing"
	hud.hide_menu()
	hud.tip.text="SAKRA · DUSHMANNING USTIGA TUSH"
	hud.notify("↑ SAKRA · BIRINCHI STOMP SENIKI",3.2)
	_update_hud()

func show_main_menu() -> void:
	reset_run()
	mode="menu"
	hud.show_menu()
	hud.tip.text="TAYYORMISAN? YO‘L SENIKI."
	_update_hud()

func pause_run() -> void:
	if mode!="playing":
		return
	mode="paused"
	_clear_input()
	sound.stop_sounds()
	hud.show_pause()
	_update_hud()

func resume_run() -> void:
	if mode!="paused" or help_open:
		return
	_clear_input()
	mode="playing"
	hud.hide_menu()
	_update_hud()

func _clear_input() -> void:
	touch_down=false
	touch_fingers.clear()
	player.jump_buffer=0
	Input.action_release("jump")
	Input.action_release("duck")

func request_jump() -> void:
	if help_open:
		return
	match mode:
		"menu","over": start_run()
		"paused": resume_run()
		"playing": player.request_jump()

func toggle_sound() -> void:
	sound.muted = not sound.muted
	if sound.muted:
		sound.stop_sounds()
	_save()
	_update_hud()

func open_help() -> void:
	if help_open:
		return
	help_was_running=mode=="playing"
	if help_was_running:
		pause_run()
	help_open=true
	hud.show_help()

func close_help() -> void:
	hud.hide_help()
	help_open=false
	if help_was_running:
		help_was_running=false
		resume_run()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.echo:
		return
	if event.is_action_pressed("pause_run"):
		if help_open:
			close_help()
		elif mode=="playing":
			pause_run()
		elif mode=="paused":
			resume_run()
	elif event.is_action_pressed("jump"):
		request_jump()
	elif event.is_action_pressed("restart_run") and mode!="menu":
		if not help_open:
			start_run()
	elif event.is_action_pressed("mute_run"):
		toggle_sound()
	elif event.is_action_pressed("fullscreen_run"):
		var full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x>RushConfig.WIDTH*.45:
				request_jump()
			else:
				touch_fingers[event.index]=true
		else:
			touch_fingers.erase(event.index)

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		pause_run()

func _physics_process(delta: float) -> void:
	if mode=="playing":
		simulate_step(delta)
	elif mode=="menu":
		background.scroll += delta*14.0
		player.animation_time += delta
		player.queue_redraw()
	elif mode=="over":
		effects.simulate(delta,0.0)
		shake=maxf(0,shake-delta*25)
	if mode!="paused":
		background.animation_time += delta
		coin_layer.animation_time += delta
		background.queue_redraw()
		coin_layer.queue_redraw()
		camera.offset=Vector2(random.randf_range(-shake/2,shake/2),random.randf_range(-shake/2,shake/2)) if shake>0 else Vector2.ZERO
	hud_timer += delta
	if hud_timer>.06:
		_update_hud()
		hud_timer=0.0

func simulate_step(delta: float) -> void:
	elapsed += delta
	if star_time>0:
		star_time=maxf(0,star_time-delta)
		if star_time==0:
			hud.notify("STAR TUGADI · YANA COMBO YIG‘!",2.0)
			hud.tip.text="YO‘L SENIKI · YANGI COMBOGA TAYYORLAN"
	var base = minf(RushConfig.MAX_SPEED,RushConfig.BASE_SPEED+elapsed*RushConfig.ACCELERATION)
	speed=base*(2.0 if star_time>0 else 1.0)
	score += delta*(27.0+speed/75.0)
	background.scroll += speed*delta
	background.rainbow = star_time>0
	player.star_time=star_time
	var down = touch_down or not touch_fingers.is_empty() or Input.is_action_pressed("duck")
	player.simulate(delta,down)
	if boss.state=="off":
		spawn_wait -= delta
		if spawn_wait<=0:
			spawn_pattern()
		if score>=next_boss_score and star_time<=0:
			next_boss_score += RushConfig.BOSS_INTERVAL
			_clear_actors()
			boss.trigger()
			sound.play("roar")
			shake=6
			hud.tip.text="BOSS QUVMOQDA · OGOHLANTIRISHGA QARA"
	var boss_was_active = boss.state!="off"
	boss.simulate(delta)
	if boss_was_active and boss.state=="off":
		spawn_wait=1.6
		hud.tip.text="YO‘L DAVOM ETADI · KEYINGI BOSS: %d" % next_boss_score
	for enemy: RushEnemy in actors.get_children():
		enemy.simulate(delta,speed)
		if (enemy.dead and enemy.life<=0) or enemy.position.x< -200 or enemy.position.x>4000:
			enemy.queue_free()
			continue
		if enemy.dead:
			continue
		if player.hit_rect().intersects(enemy.hit_rect()):
			if star_time>0:
				_smash(enemy)
			elif enemy.stompable() and player.velocity.y>0 and player.previous_bottom<=enemy.position.y+13:
				_stomp(enemy)
			else:
				finish_run(_reason(enemy))
				return
	for i in range(coin_layer.coins.size()-1,-1,-1):
		var coin: Dictionary = coin_layer.coins[i]
		coin.point.x -= speed*delta
		if player.hit_rect().intersects(Rect2(coin.point,Vector2(15,18))):
			coins+=1
			score+=10
			sound.play("coin")
			effects.burst(coin.point,Color("f3c849"),5)
			coin_layer.coins.remove_at(i)
		elif coin.point.x< -30:
			coin_layer.coins.remove_at(i)
	sound.star_music(delta,star_time>0)
	trail_timer-=delta
	if star_time>0 and trail_timer<=0:
		effects.trail(player.position,player.body_height)
		trail_timer=.035
	effects.simulate(delta,speed)
	shake=maxf(0,shake-delta*24)
	hud.tick(delta)

func add_enemy(kind: String,x: float,y: float) -> RushEnemy:
	var enemy = EnemyScene.instantiate() as RushEnemy
	enemy.setup(kind,Vector2(x,y))
	actors.add_child(enemy)
	return enemy

func _arc(x: float,count: int=5,spacing: float=29,height: float=80) -> void:
	for i in range(count):
		coin_layer.coins.append({"point":Vector2(x+i*spacing,RushConfig.GROUND-40-height*sin(float(i+1)/float(count+1)*PI)),"phase":i*.6})

func spawn_pattern() -> void:
	wave_count+=1
	var g=RushConfig.GROUND
	var base=minf(RushConfig.MAX_SPEED,RushConfig.BASE_SPEED+elapsed*RushConfig.ACCELERATION)
	var start_x=RushConfig.WIDTH+60
	if star_time>0:
		if star_time>1.6:
			for i in range(4):
				add_enemy("pipe" if i%2 else "goomba",start_x+i*85,g-32)
			_arc(start_x,7,40,105)
		spawn_wait=1.05
		return
	if wave_count==1:
		add_enemy("goomba",start_x,g-32)
		_arc(start_x-80,5,29,90)
		spawn_wait=(RushConfig.WIDTH-player.position.x+200)/speed+1.0
		return
	var pattern="combo" if wave_count==2 or wave_count%4==2 else ("pipe" if random.randf()<.43 else ("bullet" if random.randf()<.5 else "pair"))
	if pattern=="combo":
		var flight=.568
		var acceleration=RushConfig.ACCELERATION if base<RushConfig.MAX_SPEED else 0.0
		var eta=(start_x-player.position.x)/base
		for i in range(5):
			var t=i*flight
			var x=start_x+base*t+acceleration*(eta*t+t*t/2.0)
			add_enemy("turtle" if i%3==2 else "goomba",x,g-32)
			coin_layer.coins.append({"point":Vector2(x+14,g-124),"phase":float(i)})
		spawn_wait=4*flight+(RushConfig.WIDTH-player.position.x)/base+1.5
		hud.tip.text="COMBO IZLARI · 5 DUSHMAN = 1 YULDUZ"
	elif pattern=="pipe":
		add_enemy("pipe",start_x,g-81)
		_arc(start_x-68,5,30,119)
		spawn_wait=(RushConfig.WIDTH-player.position.x+160)/base+random.randf_range(.6,1.2)
	elif pattern=="bullet":
		var high=random.randf()<.65
		add_enemy("bullet",start_x,g-(60 if high else 34))
		_arc(start_x+55,3,32,10 if high else 96)
		spawn_wait=(RushConfig.WIDTH-player.position.x+160)/base+1.0
	else:
		add_enemy("goomba",start_x,g-32)
		add_enemy("turtle",start_x+base*.568,g-32)
		_arc(start_x,4,38,115)
		spawn_wait=(RushConfig.WIDTH-player.position.x)/base+2.4

func _landed() -> void:
	if combo>0 and star_time<=0:
		combo=0
		hud.tip.text="YERGA TEGDING · YANGI COMBO YIG‘"
	effects.burst(player.position,Color("ddd5a1"),3)

func _stomp(enemy: RushEnemy) -> void:
	enemy.dead=true
	enemy.life=.24
	enemy.drift=Vector2(-speed*.35,95)
	player.bounce(enemy.position.y)
	combo+=1
	best_combo=maxi(best_combo,combo)
	score+=25*combo
	sound.play("stomp"+str(mini(combo,5)))
	effects.burst(enemy.position,Color("ffe0a0"),12)
	effects.text("%d× COMBO" % combo,player.position-Vector2(10,player.body_height+14))
	shake=2
	if combo>=RushConfig.COMBO_TARGET:
		activate_star()

func activate_star() -> void:
	star_time=RushConfig.STAR_DURATION
	star_count+=1
	combo=0
	shake=8
	spawn_wait=.1
	hud.notify("★ SUPER STAR · 6 SONIYA · 2× TEZLIK",2.8)
	hud.tip.text="★ SUPER STAR · HAMMASINI UCHIRIB YUBOR!"
	effects.burst(player.position-Vector2(0,25),Color("fff483"),25)

func _smash(enemy: RushEnemy) -> void:
	enemy.dead=true
	enemy.life=1.2
	enemy.drift=Vector2(random.randf_range(180,330),-random.randf_range(370,580))
	enemy.spin=random.randf_range(-7,7)
	score+=50
	shake=4
	sound.play("smash")
	effects.burst(enemy.position,Color("d4fc84"),12)
	effects.text("+50",enemy.position)

func _boss_fire(high: bool) -> void:
	var fire=add_enemy("fire",boss.position.x+103,RushConfig.GROUND-(55 if high else 22))
	fire.drift.x=maxf(200,speed*.8)
	sound.play("fire")

func _boss_survived() -> void:
	score+=250
	hud.notify("BOSSDAN QUTULDING! +250",2.0)
	effects.text("+250",player.position-Vector2(0,85))
	sound.play("note3")

func _reason(enemy: RushEnemy) -> String:
	match enemy.kind:
		"pipe": return "Tishli gul ustidan sakrab o‘t."
		"bullet": return "O‘q ostidan egil yoki ustiga tush."
		"fire": return "Baland olovda egil." if enemy.position.y<RushConfig.GROUND-40 else "Past olovdan sakrab o‘t."
	return "Dushmanning yoniga emas, ustiga tush."

func finish_run(reason: String) -> void:
	if mode!="playing":
		return
	mode="over"
	_clear_input()
	player.hide()
	shake=9
	sound.stop_sounds()
	sound.play("hit")
	effects.burst(player.position-Vector2(0,25),Color("f18a58"),25)
	high_score=maxi(high_score,int(score))
	lifetime_coins+=coins
	_save()
	hud.banner.text=""
	hud.show_result(int(score),coins,best_combo,star_count,int(score)>run_high_score,reason)
	_update_hud()

func _update_hud() -> void:
	hud.update_values(int(score),coins,combo,star_time,speed,high_score,mode,sound.muted)
