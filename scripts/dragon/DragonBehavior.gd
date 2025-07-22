# DragonBehavior.gd - Sistema com raiva e destruição
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

# === SISTEMA DE RAIVA ===
var is_angry: bool = false
var anger_timer: float = 0.0
var max_anger_duration: float = 30.0  # 30 segundos de raiva máxima
var anger_energy_drain_rate: float = 3.0  # Energia gasta por segundo em raiva
var last_anger_check_timer: float = 0.0

# Alvos para destruição
var target_decoration: Node = null
var target_dragon = null

var colldown: float = 1.2
var colldownPassed: float = 0.0

signal state_changed(new_state)
signal dragon_became_angry(dragon)
signal dragon_calmed_down(dragon)

func initialize(dragon_ref: KinematicBody2D, stats_ref: DragonStats, personality_ref: DragonPersonality):
	"""Inicializa o comportamento"""
	dragon = dragon_ref
	stats = stats_ref
	personality = personality_ref

	home_territory = dragon.global_position
	set_physics_process(true)

func _physics_process(delta):
	if not dragon:
		return

	state_timer += delta
	last_anger_check_timer += delta
	
	# Verifica raiva periodicamente
	if last_anger_check_timer >= 1.0:  # A cada 1 segundo
		check_anger_system()
		last_anger_check_timer = 0.0
	
	# Processa raiva se estiver ativo
	if is_angry:
		process_anger_system(delta)
	
	update_behavior(delta)
	natural_decay(delta)

func check_anger_system():
	"""Verifica se o dragão deve ficar com raiva"""
	
	if is_angry:
		return  # Já está com raiva
	
	# Calcula chance de raiva baseada na satisfação
	var satisfaction = stats.satisfaction
	var anger_chance = calculate_anger_chance(satisfaction)
	
	# Fatores que aumentam chance de raiva
	if stats.is_hungry():
		anger_chance *= 1.5  # 50% mais chance se com fome
	
	if stats.is_tired():
		anger_chance *= 1.3  # 30% mais chance se cansado
	
	# Personalidade afeta chance de raiva
	match personality.primary_trait:
		Enums.PersonalityTrait.AGGRESSIVE:
			anger_chance *= 2.0  # Agressivos ficam com raiva mais fácil
		Enums.PersonalityTrait.PEACEFUL:
			anger_chance *= 0.3  # Pacíficos raramente ficam com raiva
		Enums.PersonalityTrait.TERRITORIAL:
			anger_chance *= 1.5  # Territoriais ficam com raiva mais
	
	# Testa chance de raiva
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	if rng.randf() < anger_chance:
		become_angry()

func calculate_anger_chance(satisfaction: float) -> float:
	"""Calcula chance de raiva baseada na satisfação (inversamente proporcional)"""
	
	# Satisfação 0-100, chance de raiva 0.2-0.001 por segundo
	# Quanto menor a satisfação, maior a chance de raiva
	
	if satisfaction >= 80:
		return 0.001  # 0.1% chance por segundo quando muito satisfeito
	elif satisfaction >= 60:
		return 0.005  # 0.5% chance por segundo quando satisfeito
	elif satisfaction >= 40:
		return 0.02   # 2% chance por segundo quando neutro
	elif satisfaction >= 20:
		return 0.05   # 5% chance por segundo quando insatisfeito
	else:
		return 0.1    # 10% chance por segundo quando muito insatisfeito

func become_angry():
	"""Dragão fica com raiva"""
	
	if is_angry:
		return
	
	is_angry = true
	anger_timer = 0.0
	
	# Energia vai para o máximo quando fica com raiva (adrenalina)
	stats.energy = stats.max_energy
	
	# Muda para estado agressivo
	change_state(Enums.DragonState.AGGRESSIVE)
	
	# Efeito visual de raiva
	dragon.modulate = Color.red
	
	# Calcula duração da raiva baseada na personalidade
	max_anger_duration = 30.0
	match personality.primary_trait:
		Enums.PersonalityTrait.AGGRESSIVE:
			max_anger_duration = 45.0  # Agressivos ficam com raiva mais tempo
		Enums.PersonalityTrait.PEACEFUL:
			max_anger_duration = 15.0  # Pacíficos se acalmam rápido
		Enums.PersonalityTrait.ENERGETIC:
			max_anger_duration = 40.0  # Energéticos mantêm raiva mais tempo
	
	emit_signal("dragon_became_angry", dragon)
	print(stats.dragon_name, " ficou FURIOSO! Duração: ", int(max_anger_duration), "s")

