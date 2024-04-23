extends Marker3D

@export var radius = 20

func random_point_in_unit_sphere() -> Vector3:
	var theta = randf_range(0, 2 * PI)
	var phi = randf_range(0, PI)
	var r = pow(randf_range(0, 1), 1.0/3.0)  # Cube root for uniform distribution

	var x = r * sin(phi) * cos(theta)
	var y = r * sin(phi) * sin(theta)
	var z = r * cos(phi)
	return Vector3(x, y, z)

#This function called by timer at a set interval
func moveTarget():
	global_transform.origin = random_point_in_unit_sphere() * radius
	 
# Called when the node enters the scene tree for the first time.
func _ready():
	moveTarget()
	
func _on_timer_timeout():
	moveTarget()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	DebugDraw3D.draw_sphere(global_position, 0.5, Color(1,0,0))
	



