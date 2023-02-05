extends Control


var time := 5.0
var processing := false


func _process(_delta: float) -> void:
	if visible and not processing:
		$Tween.interpolate_property(
			$TextureRect, 
			"self_modulate", 
			$TextureRect.self_modulate, 
			Color.white, 
			time, 
			Tween.TRANS_LINEAR, 
			Tween.EASE_IN_OUT
		)
		processing = true
		$Tween.start()
	elif not visible:
		processing = false
		$Tween.stop_all()
