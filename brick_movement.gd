extends KinematicBody2D

# Class controlling the player

# Movement Constants
const GRAVITY = 2600.0 #5200
const FLOOR_ANGLE = 40
const WALK_FORCE = 1000.0
const WALK_MIN = 80
const WALK_MAX = 200.0
const SPRINT_MIN = 180.0
const SPRINT_MAX = 400.0
const STOP_FORCE = 1000 #5200
const STOP_COEFF = 0.65
const MAX_JUMP = 0.1 #.08
const JUMP_VEL = 800.0 #1000
const MAX_AIR = 0.1

# Variables
# Movement
var velocity = Vector2()
var jumping = false
var can_jump = true
var can_sprint = true
var falling = false
export var mining = false
var can_mine = true
var air_time = 100
var jump_timer
# Input
var walk_left
var walk_right
var walk_up
var walk_down
var jump
var mine
var sprint
# Spritework
var anim
var sprite
var sees_left = false
var top_sprite
var bot_sprite
var effects
export var need_synchro = false
#var dust = preload("res://scenes/dust.scn")
var landed = false
var stopped = false
# Death
var dead = false
# GUI
var controller

func _ready():
	jump_timer = get_node("Jump")
	jump_timer.set_wait_time(MAX_JUMP)
	controller = get_node("/root/Controller")
	controller.cam_target = self
	sprite = get_node("Sprite")
	anim = get_node("Anim")
	set_fixed_process(true)

		
func _fixed_process(delta):
	walk_left = Input.is_action_pressed("ui_left")
	walk_right = Input.is_action_pressed("ui_right")
	walk_up = Input.is_action_pressed("ui_up")
	walk_down = Input.is_action_pressed("ui_down")
	jump = Input.is_action_pressed("ui_jump")
	mine = Input.is_action_pressed("ui_mine")
	sprint = Input.is_action_pressed("ui_sprint")
	if (not dead):
		_movement(delta)
		
func _movement(delta):
	# gravity
	var force = Vector2(0,GRAVITY)
	
	# stop by default, inertia
	var stop = true
	
	# check if we are sprinting
	var MAX_X_VEL = WALK_MAX
	if (sprint):
		MAX_X_VEL = SPRINT_MAX
#	print("V1:" + str(velocity.x) + " F:" + str(force.x))
	# Sideways movement
	if (walk_left and not walk_right):
		if (velocity.x<=WALK_MIN and velocity.x > -MAX_X_VEL):
			force.x-=WALK_FORCE
			stop = false
			stopped = false
			if (anim.get_current_animation() != "run" and !jumping && !falling):
				anim.play("run")
		else:
			force.x = -WALK_FORCE * STOP_COEFF
	elif (walk_right and not walk_left):
		if (velocity.x>=-WALK_MIN and velocity.x < MAX_X_VEL):
			force.x+=WALK_FORCE
			stop = false
			stopped = false
			if (anim.get_current_animation() != "run" and !jumping && !falling):
				anim.play("run")
		else:
			force.x = WALK_FORCE * STOP_COEFF
	
	# if the player got no movement, he'll slow down with inertia.
	if (stop):
		stop(delta)
		
#	print("V2:" + str(velocity.x) + " F:" + str(force.x))
	# calculate motion
	velocity += force * delta
	var motion = velocity * delta
#	motion = Vector2(round(motion.x),round(motion.y))
	motion = move(motion)
	# print("F:"+str(falling)+" J:"+str(jumping))
	# because the first move would stop if there's a collision, we recalculate the movement to slide along the colliding object.
	if (is_colliding()):
		#ran against something, is it the floor? get normal
		var n = get_collision_normal()
		
		if ( rad2deg(acos(n.dot( Vector2(0,-1)))) < FLOOR_ANGLE ):
			#if angle to the "up" vectors is < angle tolerance
			#char is on floor
			air_time=0
			falling = false
			if (not landed):
#				create_dust("Land")
#				sfx.play("step")
				landed = true
			

		# But we were moving and our motion was interrupted, 
		# so try to complete the motion by "sliding"
		# by the normal
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		
		#then move again
		move(motion)

	air_time+=delta
	
	if (jumping and velocity.y>=0):
		falling = true
		jumping=false
		
	if (velocity.y > 0 and air_time > MAX_AIR):
		falling = true
	
#	if (velocity.y < 0 and bot_sprite.get_current_animation() != "Jump"):
#		bot_sprite.play("Jump")
#		if (!attacking):
#			top_sprite.play("Jump")
#
#	if (falling and bot_sprite.get_current_animation() != "Fall"):
#		bot_sprite.play("Fall")
#		if (!attacking):
#			top_sprite.play("Fall")

	# Manage jumping
	if (!jump):
		can_jump = true
	elif (not jumping and can_jump and jump and not falling):
		can_jump = false
#		sfx.play("jump")
#		create_dust("Jump")
#		if (not is_attacking()):
#			top_sprite.play("Jump")
		anim.play("jumping")
		jumping=true
		jump_timer.start()
		velocity.y = -JUMP_VEL
		

		
	# Manage sprite mirroring
	if (velocity.x>0):
		sees_left = false
	elif (velocity.x<0):
		sees_left = true
	if (sees_left):
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)

func stop(delta):
	var vsign = sign(velocity.x)
	var vx = abs(velocity.x)
	vx -= STOP_FORCE * delta
	if (vx<0):
		vx=0
		if (!jumping && !falling):
			if (not stopped and not jumping and not falling):
#				create_dust("Brake")
				stopped = true
			anim.play("idle")
	velocity.x=vx*vsign
	
func _on_jump_timerout():
	if (jump):
		velocity.y = -JUMP_VEL

