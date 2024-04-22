extends CharacterBody3D

var boid

# Boid vars
@export var mass = 1
@export var vel: Vector3 = Vector3.ZERO
@export var force: Vector3 = Vector3.ZERO
@export var acceleration: Vector3 = Vector3.ZERO
@export var speed: float
@export var max_speed: float = 10.0
@export var max_force: float = 10.0

# Persue vars
var leader_offset:Vector3
var world_target:Vector3
var projected:Vector3
var slowingDistance = 30

func _ready():
	boid = get_tree().current_scene.find_child("Boid")
	calculateOffset()

func lookAtBoid(delta):
	var desired = global_transform.looking_at(boid.global_transform.origin, Vector3.UP)  #Get the desired orientation
	self.global_transform.basis = global_transform.basis.slerp(desired.basis, delta * 2).orthonormalized() #slerp to orientation

func calculateOffset():
	leader_offset = global_transform.origin - boid.global_transform.origin
	leader_offset = (leader_offset) * boid.global_transform.basis	

func calcPersueForce():
	
	world_target = boid.global_transform  * leader_offset #Get target by adding boid position & offset
	
	var dist = boid.global_transform.origin.distance_to(world_target) #Get distance from boid to target
	
	var time = dist / boid.max_speed #get time to reach boid (t = d/s)
	
	var distBoidWillMove = boid.velocity * time #Distance = s * t
	
	projected = world_target + distBoidWillMove #Get projected position boid will be at
		
	var toTarget = projected - global_transform.origin #Get vector to the target
	
	dist = toTarget.length() # Get new length of vector
	
	if dist < 2: #This will make the boid stop when its close to the target
		return Vector3.ZERO
	
	var rampedSpeed = (dist / slowingDistance) * max_speed #Calculate a speed based on the distance and slowing distance
	
	var limitedSpeed = min(max_speed, rampedSpeed) #Don't exeed boids max speed
	
	var desiredVelocity = (toTarget * limitedSpeed) / dist #Desired velocity vector to get to target
	
	return desiredVelocity - vel #return steering force needed to reach desired velocity

func applyBoidForce(delta):
	var force = calcPersueForce()
	
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

func _physics_process(delta):
	lookAtBoid(delta)
	applyBoidForce(delta)

