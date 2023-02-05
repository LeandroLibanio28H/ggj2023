extends Control


export var _next_scene : PackedScene


func _ready() -> void:
	set_process_unhandled_input(true)


func _input(event: InputEvent) -> void:
	if event.is_action("hook"):
		if event.pressed:
			get_tree().change_scene_to(_next_scene)