func process_anger_system(delta):
	"""Processa sistema de raiva"""
	
	anger_timer += delta
	
	# Drena energia durante a raiva
	stats.modify_energy(-anger_energy_drain_rate * delta)
	
	# Calma quando energia zera ou tempo da raiva passa
	if stats.energy <= 0 or anger_timer >= max_anger_duration:
		calm_down()

func calm_down():
	"""Dragão se acalma"""
	
	if not is_angry:
		return
	
	is_angry = false
	anger_timer = 0.0
	target_decoration = null
	target_dragon = null
	
	# Remove efeito visual
	dragon.modulate = Color.white
	
	# Volta para estado de vagar
	change_state(Enums.DragonState.WANDERING)
	
	# Perde um pouco de satisfação por ter ficado com raiva
	stats.modify_satisfaction(-5)
	
	emit_signal("dragon_calmed_down", dragon)
	print(stats.dragon_name, " se acalmou.")

func update_behavior(delta):
	"""Atualiza comportamento baseado no estado atual"""

	# Se está com raiva, comportamento especial
	if is_angry:
		update_angry_behavior(delta)
		return
	
	# Comportamento normal
	check_state_transitions()

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
			if not is_angry:  # Agressividade normal (não raiva)
				behavior_aggressive(delta)
		Enums.DragonState.FLEEING:
			behavior_fleeing(delta)
		Enums.DragonState.SLEEPING:
			behavior_sleeping(delta)

func update_angry_behavior(delta):
	"""Comportamento especial quando com raiva"""
	
	# Procura alvos para destruir/atacar
	find_anger_targets()
	
	if target_decoration and is_instance_valid(target_decoration) and colldown <= colldownPassed:
		# Vai destruir decoração
		attack_decoration(delta)
		colldownPassed = 0
	elif target_dragon and is_instance_valid(target_dragon) and colldown <= colldownPassed:
		# Vai atacar outro dragão
		attack_dragon(delta)
		colldownPassed = 0
	else:
		# Sem alvos, vaga com raiva
		angry_wandering(delta)
		
		colldownPassed += delta
	

func find_anger_targets():
	"""Encontra alvos para a raiva"""
	
	# Primeiro prioridade: decorações próximas
	if not target_decoration or not is_instance_valid(target_decoration):
		target_decoration = find_nearest_decoration()
	
	# Segunda prioridade: outros dragões
	if not target_decoration and (not target_dragon or not is_instance_valid(target_dragon)):
		target_dragon = find_nearest_dragon()

func find_nearest_decoration():
	"""Encontra decoração mais próxima para destruir"""
	
	var decorations = get_tree().get_nodes_in_group("decorations")
	var nearest = null
	var nearest_distance = INF
	var max_search_range = 200.0  # Não vai muito longe procurar
	
	for decoration in decorations:
		if is_instance_valid(decoration):
			var distance = dragon.global_position.distance_to(decoration.global_position)
			if distance < nearest_distance and distance <= max_search_range:
				nearest = decoration
				nearest_distance = distance
	
	return nearest

func find_nearest_dragon():
	"""Encontra dragão mais próximo para atacar"""
	
	var nearest = null
	var nearest_distance = INF
	var max_search_range = 1500.0
	
	nearby_dragons = get_tree().get_nodes_in_group("dragons")
	
	for other_dragon in nearby_dragons:
		if is_instance_valid(other_dragon) and other_dragon != dragon:
			var distance = dragon.global_position.distance_to(other_dragon.global_position)
			if distance < nearest_distance and distance <= max_search_range:
				nearest = other_dragon
				nearest_distance = distance
	
	return nearest

