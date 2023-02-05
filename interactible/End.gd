extends Area2D



func run() -> void:
	var game_controller := get_tree().get_nodes_in_group("game_controller")[0] as GameController
	game_controller.load_win_scene()
