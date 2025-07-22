extends Area2D
class_name DragonProjectile

# Propriedades do projétil
var direction: Vector2
var speed: float = 400.0
var damage: float = 0.0
var attacker = null
var attacker_dragon = null  # Referência direta ao dragão atacante
var lifetime: float = 5.0
var current_lifetime: float = 0.0

# Estado do projétil
var is_destroyed: bool = false
var has_hit_target: bool = false

# Referências aos nós (usando get_node para maior segurança)
var sprite: Sprite
var collision: CollisionShape2D

# Lista de alvos já atingidos (evita hits múltiplos)
var hit_targets: Array = []

func _ready():
	"""Inicialização segura do projétil"""
	
	# Busca componentes de forma segura
	sprite = get_node_or_null("Sprite")
	collision = get_node_or_null("CollisionShape2D")
	
	# Se não encontrou os nós, cria uns básicos
	if not sprite:
		create_default_sprite()
	
	if not collision:
		create_default_collision()
	
	# Conecta sinais de forma segura
	if not is_connected("body_entered", self, "_on_body_entered"):
		connect("body_entered", self, "_on_body_entered")
	
	if not is_connected("area_entered", self, "_on_area_entered"):
		connect("area_entered", self, "_on_area_entered")
	
	# Adiciona ao grupo de projéteis para fácil limpeza
	add_to_group("projectiles")
	
	print("Projétil criado e inicializado")

func create_default_sprite():
	"""Cria sprite padrão se não existir"""
	
	sprite = Sprite.new()
	sprite.name = "Sprite"
	
	# Cria uma textura simples (círculo vermelho)
	var texture = ImageTexture.new()
	var image = Image.new()
	image.create(16, 16, false, Image.FORMAT_RGB8)
	image.fill(Color.red)
	texture.create_from_image(image)
	
	sprite.texture = texture
	add_child(sprite)

func create_default_collision():
	"""Cria colisão padrão se não existir"""
	
	collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	
	var shape = CircleShape2D.new()
	shape.radius = 8.0
	collision.shape = shape
	
	add_child(collision)

func setup(proj_direction: Vector2, proj_damage: float, proj_attacker):
	"""Configura o projétil de forma segura"""
	
	# Validações de entrada
	if proj_direction == Vector2.ZERO:
		print("AVISO: Direção do projétil é zero!")
		proj_direction = Vector2.RIGHT  # Direção padrão
	
	direction = proj_direction.normalized()
	damage = max(0.0, proj_damage)  # Garante que damage não seja negativo
	attacker = proj_attacker
	
	# Tenta extrair referência ao dragão de forma segura
	if attacker:
		if attacker.has_method("get") and attacker.get("dragon"):
			attacker_dragon = attacker.dragon
		elif attacker.get_script() and attacker.get_script().get_path().find("Dragon") != -1:
			attacker_dragon = attacker
		elif attacker.get_parent() and attacker.get_parent().get_script():
			var parent_script = attacker.get_parent().get_script().get_path()
			if parent_script.find("Dragon") != -1:
				attacker_dragon = attacker.get_parent()
	
	# Rotaciona visual baseado na direção
	if direction != Vector2.ZERO and sprite:
		sprite.rotation = direction.angle()
		rotation = direction.angle()
	
	print("Projétil configurado - Direção: ", direction, " | Dano: ", damage, " | Atacante: ", attacker)

func _physics_process(delta):
	"""Atualização física segura"""
	
	if is_destroyed:
		return
	
	# Move o projétil
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta
	
	# Controla tempo de vida
	current_lifetime += delta
	if current_lifetime >= lifetime:
		destroy_projectile("tempo_vida")
		return
	
	# Verifica se saiu muito longe da tela (cleanup de segurança)
	check_screen_bounds()
	
	# Verifica se o atacante ainda existe
	check_attacker_validity()

func check_screen_bounds():
	"""Verifica se o projétil saiu muito longe da tela"""
	
	var viewport_size = get_viewport().size if get_viewport() else Vector2(1024, 600)
	var screen_buffer = 500.0  # Margem de segurança
	
	if abs(global_position.x) > viewport_size.x + screen_buffer or \
	   abs(global_position.y) > viewport_size.y + screen_buffer:
		destroy_projectile("fora_da_tela")

func check_attacker_validity():
	"""Verifica se o atacante ainda é válido"""
	
	if attacker and not is_instance_valid(attacker):
		print("Atacante do projétil não é mais válido, limpando referência")
		attacker = null
	
	if attacker_dragon and not is_instance_valid(attacker_dragon):
		print("Dragão atacante não é mais válido, limpando referência")
		attacker_dragon = null

func _on_body_entered(body):
	"""Colisão com corpo - versão robusta"""
	
	if is_destroyed or has_hit_target:
		return
	
	if not is_instance_valid(body):
		print("Corpo não é válido, ignorando colisão")
		return
	
	# Evita atingir o próprio atacante
	if is_same_attacker(body):
		return
	
	# Evita hits múltiplos no mesmo alvo
	if hit_targets.has(body):
		return
	
	# Verifica se é um alvo válido
	if is_valid_target(body):
		hit_target(body)
	else:
		# Colidiu com obstáculo ou terreno
		destroy_projectile("obstaculo")

