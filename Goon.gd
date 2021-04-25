extends KinematicBody2D

var RUN_SPEED = 250
var JUMP_SPEED = -800
var GRAVITY = 1800
var REACT_TIME = 200
var PUNCH_DELAY = 800
var FOLLOW_MARGIN = 60
var MAX_HEALTH = 3

var velocity = Vector2()
var dir = 0
var next_dir = 0
var next_dir_time = 0
var next_jump_time = -1
var next_punch_time = -1
var next_block_time = -1
var is_winding = false
var is_punching = false
var is_blocking = false
var target = null
var health

# Called when the node enters the scene tree for the first time.
func _ready():
	health = MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func target_player(player):
	target = player

func set_dir(target_dir):
	if next_dir != target_dir:
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + REACT_TIME

func choose_action():
	if target != null:
		if target.position.x < position.x - FOLLOW_MARGIN:
			set_dir(-1)
		elif target.position.x > position.x + FOLLOW_MARGIN:
			set_dir(1)
		else:
			set_dir(0)
			if next_punch_time < 0:
				next_punch_time = OS.get_ticks_msec() + (randi()%1500/health + 2000)
			if next_block_time < 0:
				next_block_time = OS.get_ticks_msec() + (randi()%500*health + 2000)
	
	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir

	if next_block_time > 0 and OS.get_ticks_msec() > next_block_time:
		is_blocking = true
		next_block_time = -1

	if next_punch_time > 0 and OS.get_ticks_msec() > next_punch_time:
		if OS.get_ticks_msec() > next_punch_time + PUNCH_DELAY:
			is_punching = true
			is_winding = false
			punch()
			next_punch_time = -1
		else:
			is_punching = false
			is_winding = true
		is_blocking = false

	if next_jump_time > 0 and OS.get_ticks_msec() > next_jump_time and is_on_floor():
		if target.position.y < position.y - 60:
			velocity.y = JUMP_SPEED
		next_jump_time = -1
	
	if target.position.y < position.y - 60 and next_jump_time < 0:
		next_jump_time = OS.get_ticks_msec() + REACT_TIME

func _on_Sprite_animation_finished():
	is_punching = false
	
func point_towards_target():
	if target.position.x > position.x:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

func _physics_process(delta):
	
	choose_action()
	
	velocity.x = dir * RUN_SPEED
	velocity.y += delta * GRAVITY
	if velocity.y < 0:
		set_collision_mask_bit(2, false)
	else:
		set_collision_mask_bit(2, true)
	velocity = move_and_slide(velocity, Vector2(0,-1))
	
	if is_winding:
		$Sprite.animation = "winding"
	elif is_punching:
		$Sprite.animation = "punch"
	elif is_blocking:
		$Sprite.animation = "block"
	elif velocity.y < -0:
		$Sprite.animation = "jump"
	elif velocity.y > 0:
		$Sprite.animation = "falling"
	elif velocity.x == 0:
		$Sprite.animation = "idle"
	else:
		$Sprite.animation = "walk"
	
	point_towards_target()
	
	if velocity.x > 0:
		$Sprite.flip_h = false
	elif velocity.x < 0:
		$Sprite.flip_h = true

func punch():
	var distance = target.position.distance_to(position)
	if distance < FOLLOW_MARGIN:
		target.take_damage(1)

func take_damage(damage):
	if not is_blocking:
		health -= damage
	if health <= 0:
		die()
func die():
	print("AAAAGGHHH!!!")
	queue_free()
