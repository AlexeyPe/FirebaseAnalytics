tool
extends Button
#class_name ButtonAuth, "res://addons/Firebase/Resources/sign-in4.png"
#class_name ButtonAuth, "res://addons/Firebase/Resources/Firebase.png"

export(Texture) var texture = load("res://addons/Firebase/Resources/Google.png") setget setTexture
export(Color) var colorButton = Color("ecebf0") setget setColorButton
export(Color) var colorText = Color("000000") setget setColorText
export(String) var textButton = "Sign In" setget setTextButton

func _enter_tree():
#	disabled = true
	rect_min_size[1] = 50
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	
	var styleNormal = StyleBoxFlat.new()
	set("custom_styles/normal", styleNormal) 
	set("custom_styles/focus", StyleBoxEmpty.new())
	set("custom_styles/pressed", styleNormal)
	set("custom_styles/hover", styleNormal)
	
	
	var borderRadius = 8
	get("custom_styles/normal").set("corner_radius_top_left", borderRadius)
	get("custom_styles/normal").set("corner_radius_top_right", borderRadius)
	get("custom_styles/normal").set("corner_radius_bottom_right", borderRadius)
	get("custom_styles/normal").set("corner_radius_bottom_left", borderRadius)
	
	if !has_node("ButtonAuthContent"):
		add_child(load("res://addons/Firebase/UI/ButtonAuthContent.tscn").instance())
		connect("pressed", self, "_on_ButtonAuth_pressed")
		Firebase.connect("getCurrentUserSignal", self, "on_getCurrentUserSignal")
	
	update()
	checkDisable()

func on_getCurrentUserSignal():
	checkDisable()

func checkDisable():
	if !Engine.has_singleton("AFirebase"): 
		disabled = true
		print("ButtonAuth.checkDisable() !Engine.has_singleton('AFirebase')")
		return
	if Firebase.firebase == null: 
		print("Firebase ButtonAuth %s init, Firebase.firebase == null")
		disabled = true
		return
	if Firebase.firebaseUser.isNull == null:
		print("Firebase ButtonAuth %s init, Firebase.firebaseUser.isNull == null (need call Firebase.getCurrentUser())")
		disabled = true
		return
	if Firebase.firebaseUser.isNull == false:
		print("Firebase ButtonAuth %s init, Firebase.firebaseUser.isNull != null (user logged)")
		disabled = true
		return
	disabled = false

func update():
	setTexture(texture)
	setColorText(colorText)
	setColorButton(colorButton)
	setTextButton(textButton)

func setTextButton(new):
	if !has_node("ButtonAuthContent/HBoxContainer/Label"): return
	$ButtonAuthContent/HBoxContainer/Label.text = new

func setColorText(new):
	colorText = new
	if !has_node("ButtonAuthContent/HBoxContainer/Label"):return
	$ButtonAuthContent/HBoxContainer/Label.set("custom_colors/font_color", new)

func setColorButton(new):
	colorButton = new
	if get("custom_styles/normal") == null: return
	get("custom_styles/normal").bg_color = colorButton

func setTexture(new):
	texture = new
	if !has_node("ButtonAuthContent/HBoxContainer/TextureRect"):return
	$ButtonAuthContent/HBoxContainer/TextureRect.texture = texture


func _on_ButtonAuth_pressed(): 
#	print("Firebase ButtonAuth _on_ButtonAuth_pressed")

	Firebase.authFirebaseUI()
