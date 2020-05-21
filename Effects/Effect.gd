extends AnimatedSprite
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	self.connect("animation_finished",self,"_on_animation_finished")
	#if Input.is_action_just_pressed("Attack"):
	play("Animate")



func _on_animation_finished():
	queue_free()

