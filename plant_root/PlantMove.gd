class_name PlantMove extends Area2D



signal root_connected



export var _move_speed : float = 0.0

onready var _timer := $Timer as Timer
onready var _shape := $Shape.shape as Shape2D


var _direction := Vector2.UP
var _connected := false
var _inactive := false
var _is_setup := false



func _ready() -> void:
	set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	if not _connected and _is_setup:
		rotate(deg2rad(720 * delta))
		position += _direction * delta * _move_speed
	if _connected:
		queue_free()


func setup(direction : Vector2, time : float) -> void:
	if not _is_setup:
		_direction = direction
		_connected = false
		_is_setup = true
		_timer.wait_time = time
		_timer.one_shot = true
		_timer.start()


func _on_Timer_timeout() -> void:
	if _connected:
		return
	_is_setup = false
	queue_free()


func _on_PlantRoot_body_entered(body: Node) -> void:
	if _inactive:
		return
	if not body.is_in_group("connected"):
		queue_free()
		_inactive = true
		return
	var shape : CollisionShape2D = body.get_node("Shape") as CollisionShape2D
	if not shape:
		queue_free()
		_inactive = true
		return
	var points := _shape.collide_and_get_contacts(global_transform, shape.shape, shape.global_transform)
	if points.size() < 2:
		queue_free()
		_inactive = true
		return
	position = points[1]
	_connected = true
	var colliding_bodies : Array = get_overlapping_bodies()
	for col_body in colliding_bodies:
		if col_body.is_in_group("world"):
			queue_free()
			_inactive = true
			return
	var normal : Vector2 = (points[1] - points[0]).normalized()
	emit_signal("root_connected", [self.global_position, normal])
	body.add_to_group("connected")
