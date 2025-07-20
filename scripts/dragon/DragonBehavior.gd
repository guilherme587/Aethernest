# DragonBehavior.gd
# IMPORTANTE: NÃO usar class_name aqui para evitar dependência circular
extends Node

var Enums = preload("res://scripts/utils/Enums.gd")

var dragon: KinematicBody2D
var stats: DragonStats
var personality: DragonPersonality

var current_state: int = Enums.DragonState.WANDERING
var state_timer: float = 0.0
var target_position: Vector2
var home_territory: Vector2

# Detecção de proximidade
var nearby_dragons: Array = []
var nearby_food: Array = []

signal state_changed(new_state)

func initialize(dragon_ref: KinematicBody2D, stats_ref: DragonStats, personality_ref: DragonPersonality):
	"""Inicializa o comportamento - chamado pelo Dragon"""
	dragon = dragon_ref
	stats = stats_ref
	personality = personality_ref

	# Define território inicial como posição atual
	home_territory = dragon.global_position

	set_physics_process(true)

func _physics_process(delta):
	if not dragon:
		return

	state_timer += delta
	update_behavior(delta)

	# Decaimento natural de stats
	natural_decay(delta)

func update_behavior(delta):
	"""Atualiza comportamento baseado no estado atual"""

	# Verifica condições para mudança de estado
	check_state_transitions()

	# Executa comportamento do estado atual
	match current_state:
		Enums.DragonState.WANDERING:
			behavior_wandering(delta)
		Enums.DragonState.SEEKING_FOOD:
			behavior_seeking_food(delta)
		Enums.DragonState.EATING:
			behavior_eating(delta)
		Enums.DragonState.RESTING:
			behavior_resting(delta)
		Enums.DragonState.TERRITORIAL:
			behavior_territorial(delta)
		Enums.DragonState.AGGRESSIVE:
			behavior_aggressive(delta)
		Enums.DragonState.FLEEING:
			behavior_fleeing(delta)
		Enums.DragonState.SLEEPING:
			behavior_sleeping(delta)

func check_state_transitions():
	"""Verifica se deve mudar de estado"""

	# Prioridades altas (sempre verificadas)
	if stats.health < stats.max_health * 0.2:
		change_state(Enums.DragonState.FLEEING)
		return

	if stats.is_tired() and personality.should_rest():
		change_state(Enums.DragonState.RESTING)
		return

	if stats.is_hungry():
		change_state(Enums.DragonState.SEEKING_FOOD)
		return

	# Comportamentos baseados em satisfação
	if stats.get_satisfaction_level() == Enums.SatisfactionLevel.MISERABLE:
		if randf() < personality.get_aggression_level():
			change_state(Enums.DragonState.AGGRESSIVE)
			return

	# Comportamento territorial
	if personality.primary_trait == Enums.PersonalityTrait.TERRITORIAL:
		var distance_from_home = dragon.global_position.distance_to(home_territory)
		if distance_from_home > personality.territory_size:
			change_state(Enums.DragonState.TERRITORIAL)
			return

	# Verifica dragões próximos para comportamento social
	check_social_behavior()

func check_social_behavior():
	"""Verifica comportamentos sociais"""
	for nearby_dragon in nearby_dragons:
		if not nearby_dragon or not is_instance_valid(nearby_dragon):
			continue

		var distance = dragon.global_position.distance_to(nearby_dragon.global_position)
		var preferred_distance = personality.get_preferred_distance_from_others()

		if distance < preferred_distance * 0.5:
			# Muito próximo - pode causar estresse ou agressão
			if personality.primary_trait == Enums.PersonalityTrait.AGGRESSIVE:
				change_state(Enums.DragonState.AGGRESSIVE)
				return
			elif personality.primary_trait == Enums.PersonalityTrait.SOLITARY:
				change_state(Enums.DragonState.FLEEING)
				return

func behavior_wandering(delta):
	"""Comportamento de vagar livremente"""

	# Se não tem destino ou chegou próximo ao destino
	if target_position == Vector2.ZERO or dragon.global_position.distance_to(target_position) < 50:
		set_random_wander_target()

	# Move em direção ao alvo
	move_towards_target(delta)

	# Muda de estado depois de um tempo
	if state_timer > (RandomNumberGenerator.new()).randf_range(3.0, 8.0):
		if personality.should_rest():
			change_state(Enums.DragonState.RESTING)
		else:
			set_random_wander_target()

func behavior_seeking_food(delta):
	"""Procura por comida no mapa"""

	if nearby_food.size() > 0:
		# Move para a comida mais próxima
		var closest_food = find_closest_food()
		if closest_food and is_instance_valid(closest_food):
			target_position = closest_food.global_position
			move_towards_target(delta)

			# Se chegou perto da comida
			if dragon.global_position.distance_to(target_position) < 30:
				change_state(Enums.DragonState.EATING)
	else:
		# Não encontrou comida, vaga procurando
		if target_position == Vector2.ZERO or dragon.global_position.distance_to(target_position) < 50:
			set_random_wander_target()
		move_towards_target(delta)

