extends Area2D
const HitEffect = preload("res://Effects/HitEffect.tscn")
onready var timer = $Timer
onready var collisionShape =$CollisionShape2D
signal invincibility_started
signal invincibility_ended

var invincible = false setget set_invincible
func set_invincible(value):
	invincible = value
	#it wont call setter
	if invincible==true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
func create_hit_effect():
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position=global_position

func start_invincibility(durection):
	self.invincible= true
	timer.start(durection)

func _on_Timer_timeout():
	self.invincible = false
	#puting self will call setter


func _on_HurtBox_invincibility_started():
	collisionShape.set_deferred("disabled",true)


func _on_HurtBox_invincibility_ended():
	collisionShape.disabled = false
	
