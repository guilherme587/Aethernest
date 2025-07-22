# Dragon.gd - Versão atualizada com sistema de decorações
class_name Dragon
extends KinematicBody2D

var Enums = preload("res://scripts/utils/Enums.gd")

# Componentes do dragão
var stats: DragonStats
var personality: DragonPersonality
var behavior: Node

# Propriedades de movimento
var velocity: Vector2 = Vector2.ZERO

# Componentes visuais
onready var sprite: Sprite = $Sprite
onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Sistema de detecção
onready var detection_area: Area2D = $DetectionArea
onready var detection_collision: CollisionShape2D = $DetectionArea/CollisionShape2D

# NOVO: Sistema de decorações
var decoration_update_timer: float = 0.0

# Sinais
signal dragon_clicked(dragon)
signal stats_updated(dragon)

func _ready():
	add_to_group("dragons")
	initialize_dragon()
	setup_detection()
	connect_signals()

func initialize_dragon():
	"""Inicializa todos os sistemas do dragão"""
	
	# Cria componentes
	stats = DragonStats.new()
	personality = DragonPersonality.new()
	
	# Aplica modificadores de personalidade aos stats
	stats.speed_modifier = personality.get_speed_modifier()
	stats.aggression_modifier = personality.get_aggression_level()
	
	# Cria comportamento usando preload para evitar dependência circular
	var behavior_script = preload("res://scripts/dragon/DragonBehavior.gd")
	behavior = behavior_script.new()
	add_child(behavior)
	behavior.initialize(self, stats, personality)
	
	# Gera nome único
	if stats.dragon_name.empty():
		stats.dragon_name = generate_dragon_name()
	
	# Ajusta tamanho visual baseado no nível
	update_visual_scale()

func setup_detection():
	"""Configura área de detecção"""
	
	detection_area.connect("body_entered", self, "_on_detection_area_entered")
	detection_area.connect("body_exited", self, "_on_detection_area_exited")
	
	# Ajusta tamanho da área de detecção baseado na personalidade
	var detection_radius = personality.social_distance
	var shape = CircleShape2D.new()
	shape.radius = detection_radius
	detection_collision.shape = shape

func connect_signals():
	"""Conecta sinais internos"""
	
	stats.connect("stats_changed", self, "_on_stats_changed")
	behavior.connect("state_changed", self, "_on_state_changed")
	
	# NOVO: Conecta sinais de raiva
	behavior.connect("dragon_became_angry", self, "_on_dragon_became_angry")
	behavior.connect("dragon_calmed_down", self, "_on_dragon_calmed_down")
	
	# Conecta sinais de decoração
	if personality:
		personality.connect("decoration_satisfaction_changed", self, "_on_decoration_satisfaction_changed")
	
	connect("input_event", self, "_on_dragon_input")

func _on_dragon_became_angry(dragon_ref):
	"""Dragão ficou com raiva"""
	print(stats.dragon_name, " está FURIOSO e vai causar destruição!")

func _on_dragon_calmed_down(dragon_ref):
	"""Dragão se acalmou"""
	print(stats.dragon_name, " se acalmou e parou de causar destruição.")

# Adicionar na função get_state_name():
func get_state_name(state: int) -> String:
	"""Converte estado para nome legível"""
	
	# Se está com raiva, mostra isso no estado
	if behavior and behavior.is_dragon_angry():
		return "FURIOSO"
	
	match state:
		Enums.DragonState.WANDERING:
			return "Vagando"
		Enums.DragonState.SEEKING_FOOD:
			return "Procurando comida"
		Enums.DragonState.EATING:
			return "Comendo"
		Enums.DragonState.RESTING:
			return "Descansando"
		Enums.DragonState.TERRITORIAL:
			return "Defendendo território"
		Enums.DragonState.AGGRESSIVE:
			return "Agressivo"
		Enums.DragonState.FLEEING:
			return "Fugindo"
		Enums.DragonState.SLEEPING:
			return "Dormindo"
		_:
			return "Desconhecido"

