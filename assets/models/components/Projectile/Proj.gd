extends Node3D

@export var speed = 50.0  # Vitesse du projectile
@export var lifetime = 2.0  # Durée de vie en secondes
@export var damage = 1.0
var direction = Vector3.ZERO  # Direction de déplacement
var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Définir la direction initiale (vers l'avant de l'Area3D)
	direction = -transform.basis.z.normalized()
	$Area3D.get_child(random.randi_range(2, 7)).visible = true
	await get_tree().create_timer(lifetime).timeout  # Attend que le timer se termine
	queue_free()  # Détruire le projectile après un certain temps
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	# Déplacer l'Area3D
	transform.origin += direction * speed * delta
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	# Détruire le projectile si un corps est touché
	if body.is_in_group("car"):
		body.damage(damage)
		queue_free()
	pass # Replace with function body.
