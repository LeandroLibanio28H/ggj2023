class_name RootHair extends Line2D


onready var parent := get_parent() as Position2D
onready var active := true
onready var done := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_as_toplevel(true)
	clear_points()


func _physics_process(_delta: float) -> void:
	if active:
		add_point(parent.global_position)
	elif points.size() > 0:
		remove_point((points.size() - 1) if not done else 0)