func _process(delta):
	"""ATUALIZADO: Processa lógica do dragão incluindo decorações"""
	
	# CORRIGIDO: Atualiza satisfação com decorações periodicamente
	decoration_update_timer += delta
	if decoration_update_timer >= 2.0:  # A cada 2 segundos
		decoration_update_timer = 0.0
		if personality:
			# Pega decorações da árvore de cenas
			var decoration_nodes = get_tree().get_nodes_in_group("decorations")
			personality.update_decoration_satisfaction(global_position, decoration_nodes)


func _on_stats_changed(stat_name: String, new_value):
	"""Responde a mudanças nos stats"""
	
	emit_signal("stats_updated", self)
	
	# Atualiza visual baseado em mudanças
	if stat_name == "level":
		update_visual_scale()

func _on_state_changed(new_state: int):
	"""Responde a mudanças de estado"""
	
	# Pode atualizar animações ou efeitos visuais aqui
	update_visual_state(new_state)

func _on_decoration_satisfaction_changed(new_satisfaction: float):
	"""NOVO: Satisfação com decorações mudou"""
	
	# Aplica efeito na satisfação geral do dragão
	var decoration_bonus = (new_satisfaction - 50.0) * 0.2  # ±10 pontos máximo
	stats.modify_satisfaction(decoration_bonus)
	
	print(stats.dragon_name, " satisfação com decorações: ", int(new_satisfaction), "%")

func _on_detection_area_entered(body):
	"""Detecta quando algo entra na área"""
	
	if body.is_in_group("dragons") and body != self:
		behavior.nearby_dragons.append(body)
	elif body.is_in_group("food"):
		behavior.nearby_food.append(body)

func _on_detection_area_exited(body):
	"""Detecta quando algo sai da área"""
	
	if body.is_in_group("dragons"):
		behavior.nearby_dragons.erase(body)
	elif body.is_in_group("food"):
		behavior.nearby_food.erase(body)

func _on_dragon_input(viewport, event, shape_idx):
	"""Responde a cliques no dragão"""
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("dragon_clicked", self)

func update_visual_scale():
	"""Atualiza escala visual baseada no nível"""
	
	var base_scale = 1.0
	var scale_per_level = 0.1
	var new_scale = base_scale + (stats.level - 1) * scale_per_level
	
	scale = Vector2(new_scale, new_scale)

func update_visual_state(state: int):
	"""Atualiza visual baseado no estado comportamental"""
	
	# Placeholder para animações futuras
	match state:
		Enums.DragonState.AGGRESSIVE:
			modulate = Color.red
		Enums.DragonState.RESTING:
			modulate = Color.blue
		Enums.DragonState.EATING:
			modulate = Color.green
		_:
			modulate = Color.white

func generate_dragon_name() -> String:
	"""Gera nome único para o dragão"""
	
	var prefixes = ["Ignis", "Frost", "Terra", "Zephyr", "Crystal", "Shadow", "Storm", "Ember"]
	var suffixes = ["wing", "claw", "heart", "scale", "flame", "shard", "roar", "eye"]
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var prefix = prefixes[rng.randi() % prefixes.size()]
	var suffix = suffixes[rng.randi() % suffixes.size()]
	
	return prefix + suffix

func get_info_text() -> String:
	"""Retorna texto formatado com informações do dragão"""
	
	var info = ""
	info += "Nome: " + stats.dragon_name + "\n"
	info += "Personalidade: " + personality.get_personality_description() + "\n"
	info += "Nível: " + str(stats.level) + "\n"
	info += "Saciedade: " + str(int(stats.satiety)) + "/" + str(int(stats.max_satiety)) + "\n"
	info += "Satisfação: " + str(int(stats.satisfaction)) + "/100\n"
	info += "Energia: " + str(int(stats.energy)) + "/" + str(int(stats.max_energy)) + "\n"
	info += "Estado: " + get_state_name(behavior.current_state) + "\n"
	
	# NOVO: Adiciona informação de decorações
	info += "Satisfação Decorações: " + str(int(personality.decoration_satisfaction)) + "%\n"
	
	return info

