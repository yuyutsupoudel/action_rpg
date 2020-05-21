extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")#getting original scene

func effect():
	var grassEffect = GrassEffect.instance()#getting instance of original scene
	get_parent().add_child(grassEffect)#adding child to parent 
	grassEffect.global_position = global_position
	
func _on_HurtBox_area_entered(area):
	effect()
	queue_free()
