extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var ship: RigidBody = $"../Ship"
onready var camera: Camera = $"../Ship/ShipCamera"

var hud_green: Color = Color(0, 255, 0)

func vec_to_screen(vec: Vector3):
	var vec_mod = vec + camera.global_transform.origin
	
	if camera.is_position_behind(vec_mod):
		return null
	else:
		return camera.unproject_position(vec_mod)

var waterline_points = [Vector2(-15, 0),
						Vector2(-10,0),
						Vector2(-5,-5),
						Vector2(0,5),
						Vector2(5,-5),
						Vector2(10,0),
						Vector2(15,0)]

func draw_waterline(pos: Vector2):
	for i in range(1,len(waterline_points)):
		draw_line(pos + waterline_points[i-1], 
				  pos + waterline_points[i], hud_green, 3, true)
				
func draw_velvec(pos: Vector2):
	draw_arc(pos, 15, 0, 2*PI, 20, hud_green, 5, true)
	draw_line(pos+Vector2(0,-15), pos+Vector2(0, -30), hud_green, 5, true)
	draw_line(pos+Vector2(15, 0), pos+Vector2(30, 0), hud_green, 5, true)
	draw_line(pos+Vector2(-15, 0), pos+Vector2(-30, 0), hud_green, 5, true)

func _draw():
	var heading = ship.global_transform.basis.xform(Vector3(1,0,0))
	var heading_coords = vec_to_screen(heading)
	
	$"../Debug".text = """Heading: %s
	Screen point: %s""" % [heading, heading_coords]
	
	draw_waterline(heading_coords)
	var vv_coords = vec_to_screen($"../Ship".linear_velocity)
	if vv_coords:
		draw_velvec(vv_coords)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
