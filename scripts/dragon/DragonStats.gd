# DragonStats.gd - Versão corrigida com método take_damage
class_name DragonStats
extends Resource

var Enums = preload("res://scripts/utils/Enums.gd")

export var dragon_name: String = ""
export var dragon_type: int = 0

# Atributos principais
export var level: int = 1
export var experience: float = 0.0
export var max_experience: float = 100.0

# Necessidades básicas
export var satiety: float = 100.0
export var max_satiety: float = 100.0
export var satisfaction: float = 50.0
export var energy: float = 100.0
export var max_energy: float = 100.0

# Atributos de combate/movimento
export var base_speed: float = 100.0
export var strength: float = 10.0
export var damage: float = 5.0
export var health: float = 100.0
export var max_health: float = 100.0

# Modificadores baseados em personalidade
var speed_modifier: float = 1.0
var aggression_modifier: float = 1.0
var energy_consumption_modifier: float = 1.0

signal stats_changed(stat_name, new_value)

func _init():
	generate_random_stats()

func generate_random_stats():
	"""Gera variações aleatórias nos atributos base"""
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Variação de ±20% nos atributos base
	base_speed *= rng.randf_range(0.8, 1.2)
	strength *= rng.randf_range(0.8, 1.2)
	damage *= rng.randf_range(0.8, 1.2)
	max_health *= rng.randf_range(0.8, 1.2)
	health = max_health

func get_effective_speed() -> float:
	"""Retorna velocidade real considerando modificadores"""
	var personality_mod = speed_modifier
	var satisfaction_mod = get_satisfaction_speed_modifier()
	var energy_mod = energy / max_energy
	
	return base_speed * personality_mod * satisfaction_mod * energy_mod

func get_satisfaction_speed_modifier() -> float:
	"""Dragões infelizes se movem mais devagar"""
	if satisfaction < 20:
		return 0.5
	elif satisfaction < 40:
		return 0.7
	elif satisfaction > 80:
		return 1.2
	else:
		return 1.0

func get_satisfaction_level() -> int:
	"""Retorna o nível de satisfação baseado no valor"""
	if satisfaction <= 20:
		return Enums.SatisfactionLevel.MISERABLE
	elif satisfaction <= 40:
		return Enums.SatisfactionLevel.UNHAPPY
	elif satisfaction <= 60:
		return Enums.SatisfactionLevel.NEUTRAL
	elif satisfaction <= 80:
		return Enums.SatisfactionLevel.CONTENT
	else:
		return Enums.SatisfactionLevel.HAPPY

func modify_satiety(amount: float):
	"""Modifica saciedade e emite sinal"""
	satiety = clamp(satiety + amount, 0, max_satiety)
	emit_signal("stats_changed", "satiety", satiety)

func modify_satisfaction(amount: float):
	"""Modifica satisfação e emite sinal"""
	satisfaction = clamp(satisfaction + amount, 0, 100)
	emit_signal("stats_changed", "satisfaction", satisfaction)

func modify_energy(amount: float):
	"""Modifica energia e emite sinal"""
	energy = clamp(energy + amount, 0, max_energy)
	emit_signal("stats_changed", "energy", energy)

func can_eat() -> bool:
	"""Verifica se o dragão pode comer (não está cheio)"""
	return satiety < max_satiety * 0.9

func is_hungry() -> bool:
	"""Verifica se o dragão está com fome"""
	return satiety < max_satiety * 0.3

func is_tired() -> bool:
	"""Verifica se o dragão está cansado"""
	return energy < max_energy * 0.3

func gain_experience(amount: float):
	"""Adiciona experiência e verifica level up"""
	experience += amount
	while experience >= max_experience:
		level_up()

func level_up():
	"""Sobe de nível e melhora atributos"""
	level += 1
	experience -= max_experience
	max_experience *= 1.5
	
	# Melhora atributos no level up
	max_health += 10
	health = max_health
	strength += 2
	damage += 1
	base_speed += 5
	
	emit_signal("stats_changed", "level", level)

func take_damage(damage_amount: float):
	"""CORRIGIDO: Recebe dano"""
	
	var old_health = health
	health = max(0.0, health - damage_amount)
	
	emit_signal("stats_changed", "health", health)
	
	print(dragon_name, " recebeu ", damage_amount, " de dano. Vida: ", health, "/", max_health)
	
	# Se morreu
	if health <= 0.0:
		print(dragon_name, " morreu!")
		# Aqui você pode adicionar lógica de morte
	
	# Retorna quanto dano foi realmente aplicado
	return old_health - health

func heal(heal_amount: float):
	"""NOVO: Cura o dragão"""
	
	health = min(max_health, health + heal_amount)
	emit_signal("stats_changed", "health", health)

func is_critically_injured() -> bool:
	"""Verifica se está gravemente ferido"""
	return health < max_health * 0.25

func is_dead() -> bool:
	"""Verifica se está morto"""
	return health <= 0.0

func get_health_percentage() -> float:
	"""Retorna porcentagem de vida"""
	return (health / max_health) * 100.0 if max_health > 0 else 0.0