func get_stats() -> DragonStats:
	"""Getter para stats (usado por outros dragões)"""
	return stats

func save_dragon_data() -> Dictionary:
	"""ATUALIZADO: Salva dados do dragão incluindo decorações"""
	
	return {
		"position": global_position,
		"stats": {
			"dragon_name": stats.dragon_name,
			"dragon_type": stats.dragon_type,
			"level": stats.level,
			"experience": stats.experience,
			"satiety": stats.satiety,
			"satisfaction": stats.satisfaction,
			"energy": stats.energy,
			"health": stats.health
		},
		"personality": {
			"primary_trait": personality.primary_trait,
			"secondary_trait": personality.secondary_trait,
			"trait_intensity": personality.trait_intensity,
			"decoration_preferences": personality.decoration_preferences,
			"decoration_satisfaction": personality.decoration_satisfaction,
			"satisfaction_area_radius": personality.satisfaction_area_radius
		}
	}

func load_dragon_data(data: Dictionary):
	"""ATUALIZADO: Carrega dados salvos incluindo decorações"""
	
	global_position = data.get("position", Vector2.ZERO)
	
	var stats_data = data.get("stats", {})
	stats.dragon_name = stats_data.get("dragon_name", "")
	stats.dragon_type = stats_data.get("dragon_type", 0)
	stats.level = stats_data.get("level", 1)
	stats.experience = stats_data.get("experience", 0.0)
	stats.satiety = stats_data.get("satiety", 100.0)
	stats.satisfaction = stats_data.get("satisfaction", 50.0)
	stats.energy = stats_data.get("energy", 100.0)
	stats.health = stats_data.get("health", 100.0)
	
	var personality_data = data.get("personality", {})
	personality.primary_trait = personality_data.get("primary_trait", 0)
	personality.secondary_trait = personality_data.get("secondary_trait", 0)
	personality.trait_intensity = personality_data.get("trait_intensity", 1.0)
	
	# NOVO: Carrega dados de decorações
	if personality_data.has("decoration_preferences"):
		personality.decoration_preferences = personality_data.decoration_preferences
	if personality_data.has("decoration_satisfaction"):
		personality.decoration_satisfaction = personality_data.decoration_satisfaction
	if personality_data.has("satisfaction_area_radius"):
		personality.satisfaction_area_radius = personality_data.satisfaction_area_radius

func take_damage(damage_amount: float):
	"""Recebe dano - Interface para o stats"""
	
	if stats:
		var actual_damage = stats.take_damage(damage_amount)
		
		# Efeito visual de dano
		flash_damage_effect()
		
		# Se morreu, remove do jogo
		if stats.is_dead():
			die()
		
		return actual_damage
	
	return 0.0

func flash_damage_effect():
	"""Efeito visual de dano"""
	
	# Pisca em branco por um momento
	modulate = Color.white
	
	# Cria um tween para voltar à cor normal
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "modulate", Color.white, Color.red, 0.2)
	tween.start()
	
	# Remove o tween depois de usar
	tween.connect("tween_completed", tween, "queue_free")

func die():
	"""Dragão morre"""
	
	print(stats.dragon_name, " morreu e será removido do jogo!")
	
	# Remove da lista de dragões ativos
	var manager = get_parent()
	if manager.has_method("remove_dragon"):
		manager.remove_dragon(self)
	else:
		queue_free()

func add_impulse(impulse: Vector2):
	"""NOVO: Adiciona impulso ao dragão (para empurrões)"""
	
	# Adiciona o impulso à velocidade atual
	velocity += impulse
	
	# Limita a velocidade máxima
	var max_impulse_speed = stats.get_effective_speed() * 3
	if velocity.length() > max_impulse_speed:
		velocity = velocity.normalized() * max_impulse_speed
