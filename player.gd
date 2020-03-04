extends Spatial

var camera
var character
var direction = Vector3()
var velocity = Vector3()

var view = {
	"tpv_camera_speed": 0.001,
	"tpv_x":0,
	"tpv_y":1,
	"tpv_yheight":1,
	"tpv_radio":4,
	"tpv_radio_max":8,
	"tpv_radio_min":3.5,
}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	character = $character
	camera = $Camera
	camera.current = true
	camera.far = 700

func _physics_process(delta):
	
	if Input.is_key_pressed(KEY_ENTER) or Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		return
	
	var target = character.global_transform.origin
	if target.y < view.tpv_yheight:
		view.tpv_yheight -= (view.tpv_yheight-target.y) * 0.1
	elif target.y > view.tpv_yheight:
		view.tpv_yheight += (target.y-view.tpv_yheight) * 0.1
	var r = Vector3(target.x+cos(view.tpv_x)*view.tpv_radio, view.tpv_yheight+view.tpv_y, target.z+sin(view.tpv_x)*view.tpv_radio)

	camera.look_at_from_position(r,target,Vector3(0,1,0))
	walk(delta)

func walk(delta):
	direction = Vector3()
	var aim = camera.get_global_transform().basis
	var jump = false

	if Input.is_key_pressed(KEY_W):
		direction -= aim.z
	if Input.is_key_pressed(KEY_S):
		direction += aim.z
	if Input.is_key_pressed(KEY_A):
		direction -= aim.x
	if Input.is_key_pressed(KEY_D):
		direction += aim.x
	if Input.is_key_pressed(KEY_SPACE):
		jump = true
		
	direction = direction.normalized()
#gravity
	velocity.y -= 20 * delta

	var on_ground = character.is_on_floor()
	
	if jump and on_ground:
		velocity.y = 10
	elif on_ground:
		velocity.y = 0
	
	#adjust velocity
	var v = velocity.linear_interpolate(direction * 10,10 * delta)
	velocity = Vector3(v.x,velocity.y,v.z)
	
	character.move_and_slide(velocity,Vector3(0,1,0))
	if direction != Vector3():
		rotating(direction)

func _input(event):
	if event is InputEventMouseMotion:
		#add camera side value
		view.tpv_x += event.relative.x * view.tpv_camera_speed
		#add camera height value
		var y = view.tpv_y + (event.relative.y * view.tpv_camera_speed*10)
		if y > 1 and y < 5: # min/max height
			view.tpv_y = y
	elif event is InputEventMouseButton:
		#distance to the player
		if event.button_index == BUTTON_WHEEL_DOWN and view.tpv_radio+0.1 < view.tpv_radio_max:
			view.tpv_radio += 0.1
		elif event.button_index == BUTTON_WHEEL_UP and view.tpv_radio-0.1 > view.tpv_radio_min:
			view.tpv_radio -= 0.1

func rotating(dir,set = false):
	if set:
		character.rotation.y = atan2(dir.x* -1, dir.z* -1)
		return
	var a  = atan2(dir.x* -1, dir.z* -1)
	var rot = character.get_rotation()
	if abs(rot.y-a) > PI:
		var m = PI * 2
		var d = fmod(a-rot.y,m)
		a = rot.y + (fmod(2 * d,m)-d)*0.2
	else:
		a = lerp(rot.y,a,0.1)
	character.rotation.y = a
