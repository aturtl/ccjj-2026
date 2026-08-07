class_name Draggable extends Button

var original_click_pos: Vector2 = Vector2(0,0)
var before_pos: Vector2 = global_position

var button_was_down = false

var button_is_down = false

func bu():
	button_was_down = false
	button_is_down = false

func bd():
	if !button_was_down:
		original_click_pos = get_global_mouse_position()
		before_pos = global_position
		button_was_down = true
	button_is_down = true
	print("click")
	
	

func _ready():
	self.button_down.connect(bd)
	self.button_up.connect(bu)


func _physics_process(delta):
	if button_is_down:
		var offset = get_global_mouse_position() - original_click_pos
		global_position = before_pos + offset
		print("dragg")
