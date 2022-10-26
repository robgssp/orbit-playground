extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var thrust = 5
var pitch_torque = 2
var roll_torque = 2
var yaw_torque = 2

var target_pitch = 1.5
var target_roll = 1.5
var target_yaw = 1.5

onready var heading_arrow: Spatial = $"HeadingArrow"
onready var velocity_arrow: Spatial = $"VelocityArrow"

var G = 1
var planet_mass = 5000

var last_total_energy = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func vec3_clamp_magnitude(vec: Vector3, minmax: Vector3):
	return Vector3(clamp(vec.x, -minmax.x, minmax.x),
				   clamp(vec.y, -minmax.y, minmax.y),
				   clamp(vec.z, -minmax.z, minmax.z))

func _physics_process(delta):
	pass

func controls(state):
	var forward = global_transform.basis.xform(Vector3(1, 0, 0))

	state.add_force(forward * thrust *
						(Input.get_action_strength("forward") -
						 Input.get_action_strength("backward"))
				   ,Vector3())

	var target_rots = Vector3((Input.get_action_strength("roll_right") -
							   Input.get_action_strength("roll_left")) *
							  target_pitch
							 ,(Input.get_action_strength("yaw_left") -
							   Input.get_action_strength("yaw_right")) *
							  target_roll
							 ,(Input.get_action_strength("pitch_up") -
							   Input.get_action_strength("pitch_down")) *
							  target_yaw)

	var current_rots = global_transform.basis.xform_inv(state.angular_velocity)
	var act_torques = vec3_clamp_magnitude(
		(target_rots - current_rots) * 40,
		Vector3(roll_torque, yaw_torque, pitch_torque))

	state.add_torque(get_global_transform().basis.xform(act_torques))

func gravity_from(position: Vector3):
	var g_mag = mass * planet_mass * G
	var ps = $"../Planet".global_transform.origin - position
	return g_mag/(ps.dot(ps)) * ps.normalized()

func gravity_rk4(state):
	var mass = 1 / state.inverse_mass
	var pos1 = global_transform.origin
	var momentum = state.linear_velocity * mass
	var delta = state.step
	var k1 = gravity_from(pos1)
	var pos2 = pos1 + ((momentum + k1) / mass * delta / 2)
	var k2 = gravity_from(pos2)
	var pos3 = pos1 + ((momentum + k2) / mass * delta / 2)
	var k3 = gravity_from(pos3)
	var pos4 = pos1 + ((momentum + k3) / mass * delta)
	var k4 = gravity_from(pos4)

	var fg = (k1 + k2*2 + k3*2 + k4)/6
	state.add_central_force(fg)

func gravity_basic(state):
	state.add_central_force(gravity_from(global_transform.origin))

func _integrate_forces(state):
	track_energy(state)
	gravity_basic(state)
	controls(state)

func track_energy(state):
	var vel = state.linear_velocity

	var pe = -(G * mass * planet_mass) / \
		($"../Planet".global_transform.origin - global_transform.origin).length()
	var ke = mass * vel.length_squared() / 2
	var rots = global_transform.basis.xform_inv(angular_velocity)
	$"../Diagnostic".text = """Potential energy: %s
	kinetic energy: %s
	total energy: %s
	energy gain: %s
	rotations: %s %s %s""" % [pe, ke, pe + ke, (pe + ke - last_total_energy) / state.step
							 ,rots.x, rots.y, rots.z]

	last_total_energy = pe + ke

func _drop_breadcrumb():
	var crumb = preload("res://breadcrumb.tscn").instance().duplicate()

	crumb.translate($Rear.global_transform.origin)
	get_parent().add_child(crumb)

func _process(delta):
	heading_arrow.scale = Vector3(2, 1, 1)

	var vel = linear_velocity
	var forward = global_transform.basis.xform(Vector3(1,0,0))
	var up = global_transform.basis.xform(Vector3(0,1,0))
	var right = global_transform.basis.xform(Vector3(0,0,1))
	var a2 = forward.signed_angle_to(vel - vel.project(up), up)
	var azimuthed = forward.rotated(up, a2)
	var elevation_axis = right.rotated(up, a2)
	var a3 = azimuthed.signed_angle_to(vel - vel.project(elevation_axis), elevation_axis)

	#var a3 = 0
	velocity_arrow.scale = Vector3(linear_velocity.length()/5, 1, 1)
	velocity_arrow.rotation = Vector3(0, 0, 0)
	velocity_arrow.rotate_z(a3)
	velocity_arrow.rotate_y(a2)
