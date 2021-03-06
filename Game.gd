extends Node2D

const GOON = preload("res://Goon.tscn")

var evidence_count = 0

onready var active_player = get_node("Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	active_player = get_node("Player")
	$Player/Camera2D.current = true
	$HUD/StartMessage.self_modulate = Color(1,1,1,1)
	$HUD/StartScreen.self_modulate = Color(1,1,1,1)
	$HUD/StartScreen.show()
	get_tree().paused = true
#	spawn_goon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if event.is_action_pressed('ui_cancel'):
		print("GAME PAUSED")
		$HUD/Panel.show()
		get_tree().paused = true

func _on_GoonSpawner_timeout():
	spawn_goon()
	
func spawn_goon():
	$GoonLaugh.play()
	var new_goon = GOON.instance()
	new_goon.position = $GoonSpawn.position
	new_goon.target_player(get_node("Player"))
	add_child(new_goon)

func collect_evidence():
	$CollectSFX.play()
	evidence_count += 1
	$HUD/EvidenceCount.text = String(evidence_count)

func _on_StartingEvidence_collected():
	collect_evidence()
	print("GAME PAUSED")
	$HUD/Dialogue.show()
	get_tree().paused = true


func _on_Dialogue_start_game():
	$FightMusic.play()
	$GoonSpawner.start()
	spawn_goon()

func update_red_health():
	$HUD/HealthCount.text = String($Player.health)


func _on_Player_hit():
	update_red_health()


func _on_Player_die():
	print("GAME OVER")
	get_tree().paused = true
	var msg = "GAME OVER\n\n"
	msg += "You have been beaten by the mobsters,\n"
	msg += "but you were able to collect " + String(evidence_count)
	msg += "\npieces of evidence"
	msg += "\n\nPress SPACE to restart"
	$HUD/GameOver/SpaceInfo.text = msg
	$HUD/GameOver.show()

func start():
	get_tree().paused = false
	$HUD/StartScreen.hide()
	$HUD/StartMessage.show()
	$HUD/StartMessage/Timer.start()
	

func _on_BertaButton_pressed():
	$Player.PLAYER_COLOR = "blue"
	start()
func _on_RuthButton_pressed():
	$Player.PLAYER_COLOR = "red"
	start()
