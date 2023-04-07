tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("Firebase", "res://addons/Firebase/Scripts/Firebase.gd")
	pass


func _exit_tree():
	remove_autoload_singleton("Firebase")
	pass
