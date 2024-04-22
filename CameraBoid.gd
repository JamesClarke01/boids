extends CharacterBody3D

var boid

func _ready():
	boid = get_tree().current_scene.find_child("Boid")

func _physics_process(delta):	
	var desired = global_transform.looking_at(boid.global_transform.origin, Vector3.UP)		
	self.global_transform.basis = global_transform.basis.slerp(desired.basis, delta * 2).orthonormalized()
