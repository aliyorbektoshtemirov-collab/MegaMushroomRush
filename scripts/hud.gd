extends CanvasLayer
signal jump_requested
signal duck_changed(held: bool)
signal start_requested
signal pause_requested
signal resume_requested
signal restart_requested
signal menu_requested
signal mute_requested
signal help_requested
signal help_closed
var root_control: Control
var overlay: Control
var help_overlay: Control
var score_label: Label
var coin_label: Label
var combo_label: Label
var speed_label: Label
var banner: Label
var star_label: Label
var star_bar: ProgressBar
var tip: Label
var mute_button: Button
var pause_button: Button
var notice_time: float = 0.0
var previous_mode: String = ""

func _ready() -> void:
	root_control = Control.new()
	root_control.name = "Interface"
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)
	_panel(root_control,Rect2(0,0,960,76),Color("19271f"),0)
	_panel(root_control,Rect2(0,510,960,90),Color("19271f"),0)
	var icon = Sprite2D.new()
	icon.texture = preload("res://assets/icon.svg")
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.position = Vector2(41,38)
	icon.scale = Vector2.ONE * (38.0 / 144.0)
	root_control.add_child(icon)
	_label(root_control,"MEGA MUSHROOM\nRUSH",Rect2(73,16,200,46),17,RushConfig.CREAM)
	_label(root_control,"OCHKO",Rect2(286,10,100,17),10,Color("afbe9f"))
	score_label = _label(root_control,"000000",Rect2(285,28,130,35),25,RushConfig.CREAM)
	_label(root_control,"TANGA",Rect2(418,10,80,17),10,Color("afbe9f"))
	coin_label = _label(root_control,"0",Rect2(418,28,80,35),25,Color("f2cc6d"))
	_label(root_control,"STOMP COMBO",Rect2(524,10,190,17),10,Color("afbe9f"))
	combo_label = _label(root_control,"☆ ☆ ☆ ☆ ☆",Rect2(524,29,190,33),24,Color("879d71"))
	speed_label = _label(root_control,"1.0×",Rect2(722,26,70,35),20,RushConfig.LIME)
	mute_button = _button(root_control,"SFX",Rect2(794,22,47,34),func(): mute_requested.emit(),false)
	pause_button = _button(root_control,"II",Rect2(848,22,43,34),func(): pause_requested.emit(),false)
	_button(root_control,"?",Rect2(898,22,40,34),func(): help_requested.emit(),false)
	banner = _label(root_control,"",Rect2(180,88,600,30),16,RushConfig.INK,true)
	star_label = _label(root_control,"",Rect2(22,464,350,28),17,Color("fff4c5"))
	star_bar = ProgressBar.new()
	star_bar.position = Vector2(23,495)
	star_bar.size = Vector2(178,5)
	star_bar.max_value = RushConfig.STAR_DURATION
	star_bar.show_percentage = false
	star_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	star_bar.add_theme_stylebox_override("fill",_style(RushConfig.LIME,0))
	root_control.add_child(star_bar)
	var duck = _button(root_control,"↓  EGILISH  [S]",Rect2(22,527,210,53),func(): pass,false)
	duck.focus_mode = Control.FOCUS_NONE
	duck.button_down.connect(func(): duck_changed.emit(true))
	duck.button_up.connect(func(): duck_changed.emit(false))
	var jump_button = _button(root_control,"↑  SAKRASH  [SPACE]",Rect2(246,527,262,53),func(): pass,true)
	jump_button.focus_mode = Control.FOCUS_NONE
	jump_button.button_down.connect(func(): jump_requested.emit())
	tip = _label(root_control,"TAYYORMISAN? YO‘L SENIKI.",Rect2(534,532,402,45),13,Color("c4d9aa"))
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay = _overlay("Menu")
	help_overlay = _overlay("Help")
	help_overlay.hide()

func _style(color: Color, radius: int = 6) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	return box

func _panel(parent: Node, rect: Rect2, color: Color, radius: int = 6) -> Panel:
	var panel = Panel.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel",_style(color,radius))
	parent.add_child(panel)
	return panel

func _label(parent: Node,text: String,rect: Rect2,font_size: int,color: Color,center: bool=false) -> Label:
	var label = Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if center else HORIZONTAL_ALIGNMENT_LEFT
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(parent: Node,text: String,rect: Rect2,callback: Callable,primary: bool) -> Button:
	var button = Button.new()
	button.text = text
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size",15)
	var color = RushConfig.LIME if primary else Color("2c3c2e")
	button.add_theme_stylebox_override("normal",_style(color))
	button.add_theme_stylebox_override("hover",_style(color.lightened(.09)))
	button.add_theme_stylebox_override("pressed",_style(color.darkened(.12)))
	button.add_theme_color_override("font_color",RushConfig.INK if primary else RushConfig.CREAM)
	button.add_theme_color_override("font_hover_color",RushConfig.INK if primary else RushConfig.CREAM)
	button.add_theme_color_override("font_pressed_color",RushConfig.INK if primary else RushConfig.CREAM)
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _overlay(node_name: String) -> Control:
	var control = Control.new()
	control.name = node_name
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(control)
	return control

func _clear(control: Control) -> void:
	for child in control.get_children():
		control.remove_child(child)
		child.queue_free()

func _shade(parent: Control) -> void:
	var shade = ColorRect.new()
	shade.color = Color(0.06,.13,.08,.66)
	shade.size = Vector2(960,600)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(shade)

