extends Area2D



onready var raycast := $RayCast2D as RayCast2D
onready var laser := $Base/Head/Barrel/Cannon/Line2D as Line2D
onready var cannon := $Base/Head/Barrel/Cannon as Position2D
onready var flash := $Base/Head/Barrel/Cannon/Flash as Sprite

var _target : ParticlePlant = null
var _detected := false 
var _can_shoot := true
var _active := true



func _ready() -> void:
	laser.set_as_toplevel(true)


func _physics_process(delta: float) -> void:
	if _active:
		if _target and _can_shoot:
			if not $Timer.is_stopped():
				laser.width += 15 * delta
			raycast.cast_to = _target.global_position - global_position
			var check_target := raycast.get_collider()
			if check_target is ParticlePlant:
				_detected = true
				$Base/Head.global_rotation = raycast.cast_to.angle()
				laser.clear_points()
				laser.add_point(cannon.global_position)
				laser.add_point(_target.global_position)
				if $Timer.is_stopped():
					$Timer.start()
			else:
				_detected = false
				laser.clear_points()
				laser.width = 10


func _on_PlantDetector_area_entered(area: Area2D) -> void:
	if area is ParticlePlant and _active:
		raycast.cast_to = area.global_position - global_position
		_target = area


func _on_PlantDetector_area_exited(area: Area2D) -> void:
	if area == _target and _active:
		_target = null
		_detected = false
		laser.clear_points()
		laser.width = 10


func _on_Timer_timeout() -> void:
	if _active:
		if not _target:
			return
		flash.frame = randi() % 3
		flash.show()
		$ShootSound.play()
		var error : int = get_tree().create_timer(4.0).connect("timeout", self, "_ready_to_shoot")
		error = get_tree().create_timer(0.07).connect("timeout", flash, "hide")
		if error != OK:
			get_tree().quit()
		_can_shoot = false
		_detected = false
		laser.clear_points()
		laser.width = 10
		_target._disconnect()


func _ready_to_shoot() -> void:
	_can_shoot = true


func disable_turret() -> void:
	if _active:
		raycast.enabled = false
		$PlantDetector.monitoring = false
		monitoring = false
		$Base/Head.hide()
		_active = false
