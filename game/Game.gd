class_name GameController extends Node2D



var access := []


func back_to_main() -> void:
	get_tree().change_scene("res://menu/Title.tscn")


func load_win_scene() -> void:
	get_tree().change_scene("res://menu/Win.tscn")
