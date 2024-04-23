extends CharacterBody3D

@export var mass = 1
@export var vel: Vector3 = Vector3.ZERO
@export var force: Vector3 = Vector3.ZERO
@export var acceleration: Vector3 = Vector3.ZERO
@export var speed: float
@export var max_speed: float = 10.0
@export var max_force: float = 10.0

var target = null


func _ready():
	target = $"../target"

func seekForce():	
	var toTarget = target.global_transform.origin - global_transform.origin #get vector to target
	toTarget = toTarget.normalized() #normalise
	var desired = toTarget * max_speed #scale to max speed
	return desired - vel #return steering vector to target

func arriveForce():
	var slowingDistance = 40
	var toTarget = target.global_transform.origin - global_transform.origin #get vector to target
	var dist = toTarget.length() #get distance to target
	
	if dist < 2: #if distance is less than 2, stop
		return Vector3.ZERO
		
	var rampedSpeed = (dist / slowingDistance) * max_speed #sets speed based on ratio between dist and slowingDistance, scaled to max_speed
	
	var limitedSpeed = min(max_speed, rampedSpeed) #Limit speed
	var desired = (toTarget * limitedSpeed) / dist #desired velcity vector to get to target
	return desired - vel #returns steering force

func applyBoidForce(delta):
	#var force = seekForce()
	var force = arriveForce()
	
	
	DebugDraw3D.draw_arrow(global_transform.origin,  force, Color(0, 1, 0), 0.1)
	
	#check if vector is 0
	if is_nan(force.x) or is_nan(force.y) or is_nan(force.z): 
		force = Vector3.ZERO
	
	#limit force
	if force.length() > max_force:
		force = force.limit_length(max_force)
	
	acceleration = force/mass
	
	vel += acceleration * delta #multiply acceleration by delta (time since last frame) to account for inconsistent framerate
	
	speed = vel.length()
	
	if speed > 0:
		vel = vel.limit_length(max_speed)
		
		set_velocity(vel)
		move_and_slide()

func drawGizmos():
	DebugDraw3D.draw_arrow(global_transform.origin, vel, Color(0, 0, 1), 0.1)


func _physics_process(delta):	
	applyBoidForce(delta)
	drawGizmos()
	
