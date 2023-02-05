extends Area2D



export var key : String


func run() -> void:
	var game_controller := get_tree().get_nodes_in_group("game_controller")[0] as GameController
	game_controller.access.append(key)
	queue_free()
