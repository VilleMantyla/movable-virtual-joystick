extends KinematicBody

const ZERO = Vector3(0,0,0)
const MESH_ROT = deg2rad(90)

enum {IDLE, WALK}
var state

export var walk_speed = 3.0
var touch_factor = 0.018 #0.018 feels good (screen_size.x*0.018)

var screen_size
var stick

var input_direction = ZERO

var touch_start = null
var touch_position = null

func _ready():
	screen_size = OS.get_screen_size()
	stick = get_node("Stick")
	
	_ready_camera()
	
	state = IDLE

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("mouse_left"):
			touch_start = get_viewport().get_mouse_position()
		elif event.is_action_released("mouse_left"):
			touch_start = null
	elif event is InputEventMouseMotion:
		touch_position = get_viewport().get_mouse_position()

func _process(delta):
	if state == IDLE:
		if touch_start:
			state = WALK
	elif state == WALK:
		walk()
		cam_follow_player()

#WALK STATE
func walk():
	if touch_start:
		stick.show()
		stick.set_position(touch_start)
		if touch_start.distance_to(touch_position) > screen_size.x*touch_factor:
			var dir2 = (touch_position-touch_start).normalized()
			input_direction = Vector3(dir2.x, 0, dir2.y)
			
			var spin = Vector3()
			spin.y =  -1.0*atan2(input_direction.z, input_direction.x) + MESH_ROT
			rotation = spin
	else:
		stick.hide()
		input_direction = ZERO
		state = IDLE

func _physics_process(delta):
	move_and_slide(input_direction*walk_speed, Vector3(0,1,0))

############
## CAMERA ##
############
var camera
var offset

func _ready_camera():
	camera = get_parent().get_node("Camera")
	offset =  camera.global_transform.origin-global_transform.origin

func cam_follow_player():
	var coords = translation+offset
	camera.translation = coords