func show_menu() -> void:
	_clear(overlay)
	overlay.show()
	_label(overlay,"SAKRA. COMBO YIG‘. PORLA.",Rect2(220,124,520,22),13,RushConfig.INK,true)
	_label(overlay,"MEGA",Rect2(220,150,520,60),54,RushConfig.INK,true)
	_label(overlay,"MUSHROOM",Rect2(180,205,600,70),68,RushConfig.INK,true)
	_label(overlay,"RUSH!",Rect2(220,271,520,76),73,Color("d5733e"),true)
	_label(overlay,"Besh stomp — va sen yulduzsan.\nFaqat orqangdagi bossni unutma.",Rect2(230,354,500,45),16,RushConfig.INK,true)
	_button(overlay,"O‘YINNI BOSHLASH  →",Rect2(325,409,310,52),func(): start_requested.emit(),true)
	_label(overlay,"SPACE / W / ↑  ·  TELEFONDA TUGMALAR",Rect2(220,478,520,22),11,RushConfig.INK,true)

func hide_menu() -> void:
	overlay.hide()
	var focus = get_viewport().gui_get_focus_owner()
	if focus:
		focus.release_focus()

func show_pause() -> void:
	_clear(overlay)
	overlay.show()
	_shade(overlay)
	_panel(overlay,Rect2(260,157,440,295),Color("f0f2d9"))
	_label(overlay,"BIR NAFAS OL",Rect2(280,181,400,25),13,Color("826039"),true)
	_label(overlay,"Kichik tanaffus.",Rect2(280,219,400,53),36,RushConfig.INK,true)
	_label(overlay,"Qo‘ziqorinlar seni kutib turadi.",Rect2(280,278,400,30),16,RushConfig.INK,true)
	_button(overlay,"DAVOM ETISH  →",Rect2(320,330,320,48),func(): resume_requested.emit(),true)
	_button(overlay,"Qaytadan boshlash",Rect2(320,394,320,34),func(): restart_requested.emit(),false)

func show_result(points: int,coins: int,best_combo: int,stars: int,record: bool,reason: String) -> void:
	_clear(overlay)
	overlay.show()
	_shade(overlay)
	_panel(overlay,Rect2(245,124,470,375),Color("f0f2d9"))
	_label(overlay,"★ YANGI REKORD!" if record else "YAXSHI YUGURDING!",Rect2(260,146,440,24),13,Color("826039"),true)
	_label(overlay,"Yana bir urinish?",Rect2(260,179,440,43),33,RushConfig.INK,true)
	_label(overlay,"%06d" % points,Rect2(260,227,440,66),54,RushConfig.INK,true)
	_label(overlay,reason,Rect2(262,302,436,26),14,RushConfig.INK,true)
	_label(overlay,"TANGA: %d     COMBO: %d×     STAR: %d" % [coins,best_combo,stars],Rect2(260,343,440,26),15,RushConfig.INK,true)
	_button(overlay,"YANA O‘YNASH  ↻",Rect2(320,390,320,48),func(): restart_requested.emit(),true)
	_button(overlay,"Bosh menyu",Rect2(320,452,320,30),func(): menu_requested.emit(),false)

func show_help() -> void:
	_clear(help_overlay)
	help_overlay.show()
	_shade(help_overlay)
	_panel(help_overlay,Rect2(165,94,630,414),Color("1e2c22"))
	_label(help_overlay,"Yo‘lga chiqishdan oldin.",Rect2(195,116,570,44),30,RushConfig.CREAM)
	var description = "SPACE / W / ↑ — sakrash.  S / ↓ — egilish.\nHavoda ↓ bosib tursang, tez tushasan.\n\nDushmanning ustiga tush: har stomp yana sakratadi.\nYerga tegmasdan 5 stomp = 6 soniyalik SUPER STAR!\nStar: yengilmaslik va 2× tezlik. Quvurlarni ham uchir.\n\nTishli gulni oddiy stomp bilan yengib bo‘lmaydi.\nBoss har 1 000 ochkoda keladi. 12 soniya chidab tur.\nPast olovda SAKRA, baland olovda EGIL.\n\nP / ESC — pauza · R — qayta · M — ovoz · F — to‘liq ekran."
	_label(help_overlay,description,Rect2(195,174,570,245),16,Color("c4d4b8"))
	_button(help_overlay,"TUSHUNARLI  →",Rect2(320,444,320,42),func(): help_closed.emit(),true)

func hide_help() -> void:
	help_overlay.hide()

func notify(message: String,seconds: float=2.0,boss_warning: bool=false) -> void:
	banner.text = message
	banner.add_theme_color_override("font_color",Color("a64525") if boss_warning else RushConfig.INK)
	notice_time = seconds

func tick(delta: float) -> void:
	if notice_time>0:
		notice_time -= delta
		if notice_time<=0:
			banner.text = ""

func update_values(points: int,coins: int,combo: int,star: float,speed: float,record: int,mode: String,muted: bool) -> void:
	score_label.text = "%06d" % (record if mode == "menu" else points)
	coin_label.text = str(coins)
	var marks = ""
	for i in range(5):
		marks += ("★" if star>0 or i<combo else "☆") + " "
	combo_label.text = marks
	combo_label.add_theme_color_override("font_color",Color("f2c86b") if star>0 or combo>0 else Color("879d71"))
	speed_label.text = "%.1f×" % (speed/RushConfig.BASE_SPEED)
	mute_button.text = "OFF" if muted else "SFX"
	pause_button.disabled = mode != "playing"
	star_label.text = "★ SUPER STAR   %.1fs" % star if star>0 and mode=="playing" else ""
	star_bar.visible = star>0 and mode=="playing"
	star_bar.value = star