func attack_decoration(delta):
	"""Ataca/destrói decoração"""
	
	target_position = target_decoration.global_position
	move_towards_target(delta, 1.5)  # Move rápido com raiva
	
	# Se chegou perto da decoração
	if dragon.global_position.distance_to(target_position) < 40:
		# Destrói a decoração
		print(stats.dragon_name, " destruiu ", target_decoration.item_name if "item_name" in target_decoration else "decoração")
		
		# Remove a decoração
		if target_decoration.has_method("delete_item"):
			target_decoration.delete_item()
		else:
			target_decoration.queue_free()
		
		target_decoration = null
		
		# Ganha um pouco de satisfação por descarregar a raiva
		stats.modify_satisfaction(3)

func attack_dragon(delta):
	"""CORRIGIDO: Ataca outro dragão - corpo a corpo ou à distância"""
	
	if not target_dragon or not is_instance_valid(target_dragon):
		target_dragon = null
		return
	
	target_position = target_dragon.global_position
	var distance_to_target = dragon.global_position.distance_to(target_position)
	
	# Determina o tipo de ataque baseado na distância
	var melee_attack = distance_to_target <= 100
	
	if melee_attack:
		# ATAQUE CORPO A CORPO
		move_towards_target(delta, 1.8)  # Move muito rápido para atacar
		
		# Calcula dano baseado na raiva
		var base_damage = stats.damage
		var rage_multiplier = 2.0  # Dano dobrado com raiva
		var final_damage = base_damage * rage_multiplier
		
		print("=== ATAQUE CORPO A CORPO ===")
		print(stats.dragon_name, " está atacando ", target_dragon.stats.dragon_name)
		print("Dano base: ", base_damage, " | Multiplicador raiva: ", rage_multiplier, " | Dano final: ", final_damage)
		
		# Aplica dano ao dragão alvo
		if target_dragon.has_method("take_damage"):
			target_dragon.take_damage(final_damage)
		elif target_dragon.stats:
			target_dragon.stats.take_damage(final_damage)
		else:
			print("ERRO: Não foi possível aplicar dano ao dragão alvo!")
		
		# Reduz satisfação da vítima
		if target_dragon.stats:
			target_dragon.stats.modify_satisfaction(-15)
		
		# Empurra o dragão para longe
		var push_direction = (target_dragon.global_position - dragon.global_position).normalized()
		var push_distance = 50.0
		target_dragon.global_position += push_direction * push_distance
		
		# Adiciona um pouco de velocidade para simular o empurrão
		if target_dragon.has_method("add_impulse"):
			target_dragon.add_impulse(push_direction * 200)
		
		print(stats.dragon_name, " empurrou ", target_dragon.stats.dragon_name, " para longe!")
		
		# Procura novo alvo ou limpa o atual
		target_dragon = null
		
		# Ganha satisfação por atacar (descarrega a raiva)
		stats.modify_satisfaction(5)
		
		print("=== FIM ATAQUE CORPO A CORPO ===")
		
	else:
		# ATAQUE À LONGA DISTÂNCIA
		if distance_to_target >= 700:
			return
		
		print("=== ATAQUE À DISTÂNCIA ===")
		print(stats.dragon_name, " está preparando ataque à distância contra ", target_dragon.stats.dragon_name)
		print("Distância: ", distance_to_target)
		
		# Instancia o projétil/disparo
		create_ranged_attack(target_position)
		
		# Procura novo alvo após disparar
		target_dragon = null
		
		# Ganha um pouco menos de satisfação que no corpo a corpo
		stats.modify_satisfaction(3)
		
		print("=== FIM ATAQUE À DISTÂNCIA ===")

func create_ranged_attack(target_pos: Vector2):
	"""Cria um projétil direcionado ao alvo"""
	
	# Você pode usar uma scene de projétil pré-fabricada ou criar dinamicamente
	# Exemplo com scene pré-fabricada:
	var projectile_scene = preload("res://scenes/DragonProjectile.tscn")  # Ajuste o caminho
	var projectile = projectile_scene.instance()
	
	# Posiciona o projétil na posição do dragão
	projectile.global_position = dragon.global_position
	
	# Calcula direção para o alvo
	var direction = (target_pos - dragon.global_position).normalized()
	
	# Configura o projétil
	if projectile.has_method("setup"):
		var projectile_damage = stats.damage * 1.5  # Dano ligeiramente maior à distância
		projectile.setup(direction, projectile_damage, self)
	
	# Adiciona o projétil à cena
	get_tree().current_scene.add_child(projectile)
	
	print("Projétil criado na direção: ", direction)

