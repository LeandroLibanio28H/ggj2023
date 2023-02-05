extends Area2D


export var key : String


func run() -> void:
	var game_controller := get_tree().get_nodes_in_group("game_controller")[0] as GameController
	if game_controller.access.has(key):
		queue_free()
