class_name PlantRoot extends Area2D



signal root_connected



export var _move_speed : float = 0.0


onready var root1 := $Roots/Root1/RootHair as RootHair
onready var root2 := $Roots/Root2/RootHair as RootHair
onready var root3 := $Roots/Root3/RootHair as RootHair
onready var root4 := $Roots/Root4/RootHair as RootHair

onready var _timer := $Timer as Timer
onready var _shape := $Shape.shape as Shape2D


var _direction := Vector2.UP
var _connected := false
var _is_setup := false
var _normal := Vector2()
var _rotation_speed : float = 0.0



func _ready() -> void:
	randomize()
	_rotation_speed = deg2rad(360 * rand_range(1.0, 3.0))
	set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	if not _connected and _is_setup:
		rotate(_rotation_speed * delta)
		position += _direction * delta * _move_speed
	elif root1.points.size() + root2.points.size() + root3.points.size() + root4.points.size() == 0:
		queue_free()


func setup(direction : Vector2, time : float, normal : Vector2) -> void:
	if not _is_setup:
		if normal.length() > 0.0:
			if rad2deg(acos(direction.dot(normal) / direction.length() / direction.length())) > 90:
				queue_free()
		_direction = direction
		_connected = false
		_is_setup = true
		_timer.wait_time = time
		_timer.one_shot = true
		_timer.start()


func _on_Timer_timeout() -> void:
	if _connected:
		return
	_disable_root()
	_is_setup = false


func _on_PlantRoot_body_entered(body: Node) -> void:
	if body.is_in_group("connected"):
		return
	var shape : CollisionShape2D = body.get_node("Shape") as CollisionShape2D
	if not shape:
		return
	var points := _shape.collide_and_get_contacts(global_transform, shape.shape, shape.global_transform)
	if points.size() < 2:
		return
	position = points[1]
	_disable_root(true)
	var normal : Vector2 = (points[1] - points[0]).normalized()
	emit_signal("root_connected", [self.global_position, normal])
	body.add_to_group("connected")


func _disable_root(done := false) -> void:
	root1.active = false
	root2.active = false
	root3.active = false
	root4.active = false
	root1.done = done
	root2.done = done
	root3.done = done
	root4.done = done
