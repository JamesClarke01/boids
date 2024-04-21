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

func _physics_process(delta):	
	
	var force = seekForce()
	
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
	
