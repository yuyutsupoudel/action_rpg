extends KinematicBody2D
var knockback = Vector2.ZERO
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WonderController
onready var animationplayer = $AnimationPlayer
export  var ACCLERATION = 200
export var MAX_SPEED = 60
export var FRACTION = 70
export var WANDER_TARGET_ZONE = 4
func _ready():
	state = pick_random_state([IDLE,WANDER])

const DeathEffect = preload("res://Effects/DeathEffect.tscn")
enum{
	IDLE,
	WANDER,
	CHASE
}
var velocity = Vector2.ZERO
var state = IDLE
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO,FRACTION*delta)
	knockback= move_and_slide(knockback)
	match state:
		IDLE:
			
			velocity = velocity.move_toward(Vector2.ZERO,FRACTION*delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
				
		WANDER:
			
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			
			acclerate_towards_point(wanderController.target_position,delta)

			if global_position.distance_to(wanderController.target_position) <=WANDER_TARGET_ZONE:
				update_wander()
		CHASE:
			var player = playerDetectionZone.player
			if player !=null:
				acclerate_towards_point(player.global_position,delta)
				
			else:
				state = IDLE
			if softCollision.is_colliding():#it will make two enimy to move from eachother if they come toward eachother
				velocity += softCollision.get_push_vector()*delta*400
	velocity = move_and_slide(velocity)
func update_wander():
	state = pick_random_state([IDLE,WANDER])
	wanderController.start_wonder_timer(rand_range(1,3))
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func acclerate_towards_point(point,delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction*MAX_SPEED,ACCLERATION*delta)
	sprite.flip_h = velocity.x<0
	
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
	
func _on_HurtBox_area_entered(area):
	knockback = area.knockback_vector*120
	stats.health-=area.damage
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.3)

func _on_Stats_no_health():
	queue_free()
	var deathEffect = DeathEffect.instance()
	get_parent().add_child(deathEffect)
	deathEffect.position = global_position
	
	


func _on_HurtBox_invincibility_started():
	animationplayer.play("start")


func _on_HurtBox_invincibility_ended():
	animationplayer.play("stop")
