extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	$AnimationPlayer.play("fade")


func _on_AnimationPlayer_animation_finished(anim_name):
	hide()
