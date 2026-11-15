extends SceneTree
## Run: godot --headless --fixed-fps 120 --path . --script tests/smoke_test.gd
var game: Node2D
var failures: int = 0
var checks: int = 0
var backup: PackedByteArray
var had_save: bool = false

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool,message: String) -> void:
	checks+=1
	if condition:
		print("PASS ",message)
	else:
		failures+=1
		push_error("FAIL "+message)

func quiet_run() -> void:
	game.start_run()
	game.sound.muted=true
	game.spawn_wait=100000.0
	game.next_boss_score=1000000

func tick(count: int) -> void:
	for i in range(count):
		await physics_frame
		if game.mode=="playing":
			game.simulate_step(1.0/120.0)

func _run() -> void:
	had_save=FileAccess.file_exists(RushConfig.SAVE_PATH)
	if had_save:
		backup=FileAccess.get_file_as_bytes(RushConfig.SAVE_PATH)
	game=load("res://scenes/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game.persistence_enabled=false
	quiet_run()
	game.player.request_jump()
	await tick(1)
	check(game.player.velocity.y<0,"Space action starts a native CharacterBody2D jump")
	await tick(100)
	check(game.player.grounded,"Player lands on native StaticBody2D floor")
	game.touch_down=true
	await tick(1)
	check(game.player.body_height==24,"Ducking reduces the collision shape to 24 pixels")
	game.touch_down=false
	await tick(1)
	check(game.player.body_height==46,"Releasing duck restores the normal collision shape")
	game.player.request_jump()
	await tick(10)
	game.touch_down=true
	await tick(40)
	check(game.player.grounded,"Airborne down action performs fast-fall")
	game.touch_down=false
	game.combo=3
	game.player.request_jump()
	await tick(100)
	check(game.combo==0,"Landing resets an unfinished combo")
	for start_time in [0.0,60.0,220.0]:
		quiet_run()
		game.elapsed=start_time
		await tick(1)
		game.wave_count=1
		game.spawn_pattern()
		var jumped=false
		for frame in range(1600):
			var first: RushEnemy=null
			for enemy: RushEnemy in game.actors.get_children():
				if not enemy.dead:
					first=enemy
					break
			if first and not jumped and first.position.x-game.player.position.x<=game.speed*.62+8:
				game.player.request_jump()
				jumped=true
			await tick(1)
			if game.star_count>0 or game.mode!="playing":
				break
		check(game.mode=="playing" and game.best_combo==5 and game.star_count==1,"Five real stomps activate Star at difficulty time "+str(start_time))
	quiet_run()
	game.activate_star()
	game.spawn_wait=100000
	var pipe=game.add_enemy("pipe",game.player.position.x,0)
	await tick(1)
	check(pipe.dead,"Super Star smashes a piranha pipe")
	check(game.speed>RushConfig.BASE_SPEED*1.99,"Super Star doubles world speed")
	await tick(720)
	check(game.star_time==0,"Super Star ends after six seconds")
	quiet_run()
	game.add_enemy("pipe",game.player.position.x,0)
	await tick(1)
	check(game.mode=="over","A normal pipe collision ends the run")
	for duck in [false,true]:
		quiet_run()
		game.touch_down=duck
		var fire=game.add_enemy("fire",game.player.position.x-100,RushConfig.GROUND-55)
		fire.drift.x=200
		await tick(80)
		check(game.mode==("playing" if duck else "over"),"High fire collision respects duck = "+str(duck))
	quiet_run()
	game.coin_layer.coins.append({"point":game.player.position-Vector2(0,30),"phase":0.0})
	await tick(1)
	check(game.coins==1 and game.score>=10,"Coins collect and add ten points")
	quiet_run()
	game.score=1000
	game.next_boss_score=1000
	await tick(1)
	check(game.boss.state=="warning" and game.next_boss_score==2000,"Boss threshold triggers at 1,000 and advances to 2,000")
	game.boss.state="attack"
	game.boss.remaining=12
	game.boss.cooldown=1000
	for i in range(1439):
		game.boss.simulate(1.0/120.0)
	check(game.boss.state=="attack","Boss remains active for the first 11.99 seconds")
	var before=game.score
	game.boss.simulate(.02)
	check(game.boss.state=="retreat" and game.score>=before+250,"Boss retreats at twelve seconds and rewards 250 points")
	quiet_run()
	game.pause_run()
	check(game.mode=="paused","Pause stops the gameplay state")
	game.resume_run()
	check(game.mode=="playing","Resume restores the gameplay state")
	game.open_help()
	check(game.help_open and game.mode=="paused","Help pauses an active run")
	game.close_help()
	check(not game.help_open and game.mode=="playing","Closing help resumes the active run")
	game.high_score=12345
	game.lifetime_coins=54
	game.persistence_enabled=true
	game._save()
	var cfg=ConfigFile.new()
	check(cfg.load(RushConfig.SAVE_PATH)==OK and cfg.get_value("records","high_score")==12345 and cfg.get_value("records","coins")==54,"Native ConfigFile persists score and coin totals")
	if had_save:
		var f=FileAccess.open(RushConfig.SAVE_PATH,FileAccess.WRITE)
		f.store_buffer(backup)
		f.close()
	else:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RushConfig.SAVE_PATH))
	print("RESULT: ",checks-failures,"/",checks," checks passed")
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