func behavior_eating(delta):
	"""Comportamento de comer"""

	# Para de se mover
	dragon.velocity = Vector2.ZERO

	# Simula tempo de comer
	if state_timer > 2.0:
		stats.modify_satiety(30)
		stats.modify_satisfaction(10)
		stats.gain_experience(5)
		change_state(Enums.DragonState.WANDERING)

func behavior_resting(delta):
	"""Comportamento de descanso"""

	# Para de se mover
	dragon.velocity = Vector2.ZERO

	# Recupera energia
	stats.modify_energy(20 * delta)

	# Descansa por um tempo baseado na personalidade
	var rest_time = 3.0
	if personality.primary_trait == Enums.PersonalityTrait.LAZY:
		rest_time *= 2.0
	elif personality.primary_trait == Enums.PersonalityTrait.ENERGETIC:
		rest_time *= 0.5

	if state_timer > rest_time:
		change_state(Enums.DragonState.WANDERING)

func behavior_territorial(delta):
	"""Volta para o território"""

	target_position = home_territory
	move_towards_target(delta)

	# Se chegou perto do território
	if dragon.global_position.distance_to(home_territory) < 50:
		change_state(Enums.DragonState.WANDERING)

func behavior_aggressive(delta):
	"""Comportamento agressivo"""

	# Procura alvo para atacar
	if nearby_dragons.size() > 0:
		var target_dragon = nearby_dragons[0]
		if target_dragon and is_instance_valid(target_dragon):
			target_position = target_dragon.global_position
			move_towards_target(delta, 1.5)  # Move mais rápido quando agressivo

			# Se chegou perto, "ataca" (por enquanto só empurra)
			if dragon.global_position.distance_to(target_position) < 40:
				# Causa dano ao stats do alvo
				if target_dragon.has_method("get_stats"):
					target_dragon.get_stats().modify_satisfaction(-20)
				change_state(Enums.DragonState.WANDERING)
	else:
		# Sem alvos, volta a vagar
		change_state(Enums.DragonState.WANDERING)

func behavior_fleeing(delta):
	"""Foge de ameaças"""

	# Se não tem destino de fuga, escolhe direção oposta à ameaça
	if target_position == Vector2.ZERO:
		if nearby_dragons.size() > 0:
			var threat = nearby_dragons[0]
			if threat and is_instance_valid(threat):
				var threat_position = threat.global_position
				var flee_direction = (dragon.global_position - threat_position).normalized()
				target_position = dragon.global_position + flee_direction * 300
		else:
			target_position = home_territory

	move_towards_target(delta, 1.3)  # Move mais rápido fugindo

	# Para de fugir depois de um tempo ou se chegou longe
	if state_timer > 5.0 or dragon.global_position.distance_to(target_position) < 50:
		change_state(Enums.DragonState.WANDERING)

func behavior_sleeping(delta):
	"""Dorme para recuperar energia"""

	dragon.velocity = Vector2.ZERO
	stats.modify_energy(40 * delta)

	if state_timer > 10.0 or stats.energy >= stats.max_energy:
		change_state(Enums.DragonState.WANDERING)

func move_towards_target(delta, speed_multiplier = 1.0):
	"""Move o dragão em direção ao alvo"""

	if target_position == Vector2.ZERO:
		return

	var direction = (target_position - dragon.global_position).normalized()
	var speed = stats.get_effective_speed() * speed_multiplier

	dragon.velocity = direction * speed
	dragon.velocity = dragon.move_and_slide(dragon.velocity)

func set_random_wander_target():
	"""Define um alvo aleatório para vagar"""

	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var angle = rng.randf() * 2 * PI
	var distance = rng.randf_range(100, personality.exploration_range)

	target_position = dragon.global_position + Vector2(cos(angle), sin(angle)) * distance

func change_state(new_state: int):
	"""Muda o estado comportamental"""

	if current_state != new_state:
		current_state = new_state
		state_timer = 0.0
		target_position = Vector2.ZERO
		emit_signal("state_changed", new_state)

func natural_decay(delta):
	"""Decaimento natural das necessidades"""

	# Saciedade diminui com o tempo
	stats.modify_satiety(-2 * delta)

	# Energia diminui com movimento
	if dragon.velocity.length() > 0:
		stats.modify_energy(-5 * delta)

	# Satisfação diminui lentamente se necessidades não forem atendidas
	if stats.is_hungry() or stats.is_tired():
		stats.modify_satisfaction(-1 * delta)

func find_closest_food():
	"""Encontra a comida mais próxima"""
	if nearby_food.size() == 0:
		return null

	var closest = null
	var closest_distance = INF

	for food in nearby_food:
		if not food or not is_instance_valid(food):
			continue

		var distance = dragon.global_position.distance_to(food.global_position)
		if distance < closest_distance:
			closest = food
			closest_distance = distance

	return closest
