class_name ParticlePlant extends Area2D


export var root_time : float = 0.0
export var move_speed : float = 0.0
export var plant_root_scene : PackedScene
export var plant_move_scene : PackedScene
export var rotten_color : Color


onready var root1 := $Roots/Root1 as Position2D
onready var root2 := $Roots/Root2 as Position2D
onready var root3 := $Roots/Root3 as Position2D
onready var root4 := $Roots/Root4 as Position2D

onready var roots_node := $Roots as Node2D
onready var skin := $Skin as Node2D
onready var timer := $LifeTimer as Timer
onready var color_tween := $Tween as Tween
onready var vignette := $FilterLayer/Vignette as Control


var _just_started := true
var _can_hook := true
var _connected := false
var _disconnecting := false
var _final_position := Vector2()
var _current_normal := Vector2()
var _root_name : String = "PlantRoot"
var _time : float = 0.0


func _ready() -> void:
	_time = timer.wait_time


func _process(_delta: float) -> void:
	if not _connected and _final_position.length() == 0.0 and not _just_started:
		if timer.is_stopped():
			timer.start(_time)
			color_tween.interpolate_property(
				self, 
				"modulate", 
				self.modulate, 
				rotten_color, 
				_time, 
				Tween.TRANS_LINEAR, 
				Tween.EASE_IN_OUT
			)
			color_tween.start()
			vignette.show()
	if Input.is_action_pressed("move"):
		_launch_move()


func _physics_process(delta: float) -> void:
	if _final_position.length() > 0.0:
		var direction : Vector2 =  _final_position - global_position
		skin.rotate(deg2rad(720) * delta)
		global_position += direction.normalized() * move_speed * delta
		if global_position.distance_to(_final_position) < 50.0:
			global_position = _final_position
			_final_position = Vector2()
			skin.rotation = 0.0
			if not _disconnecting and not $ConnectSound.playing:
				$ConnectSound.play()
			_connected = not _disconnecting
			_disconnecting = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("hook") and event.is_pressed():
		_launch_hook()



func _launch_hook() -> void:
	if _can_hook:
		var error : int = OK
		var plant_root : PlantRoot = plant_root_scene.instance() as PlantRoot
		if not plant_root:
			return
		_can_hook = false
		error = plant_root.connect("ready", self, "_connect_roots")
		error = plant_root.connect("tree_exited", self, "_root_free")
		error = plant_root.connect("root_connected", self, "_travel")
		if error != OK:
			return
		plant_root.global_position = global_position
		add_child(plant_root)
		plant_root.name = _root_name


func _launch_move() -> void:
	if _can_hook:
		var error : int = OK
		var plant_root : PlantMove = plant_move_scene.instance() as PlantMove
		if not plant_root:
			return
		_can_hook = false
		error = plant_root.connect("ready", self, "_setup_hook")
		error = plant_root.connect("tree_exited", self, "_root_free")
		error = plant_root.connect("root_connected", self, "_travel")
		if error != OK:
			return
		plant_root.global_position = global_position
		add_child(plant_root)
		plant_root.name = _root_name


func _connect_roots() -> void:
	var plant_root := get_node(_root_name) as PlantRoot
	if not plant_root:
		return
	plant_root.root1.add_point(root1.global_position)
	plant_root.root2.add_point(root2.global_position)
	plant_root.root3.add_point(root3.global_position)
	plant_root.root4.add_point(root4.global_position)
	
	var dir : Vector2 = get_local_mouse_position().normalized()
	plant_root.setup(dir, root_time, _current_normal)


func _setup_hook() -> void:
	var plant_root := get_node(_root_name) as PlantMove
	if not plant_root:
		return
	var dir : Vector2 = get_local_mouse_position().normalized()
	plant_root.setup(dir, root_time)


func _root_free() -> void:
	_can_hook = true


func _travel(roots : Array) -> void:
	_just_started = false
	_final_position = roots[0]
	_current_normal = roots[1]
	if not timer.is_stopped():
		_time = timer.time_left
		vignette.time = _time;
		vignette.hide()
		timer.stop()
		color_tween.stop(self)


func _on_ParticlePlant_body_exited(body: Node) -> void:
	if body.is_in_group("connected"):
		body.remove_from_group("connected")


func _disconnect() -> void:
	if _connected:
		if has_node(_root_name) and _final_position.length() > 0.0:
			for con in get_tree().get_nodes_in_group("connected"):
				con.remove_from_group("connected")
			get_node(_root_name).queue_free()
			_current_normal = Vector2()
		_connected = false
		_disconnecting = true
		_final_position = global_position + _current_normal * 1000
		_current_normal = Vector2()


func _on_LifeTimer_timeout() -> void:
	var game_controller := get_tree().get_nodes_in_group("game_controller")[0] as GameController
	game_controller.back_to_main()