func _on_area_entered(area):
	"""Colisão com área - versão robusta"""
	
	if is_destroyed or has_hit_target:
		return
	
	if not is_instance_valid(area):
		print("Área não é válida, ignorando colisão")
		return
	
	var area_owner = area.get_parent()
	
	if not is_instance_valid(area_owner):
		return
	
	# Evita atingir o próprio atacante
	if is_same_attacker(area_owner):
		return
	
	# Evita hits múltiplos
	if hit_targets.has(area_owner):
		return
	
	if is_valid_target(area_owner):
		hit_target(area_owner)
	else:
		destroy_projectile("area_obstaculo")

func is_same_attacker(target) -> bool:
	"""Verifica se o alvo é o próprio atacante"""
	
	if target == attacker or target == attacker_dragon:
		return true
	
	# Verifica se é parte do mesmo dragão
	if attacker_dragon and target.get_parent() == attacker_dragon:
		return true
	
	if attacker and target.get_parent() == attacker:
		return true
	
	return false

func is_valid_target(target) -> bool:
	"""Verifica se é um alvo válido para dano"""
	
	if not is_instance_valid(target):
		return false
	
	# Verifica se tem stats (é um dragão)
	if target.has_method("get") and target.get("stats"):
		return true
	
	# Verifica se tem método take_damage diretamente
	if target.has_method("take_damage"):
		return true
	
	# Verifica se o parent tem stats
	var parent = target.get_parent()
	if parent and is_instance_valid(parent):
		if parent.has_method("get") and parent.get("stats"):
			return true
		if parent.has_method("take_damage"):
			return true
	
	return false

func hit_target(target):
	"""Aplica dano ao alvo de forma segura"""
	
	if is_destroyed or has_hit_target:
		return
	
	if not is_instance_valid(target):
		print("Alvo não é mais válido!")
		destroy_projectile("alvo_invalido")
		return
	
	# Marca que atingiu um alvo
	has_hit_target = true
	hit_targets.append(target)
	
	print("=== PROJÉTIL ATINGIU ALVO ===")
	
	# Informações do atacante
	var attacker_name = "Desconhecido"
	if attacker and is_instance_valid(attacker):
		if attacker.has_method("get") and attacker.get("stats"):
			attacker_name = attacker.stats.dragon_name
		elif attacker.has_method("get") and attacker.get("dragon_name"):
			attacker_name = attacker.dragon_name
	elif attacker_dragon and is_instance_valid(attacker_dragon):
		if attacker_dragon.has_method("get") and attacker_dragon.get("stats"):
			attacker_name = attacker_dragon.stats.dragon_name
	
	# Informações do alvo
	var target_name = "Desconhecido"
	if target.has_method("get") and target.get("stats") and target.stats:
		target_name = target.stats.dragon_name
	elif target.has_method("get") and target.get("dragon_name"):
		target_name = target.dragon_name
	else:
		target_name = target.name
	
	print(attacker_name, " atingiu ", target_name, " com projétil!")
	print("Dano do projétil: ", damage)
	
	# Aplica dano de forma segura
	var damage_applied = false
	
	if target.has_method("take_damage"):
		target.take_damage(damage)
		damage_applied = true
	elif target.has_method("get") and target.get("stats") and target.stats.has_method("take_damage"):
		target.stats.take_damage(damage)
		damage_applied = true
	else:
		print("ERRO: Não foi possível aplicar dano ao alvo!")
	
	# Reduz satisfação da vítima (se aplicável)
	if damage_applied and target.has_method("get") and target.get("stats"):
		target.stats.modify_satisfaction(-10)
	
	# Efeito visual de impacto
	create_impact_effect()
	
	print("=== FIM IMPACTO PROJÉTIL ===")
	
	# Destrói o projétil
	destroy_projectile("atingiu_alvo")

func create_impact_effect():
	"""Cria efeito visual de impacto"""
	
	if sprite and is_instance_valid(sprite):
		sprite.modulate = Color.yellow
		
		# Cria pequena animação de impacto
		if sprite.get_parent():
			var tween = Tween.new()
			add_child(tween)
			tween.interpolate_property(sprite, "scale", Vector2(1, 1), Vector2(1.5, 1.5), 0.1)
			tween.interpolate_property(sprite, "modulate", Color.yellow, Color.red, 0.1)
			tween.start()

func destroy_projectile(reason: String = "desconhecido"):
	"""Remove o projétil de forma segura"""
	
	if is_destroyed:
		return
	
	is_destroyed = true
	
	print("Projétil destruído - Motivo: ", reason)
	
	# Remove da árvore de forma segura
	if get_parent():
		call_deferred("queue_free")
	else:
		queue_free()

# Métodos utilitários para configuração externa

func set_speed(new_speed: float):
	"""Altera velocidade do projétil"""
	speed = max(0.0, new_speed)

func set_lifetime(new_lifetime: float):
	"""Altera tempo de vida do projétil"""
	lifetime = max(0.1, new_lifetime)

func set_damage(new_damage: float):
	"""Altera dano do projétil"""
	damage = max(0.0, new_damage)

func get_travel_distance() -> float:
	"""Retorna distância percorrida"""
	return speed * current_lifetime

func is_projectile_valid() -> bool:
	"""Verifica se o projétil ainda é válido"""
	return not is_destroyed and is_instance_valid(self)

# Cleanup automático quando removido da árvore
func _exit_tree():
	"""Limpeza automática"""
	if not is_destroyed:
		print("Projétil removido da árvore de cena")
