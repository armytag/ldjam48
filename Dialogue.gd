extends Panel

signal start_game
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var stage = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "Well, if it isn't the Deeper siblings..."


func _input(event):
	if visible and event.is_action_pressed("ui_accept"):
		print(event)
		stage += 1
	if stage == 1:
		$Label.text = "You won't get any more evidence without a fight!"
	elif stage == 2:
		$Label.text = "GET 'EM!!!"
	elif stage == 3:
		get_tree().paused = false
		emit_signal('start_game')
		hide()
		queue_free()