#func attack_dragon(delta):
#	"""CORRIGIDO: Ataca outro dragão"""
#
#	if not target_dragon or not is_instance_valid(target_dragon):
#		target_dragon = null
#		return
#
#	target_position = target_dragon.global_position
#	move_towards_target(delta, 1.8)  # Move muito rápido para atacar
#
#	# Se chegou perto do dragão
#	if dragon.global_position.distance_to(target_position) <= 100:
#		# Calcula dano baseado na raiva
#		var base_damage = stats.damage
#		var rage_multiplier = 2.0  # Dano dobrado com raiva
#		var final_damage = base_damage * rage_multiplier
#
#		print("=== ATAQUE ===")
#		print(stats.dragon_name, " está atacando ", target_dragon.stats.dragon_name)
#		print("Dano base: ", base_damage, " | Multiplicador raiva: ", rage_multiplier, " | Dano final: ", final_damage)
#
#		# Aplica dano ao dragão alvo
#		if target_dragon.has_method("take_damage"):
#			target_dragon.take_damage(final_damage)
#		elif target_dragon.stats:
#			target_dragon.stats.take_damage(final_damage)
#		else:
#			print("ERRO: Não foi possível aplicar dano ao dragão alvo!")
#
#		# Reduz satisfação da vítima
#		if target_dragon.stats:
#			target_dragon.stats.modify_satisfaction(-15)
#
#		# Empurra o dragão para longe
#		var push_direction = (target_dragon.global_position - dragon.global_position).normalized()
#		var push_distance = 50.0
#		target_dragon.global_position += push_direction * push_distance
#
#		# Adiciona um pouco de velocidade para simular o empurrão
#		if target_dragon.has_method("add_impulse"):
#			target_dragon.add_impulse(push_direction * 200)
#
#		print(stats.dragon_name, " empurrou ", target_dragon.stats.dragon_name, " para longe!")
#
#		# Procura novo alvo ou limpa o atual
#		target_dragon = null
#
#		# Ganha satisfação por atacar (descarrega a raiva)
#		stats.modify_satisfaction(5)
#
#		print("=== FIM ATAQUE ===")

func angry_wandering(delta):
	"""Vaga com raiva procurando alvos"""
	
	# Move mais rápido e erraticamente
	if target_position == Vector2.ZERO or dragon.global_position.distance_to(target_position) < 30:
		set_random_wander_target()
	
	move_towards_target(delta, 1.3)  # Move rápido

func check_state_transitions():
	"""Verifica se deve mudar de estado (comportamento normal)"""

	# Prioridades altas
	if stats.health < stats.max_health * 0.2:
		change_state(Enums.DragonState.FLEEING)
		return

	if stats.is_tired() and personality.should_rest():
		change_state(Enums.DragonState.RESTING)
		return

	if stats.is_hungry():
		change_state(Enums.DragonState.SEEKING_FOOD)
		return

	# Comportamentos baseados em satisfação (só se não estiver com raiva)
	if stats.get_satisfaction_level() == Enums.SatisfactionLevel.MISERABLE and not is_angry:
		if randf() < personality.get_aggression_level():
			change_state(Enums.DragonState.AGGRESSIVE)
			return

	# Comportamento territorial
	if personality.primary_trait == Enums.PersonalityTrait.TERRITORIAL:
		var distance_from_home = dragon.global_position.distance_to(home_territory)
		if distance_from_home > personality.territory_size:
			change_state(Enums.DragonState.TERRITORIAL)
			return

	check_social_behavior()

func check_social_behavior():
	"""Verifica comportamentos sociais"""
	for nearby_dragon in nearby_dragons:
		if not nearby_dragon or not is_instance_valid(nearby_dragon):
			continue

		var distance = dragon.global_position.distance_to(nearby_dragon.global_position)
		var preferred_distance = personality.get_preferred_distance_from_others()

		if distance < preferred_distance * 0.5:
			if personality.primary_trait == Enums.PersonalityTrait.AGGRESSIVE and not is_angry:
				change_state(Enums.DragonState.AGGRESSIVE)
				return
			elif personality.primary_trait == Enums.PersonalityTrait.SOLITARY:
				change_state(Enums.DragonState.FLEEING)
				return

