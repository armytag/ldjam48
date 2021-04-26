extends KinematicBody2D

var RUN_SPEED = 300
var JUMP_SPEED = -900
var GRAVITY = 1800
var MAX_HEALTH = 6

var velocity = Vector2()
var is_blocking = false
var is_punching = false
var health

signal punch
signal hit

export(String, "blue", "red") var PLAYER_COLOR

# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAX_HEALTH


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func get_input():
	velocity.x = 0

	if Input.is_action_pressed('p1_right'):
		velocity.x += RUN_SPEED
	if Input.is_action_pressed('p1_left'):
		velocity.x -= RUN_SPEED
	if Input.is_action_pressed("p1_punch"):
		if not is_punching:
			punch()
			emit_signal("punch")
		is_punching = true
	if is_punching:
		if is_on_floor():
			velocity.x = 0
	if Input.is_action_pressed("p1_down"):
		is_blocking = true
		if is_on_floor():
			velocity.x = 0
	else:
		is_blocking = false
		if Input.is_action_pressed('p1_up'):
			if is_on_floor():
				velocity.y = JUMP_SPEED

func _on_Sprite_animation_finished():
	is_punching = false

func _physics_process(delta):
	
	get_input()
	
	velocity.y += delta * GRAVITY
	if velocity.y < 0:
		set_collision_mask_bit(2, false)
	else:
		set_collision_mask_bit(2, true)
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if PLAYER_COLOR == "blue":
		if is_punching:
			$Sprite.animation = "blue-punch"
		elif is_blocking:
			$Sprite.animation = "blue-block"
		elif velocity.y < 0:
			$Sprite.animation = "blue-jump"
		elif velocity.y > 0:
			$Sprite.animation = "blue-falling"
		elif velocity.x == 0:
			$Sprite.animation = "blue-idle"
		else:
			$Sprite.animation = "blue-walk"
	elif PLAYER_COLOR == "red":
		if is_punching:
			$Sprite.animation = "red-punch"
		elif is_blocking:
			$Sprite.animation = "red-block"
		elif velocity.y < 0:
			$Sprite.animation = "red-jump"
		elif velocity.y > 0:
			$Sprite.animation = "red-falling"
		elif velocity.x == 0:
			$Sprite.animation = "red-idle"
		else:
			$Sprite.animation = "red-walk"
	
	if velocity.x > 0:
		$Sprite.flip_h = false
	elif velocity.x < 0:
		$Sprite.flip_h = true
	
	$Camera2D.zoom_in(position - $Camera2D.get_camera_position())

func punch():
	$PunchSFX.play()
	var bodies = $FistArea2D.get_overlapping_bodies()
	for body in bodies:
		if body.name == "Goon":
			body.take_damage(1)

func take_damage(damage):
	if not is_blocking:
		health -= damage
		print(health)
		$HitSFX.play()
		emit_signal('hit')
	if health <= 0:
		die()
func die():
	print("GAME OVER")
	get_tree().paused = true
	


