extends Area3D

# Signal appelé lorsqu'un objet entre dans le deathplane
func _on_body_entered(body):
	if body.has_method("set_life"):  # Vérifie si 'life' est une propriété/méthode
		body.set_life(0)