# === COMPORTAMENTOS NORMAIS (mantidos) ===

func behavior_wandering(delta):
	"""Comportamento de vagar livremente"""

	if target_position == Vector2.ZERO or dragon.global_position.distance_to(target_position) < 50:
		set_random_wander_target()

	move_towards_target(delta)

	if state_timer > (RandomNumberGenerator.new()).randf_range(3.0, 8.0):
		if personality.should_rest():
			change_state(Enums.DragonState.RESTING)
		else:
			set_random_wander_target()

func behavior_seeking_food(delta):
	"""Procura por comida no mapa"""

	if nearby_food.size() > 0:
		var closest_food = find_closest_food()
		if closest_food and is_instance_valid(closest_food):
			target_position = closest_food.global_position
			move_towards_target(delta)

			if dragon.global_position.distance_to(target_position) < 30:
				change_state(Enums.DragonState.EATING)
	else:
		if target_position == Vector2.ZERO or dragon.global_position.distance_to(target_position) < 50:
			set_random_wander_target()
		move_towards_target(delta)

func behavior_eating(delta):
	"""Comportamento de comer"""

	dragon.velocity = Vector2.ZERO

	if state_timer > 2.0:
		stats.modify_satiety(30)
		stats.modify_satisfaction(10)
		stats.gain_experience(5)
		change_state(Enums.DragonState.WANDERING)

func behavior_resting(delta):
	"""Comportamento de descanso"""

	dragon.velocity = Vector2.ZERO
	stats.modify_energy(20 * delta)

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

	if dragon.global_position.distance_to(home_territory) < 50:
		change_state(Enums.DragonState.WANDERING)

func behavior_aggressive(delta):
	"""Comportamento agressivo normal (não raiva)"""

	if nearby_dragons.size() > 0:
		var target_dragon = nearby_dragons[0]
		if target_dragon and is_instance_valid(target_dragon):
			target_position = target_dragon.global_position
			move_towards_target(delta, 1.5)

			if dragon.global_position.distance_to(target_position) < 40:
				if target_dragon.has_method("get_stats"):
					target_dragon.get_stats().modify_satisfaction(-20)
				change_state(Enums.DragonState.WANDERING)
	else:
		change_state(Enums.DragonState.WANDERING)

func behavior_fleeing(delta):
	"""Foge de ameaças"""

	if target_position == Vector2.ZERO:
		if nearby_dragons.size() > 0:
			var threat = nearby_dragons[0]
			if threat and is_instance_valid(threat):
				var threat_position = threat.global_position
				var flee_direction = (dragon.global_position - threat_position).normalized()
				target_position = dragon.global_position + flee_direction * 300
		else:
			target_position = home_territory

	move_towards_target(delta, 1.3)

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
	
	# Se está com raiva, move ainda mais rápido
	if is_angry:
		speed *= 1.2

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

	# Energia diminui com movimento (mas não durante raiva)
	if dragon.velocity.length() > 0 and not is_angry:
		stats.modify_energy(-5 * delta)

	# Perda de vida por fome
	if stats.is_hungry():
		var hunger_damage = 2 * delta
		
		# Se está com raiva, perde menos vida por fome
		if is_angry:
			hunger_damage *= 0.3  # Reduz em 70% o dano da fome durante raiva
		
		stats.take_damage(hunger_damage)

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

# === FUNÇÕES PÚBLICAS PARA ACESSO EXTERNO ===

func is_dragon_angry() -> bool:
	"""Retorna se o dragão está com raiva"""
	return is_angry

func get_anger_info() -> Dictionary:
	"""Retorna informações sobre o estado de raiva"""
	return {
		"is_angry": is_angry,
		"anger_timer": anger_timer,
		"max_duration": max_anger_duration,
		"time_left": max_anger_duration - anger_timer if is_angry else 0,
		"target_decoration": target_decoration,
		"target_dragon": target_dragon
	}

func force_calm_down():
	"""Força o dragão a se acalmar (para debug ou eventos especiais)"""
	if is_angry:
		calm_down()
