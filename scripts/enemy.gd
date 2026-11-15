class_name RushEnemy
extends Area2D
## Editable actor scene. Area shapes document the hitbox; Main resolves
## swept top contacts before side hits, keeping fast stomps deterministic.
var kind: String = "goomba"
var size: Vector2 = Vector2(34, 32)
var dead: bool = false
var life: float = 1.2
var drift: Vector2 = Vector2.ZERO
var spin: float = 0.0
var animation_time: float = 0.0
var sprites: Dictionary = {
	"goomba": preload("res://assets/sprites/goomba.png"),
	"turtle": preload("res://assets/sprites/turtle.png"),
	"bullet": preload("res://assets/sprites/bullet.png")
}

func setup(type: String, point: Vector2) -> void:
	kind = type
	position = point
	if kind == "pipe":
		size = Vector2(44, 81)
		position.y = RushConfig.GROUND - size.y
	elif kind == "bullet":
		size = Vector2(42, 26)
	elif kind == "fire":
		size = Vector2(25, 19)
	if is_node_ready():
		_update_shape()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_update_shape()

func _update_shape() -> void:
	var collision = $CollisionShape2D as CollisionShape2D
	collision.shape = RectangleShape2D.new()
	collision.shape.size = size
	collision.position = size / 2.0

func stompable() -> bool:
	return kind in ["goomba", "turtle", "bullet"]

func hit_rect() -> Rect2:
	var inset = 6.0 if kind == "pipe" else 3.0
	return Rect2(position + Vector2(inset, 3.0), size - Vector2(inset * 2.0, 5.0))

func simulate(delta: float, speed: float) -> void:
	animation_time += delta
	if dead:
		position += drift * delta
		drift.y += 1400.0 * delta
		rotation += spin * delta
		life -= delta
		modulate.a = minf(1.0, life * 3.0)
	elif kind == "fire":
		position.x += drift.x * delta
	else:
		position.x -= speed * delta
	queue_redraw()

func _draw() -> void:
	if kind == "pipe":
		_pipe()
	elif kind == "fire":
		_fire()
	else:
		var draw_size = size
		if dead and life < 0.25 and spin == 0.0:
			draw_size.y = 10.0
		draw_texture_rect(sprites[kind], Rect2(Vector2.ZERO, draw_size), false)
		if kind == "bullet" and not dead:
			_r(44, 9, 9, 7, "e6a85b")
			_r(50, 11, 7, 3, "f4d98b")

func _r(x: float, y: float, w: float, h: float, hex: String) -> void:
	draw_rect(Rect2(x, y, w, h), Color(hex))

func _pipe() -> void:
	_r(3, 34, 38, 47, "345d36")
	_r(7, 38, 9, 43, "8db649")
	_r(16, 38, 18, 43, "6b973f")
	_r(0, 30, 44, 14, "294b30")
	_r(3, 32, 38, 8, "97bf57")
	_r(8, 32, 6, 8, "c6dc7a")
	_r(20, 10, 5, 20, "3f793c")
	_r(15, 19, 7, 5, "71a64c")
	_r(24, 14, 8, 5, "71a64c")
	_r(8, 2, 29, 19, "365039")
	_r(5, 5, 35, 12, "e36e49")
	_r(10, 0, 25, 5, "f5955b")
	_r(10, 6, 24, 5, "fff0c1")
	_r(11, 11, 4, 4, "fff0c1")
	_r(27, 11, 4, 4, "fff0c1")
	_r(13, 17, 18, 5, "ba563c")

func _fire() -> void:
	var tail = 5.0 * float(int(animation_time * 12.0) % 2)
	draw_colored_polygon(PackedVector2Array([Vector2(3, 2), Vector2(18, 0), Vector2(26, 7), Vector2(26, 13), Vector2(19, 19), Vector2(4, 16), Vector2(-9-tail, 21), Vector2(-4, 10), Vector2(-10, -2)]), Color("ee9a42"))
	_r(5, 5, 14, 10, "ffe58c")
	_r(13, 7, 8, 6, "fff7c4")
