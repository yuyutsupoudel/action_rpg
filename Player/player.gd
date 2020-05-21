extends KinematicBody2D
const MAX_SPEED = 70
const FRICTION = 600
const ACCELERATION = 7000
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var roll_speed  = 90
var state = MOVE
var stats = PlayerStats
onready var hurtbox = $HurtBox
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = $AnimationTree.get("parameters/playback")
onready var sordHitbox = $HitboxPivod/SordHitbox
onready var blinkAnimationPlayer = $BlinkAnimation

enum{
	MOVE,
	ROLL,
	ATTACK
}

func _ready():
	randomize()
	#it will randomize all function of game
	#here it is used to randomize bat wonder position for two games
	stats.connect("no_health",self,"queue_free")
	#oblect that has signal.connect("signal",object that has function,"function that we are connecting to")
	animationTree.active = true
	sordHitbox.knockback_vector = roll_vector
func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()

func move_state(delta):
	#getting Direction
	var input_vector = Vector2.ZERO
	input_vector.x=Input.get_action_strength("ui_right")-Input.get_action_strength("ui_left")
	input_vector.y=Input.get_action_strength("ui_down")-Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		sordHitbox.knockback_vector = input_vector
		sordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position",input_vector)
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(MAX_SPEED*input_vector,ACCELERATION*delta)

	else:
		velocity = velocity.move_toward(Vector2.ZERO,FRICTION*delta)
		animationState.travel("Idle")
	move()
	
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
	if Input.is_action_just_pressed("Roll"):
		state = ROLL

func roll_state():
	velocity = roll_vector*roll_speed
	animationState.travel("Roll")
	move()

func attack_state():
	#velocity = Vector2.ZERO
	animationState.travel("Attack")

func attack_animation_finished():
	state  = MOVE

func roll_animation_finished():
	velocity = velocity/2
	state = MOVE

func move():
	velocity = move_and_slide(velocity)

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.6)
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)


func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start");


func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
