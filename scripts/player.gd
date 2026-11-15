class_name RunnerPlayer
extends CharacterBody2D
## Feet are the node origin. Floor collision uses Godot's CharacterBody2D;
## enemy contacts are resolved by Main after every fixed physics step.
signal jumped
signal landed
var body_height: float = RushConfig.PLAYER_HEIGHT
var grounded: bool = true
var ducking: bool = false
var previous_bottom: float = RushConfig.GROUND
var jump_buffer: float = 0.0
var animation_time: float = 0.0
var star_time: float = 0.0
var fast_falling: bool = false
var frames: Array[Texture2D] = [preload("res://assets/sprites/hero0.png"), preload("res://assets/sprites/hero1.png")]
var duck_texture: Texture2D = preload("res://assets/sprites/duck.png")
@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	shape.shape = shape.shape.duplicate()
	reset_runner()

func reset_runner() -> void:
	position = Vector2(RushConfig.PLAYER_X, RushConfig.GROUND)
	velocity = Vector2.ZERO
	grounded = true
	ducking = false
	body_height = RushConfig.PLAYER_HEIGHT
	jump_buffer = 0.0
	previous_bottom = position.y
	visible = true
	_apply_shape()

func request_jump() -> void:
	jump_buffer = 0.14

func simulate(delta: float, down: bool) -> void:
	animation_time += delta
	previous_bottom = position.y
	jump_buffer = maxf(0.0, jump_buffer - delta)
	fast_falling = down and not grounded
	if grounded:
		ducking = down
		body_height = RushConfig.DUCK_HEIGHT if down else RushConfig.PLAYER_HEIGHT
		_apply_shape()
		if jump_buffer > 0.0 and not down:
			grounded = false
			ducking = false
			body_height = RushConfig.PLAYER_HEIGHT
			_apply_shape()
			velocity.y = RushConfig.JUMP
			jump_buffer = 0.0
			jumped.emit()
	if not grounded:
		velocity.y += (RushConfig.FAST_FALL_GRAVITY if down else RushConfig.GRAVITY) * delta
	else:
		velocity.y = 10.0 # Retain floor contact without drifting.
	var was_airborne = not grounded
	move_and_slide()
	grounded = is_on_floor()
	if grounded and was_airborne:
		landed.emit()
	queue_redraw()

func bounce(top: float) -> void:
	position.y = top
	velocity.y = RushConfig.BOUNCE
	grounded = false
	ducking = false
	body_height = RushConfig.PLAYER_HEIGHT
	jump_buffer = 0.0
	_apply_shape()

func hit_rect() -> Rect2:
	return Rect2(position + Vector2(4.0, -body_height + 3.0), Vector2(24.0, body_height - 5.0))

func _apply_shape() -> void:
	if not is_instance_valid(shape):
		return
	(shape.shape as RectangleShape2D).size = Vector2(RushConfig.PLAYER_WIDTH, body_height)
	shape.position = Vector2(16.0, -body_height / 2.0)

func _draw() -> void:
	if star_time > 0.0:
		draw_rect(Rect2(-7, -body_height - 6, 46, body_height + 10), Color.from_hsv(fmod(animation_time * 0.4, 1.0), 0.65, 1.0, 0.26))
	var tex = duck_texture if ducking else frames[int(animation_time * 11.0) % 2 if grounded else 1]
	draw_texture_rect(tex, Rect2(-4, -body_height - 4, 40, body_height + 5), false)
	if fast_falling:
		draw_rect(Rect2(8, -body_height - 24, 3, 13), Color("f6f6c3"))
		draw_rect(Rect2(24, -body_height - 36, 3, 18), Color("f6f6c3"))
