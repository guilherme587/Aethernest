# DragonPersonality.gd - Sistema baseado em quantidades ao invés de porcentagens
class_name DragonPersonality
extends Resource

var Enums = preload("res://scripts/utils/Enums.gd")

export var primary_trait: int = 0
export var secondary_trait: int = 0
export var trait_intensity: float = 1.0

# Preferências comportamentais existentes
export var territory_size: float = 200.0
export var social_distance: float = 100.0
export var exploration_range: float = 300.0
export var rest_frequency: float = 0.3

# === SISTEMA DE PREFERÊNCIAS DE DECORAÇÃO (NOVO: QUANTIDADES) ===

# Preferências por quantidade de cada categoria
var decoration_preferences: Dictionary = {}

# Quantidade total ideal de decorações (10-30)
var total_ideal_decorations: int = 15

# Satisfação atual com decorações (0-100)
var decoration_satisfaction: float = 50.0

# Área de influência para satisfação
var satisfaction_area_radius: float = 120.0

# Bonificadores de satisfação
var satisfaction_bonus_multiplier: float = 1.0

# Sinais
signal decoration_satisfaction_changed(new_value)
signal preferences_updated

func _init():
	generate_random_personality()
	generate_decoration_preferences()

func generate_random_personality():
	"""Gera personalidade aleatória"""
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	primary_trait = rng.randi_range(0, 7)
	secondary_trait = rng.randi_range(0, 7)
	
	if primary_trait == Enums.PersonalityTrait.SOCIAL and secondary_trait == Enums.PersonalityTrait.SOLITARY:
		secondary_trait = Enums.PersonalityTrait.PEACEFUL
	
	trait_intensity = rng.randf_range(0.7, 1.5)
	
	apply_personality_modifiers()

func apply_personality_modifiers():
	"""Aplica modificadores baseados na personalidade"""
	match primary_trait:
		Enums.PersonalityTrait.CURIOUS:
			exploration_range *= 1.5
			rest_frequency *= 0.7
			satisfaction_area_radius = 140.0
			total_ideal_decorations = 20  # Gosta de variedade
		Enums.PersonalityTrait.AGGRESSIVE:
			territory_size *= 1.3
			social_distance *= 1.4
			satisfaction_area_radius = 160.0
			total_ideal_decorations = 15  # Quantidade média
		Enums.PersonalityTrait.LAZY:
			exploration_range *= 0.6
			rest_frequency *= 1.8
			satisfaction_area_radius = 90.0
			total_ideal_decorations = 12  # Poucas decorações
		Enums.PersonalityTrait.SOLITARY:
			social_distance *= 2.0
			territory_size *= 0.8
			satisfaction_area_radius = 180.0
			total_ideal_decorations = 10  # Minimalista
		Enums.PersonalityTrait.SOCIAL:
			social_distance *= 0.5
			territory_size *= 0.7
			satisfaction_area_radius = 100.0
			total_ideal_decorations = 25  # Gosta de muitas decorações
		Enums.PersonalityTrait.TERRITORIAL:
			territory_size *= 1.8
			exploration_range *= 0.8
			satisfaction_area_radius = 200.0
			total_ideal_decorations = 18  # Quantidade boa
		Enums.PersonalityTrait.ENERGETIC:
			rest_frequency *= 0.4
			exploration_range *= 1.3
			satisfaction_area_radius = 130.0
			total_ideal_decorations = 22  # Gosta de movimento
		Enums.PersonalityTrait.PEACEFUL:
			satisfaction_area_radius = 110.0
			total_ideal_decorations = 16  # Quantidade equilibrada

func generate_decoration_preferences():
	"""NOVO: Gera preferências baseadas em quantidades"""
	
	decoration_preferences.clear()
	
	match primary_trait:
		Enums.PersonalityTrait.CURIOUS:
			# Gosta de variedade - distribuição equilibrada
			decoration_preferences = {
				"natureza": 7,      # 35% de 20
				"cristais": 5,      # 25% de 20
				"estruturas": 4,    # 20% de 20
				"pedras": 3,        # 15% de 20
				"agua": 1           # 5% de 20
			}
		
		Enums.PersonalityTrait.AGGRESSIVE:
			# Prefere pedras e estruturas imponentes
			decoration_preferences = {
				"pedras": 6,        # 40% de 15
				"estruturas": 5,    # 33% de 15
				"cristais": 2,      # 13% de 15
				"natureza": 1,      # 7% de 15
				"agua": 1           # 7% de 15
			}
		
		Enums.PersonalityTrait.LAZY:
			# Quer conforto e natureza
			decoration_preferences = {
				"natureza": 6,      # 50% de 12
				"agua": 3,          # 25% de 12
				"pedras": 2,        # 17% de 12
				"estruturas": 1,    # 8% de 12
				"cristais": 0       # 0% de 12
			}
		
		Enums.PersonalityTrait.SOLITARY:
			# Prefere elementos naturais isolados
			decoration_preferences = {
				"natureza": 5,      # 50% de 10
				"pedras": 2,        # 20% de 10
				"agua": 2,          # 20% de 10
				"cristais": 1,      # 10% de 10
				"estruturas": 0     # 0% de 10
			}
		
		Enums.PersonalityTrait.SOCIAL:
			# Gosta de estruturas e variedade para socializar
			decoration_preferences = {
				"estruturas": 9,    # 36% de 25
				"natureza": 8,      # 32% de 25
				"cristais": 4,      # 16% de 25
				"agua": 2,          # 8% de 25
				"pedras": 2         # 8% de 25
			}
		
		Enums.PersonalityTrait.TERRITORIAL:
			# Quer marcos territoriais
			decoration_preferences = {
				"estruturas": 8,    # 44% de 18
				"pedras": 5,        # 28% de 18
				"cristais": 3,      # 17% de 18
				"natureza": 1,      # 6% de 18
				"agua": 1           # 6% de 18
			}
		
		Enums.PersonalityTrait.PEACEFUL:
			# Ama natureza e água
			decoration_preferences = {
				"natureza": 6,      # 38% de 16
				"agua": 5,          # 31% de 16
				"cristais": 2,      # 13% de 16
				"pedras": 2,        # 13% de 16
				"estruturas": 1     # 6% de 16
			}
		
		Enums.PersonalityTrait.ENERGETIC:
			# Gosta de tudo um pouco, mas com foco em ação
			decoration_preferences = {
				"estruturas": 6,    # 27% de 22
				"natureza": 5,      # 23% de 22
				"cristais": 4,      # 18% de 22
				"pedras": 4,        # 18% de 22
				"agua": 3           # 14% de 22
			}
		
		_:
			# Preferências neutras
			decoration_preferences = {
				"natureza": 4,
				"pedras": 4,
				"estruturas": 3,
				"cristais": 2,
				"agua": 2
			}
			total_ideal_decorations = 15
	
	# Adiciona variação aleatória (±1-2 itens)
	add_quantity_variation()
	
	emit_signal("preferences_updated")

func add_quantity_variation():
	"""Adiciona variação aleatória às quantidades"""
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Aplica variação aleatória pequena
	for category in decoration_preferences:
		var current_value = decoration_preferences[category]
		var variation = rng.randi_range(-1, 2)  # -1, 0, 1, ou 2
		var new_value = max(0, current_value + variation)
		decoration_preferences[category] = new_value
	
	# Recalcula total ideal baseado nas preferências atuais
	var new_total = 0
	for category in decoration_preferences:
		new_total += decoration_preferences[category]
	
	# Mantém dentro da faixa 10-30
	# warning-ignore:narrowing_conversion
	total_ideal_decorations = clamp(new_total, 10, 30)

func calculate_decoration_satisfaction(dragon_position: Vector2, decoration_nodes: Array = []) -> float:
	"""NOVO: Calcula satisfação baseada em quantidades ao invés de porcentagens"""
	
	var decorations_in_area = get_decorations_in_area(dragon_position, decoration_nodes)
	var category_counts = count_decorations_by_category(decorations_in_area)
	var total_decorations = decorations_in_area.size()
	
	if total_decorations == 0:
		return 0.0
	
	var satisfaction = 0.0
	var total_weight = 0.0
	
	# Calcula satisfação para cada categoria baseada em quão próximo está do ideal
	for category in decoration_preferences:
		var ideal_quantity = decoration_preferences[category]
		var actual_quantity = category_counts.get(category, 0)
		
		if ideal_quantity == 0:
			# Se não quer nenhuma desta categoria, penaliza se tiver
			if actual_quantity == 0:
				continue  # Perfeito, não quer e não tem
			else:
				satisfaction -= actual_quantity * 5  # Penaliza por ter o que não quer
		else:
			# Calcula quão próximo está do ideal
			var difference = abs(ideal_quantity - actual_quantity)
			var max_possible_difference = ideal_quantity  # Pior caso seria ter 0 quando quer ideal_quantity
			
			# Satisfação desta categoria (100% quando exact, 0% quando muito longe)
			var category_satisfaction = max(0.0, 100.0 - (difference * 100.0 / max_possible_difference))
			
			# Peso baseado na importância (quantas decorações desta categoria quer)
			var weight = float(ideal_quantity) / float(total_ideal_decorations)
			
			satisfaction += category_satisfaction * weight
			total_weight += weight
	
	# Normaliza satisfação
	if total_weight > 0:
		satisfaction = satisfaction / total_weight * satisfaction_bonus_multiplier
	
	# Bonificação/penalização por quantidade total
	var quantity_bonus = calculate_total_quantity_bonus(total_decorations)
	satisfaction *= quantity_bonus
	
	return clamp(satisfaction, 0.0, 100.0)

func calculate_total_quantity_bonus(actual_total: int) -> float:
	"""Calcula bonus baseado na quantidade total de decorações"""
	
	if total_ideal_decorations == 0:
		return 1.0
	
	var ratio = float(actual_total) / float(total_ideal_decorations)
	
	if ratio < 0.3:
		# Muito poucas decorações
		return 0.3 + ratio * 0.7  # 0.3 a 0.51
	elif ratio > 2.0:
		# Muitas decorações
		return max(0.4, 1.0 - (ratio - 2.0) * 0.3)  # Diminui gradualmente
	else:
		# Quantidade boa (30% a 200% do ideal)
		return min(1.0, 0.5 + ratio * 0.5)  # 0.65 a 1.0

func get_decorations_in_area(center_position: Vector2, decoration_nodes: Array) -> Array:
	"""Retorna decorações na área de satisfação do dragão"""
	
	var decorations = []
	
	for decoration in decoration_nodes:
		if is_instance_valid(decoration):
			var distance = decoration.global_position.distance_to(center_position)
			if distance <= satisfaction_area_radius:
				decorations.append(decoration)
	
	return decorations

func count_decorations_by_category(decorations: Array) -> Dictionary:
	"""Conta decorações por categoria"""
	
	var counts = {}
	
	for decoration in decorations:
		if decoration.has_method("get") or "item_category" in decoration:
			var category = decoration.item_category
			counts[category] = counts.get(category, 0) + 1
	
	return counts

func update_decoration_satisfaction(dragon_position: Vector2, decoration_nodes: Array = []):
	"""Atualiza satisfação com decorações"""
	
	var new_satisfaction = calculate_decoration_satisfaction(dragon_position, decoration_nodes)
	
	if abs(new_satisfaction - decoration_satisfaction) > 1.0:
		decoration_satisfaction = new_satisfaction
		emit_signal("decoration_satisfaction_changed", decoration_satisfaction)

# === FUNÇÕES EXISTENTES MANTIDAS ===

func get_speed_modifier() -> float:
	"""Retorna modificador de velocidade baseado na personalidade"""
	var modifier = 1.0
	
	match primary_trait:
		Enums.PersonalityTrait.LAZY:
			modifier *= 0.7
		Enums.PersonalityTrait.ENERGETIC:
			modifier *= 1.3
		Enums.PersonalityTrait.AGGRESSIVE:
			modifier *= 1.1
	
	return modifier * trait_intensity

func get_aggression_level() -> float:
	"""Retorna nível de agressividade (0-1)"""
	var aggression = 0.1
	
	match primary_trait:
		Enums.PersonalityTrait.AGGRESSIVE:
			aggression = 0.8
		Enums.PersonalityTrait.TERRITORIAL:
			aggression = 0.6
		Enums.PersonalityTrait.PEACEFUL:
			aggression = 0.05
	
	if secondary_trait == Enums.PersonalityTrait.AGGRESSIVE:
		aggression += 0.2
	
	return clamp(aggression * trait_intensity, 0.0, 1.0)

func should_rest() -> bool:
	"""Determina se o dragão deve descansar baseado na personalidade"""
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randf() < rest_frequency

func get_preferred_distance_from_others() -> float:
	"""Retorna distância preferida de outros dragões"""
	return social_distance * trait_intensity

func get_personality_description() -> String:
	"""Retorna descrição textual da personalidade"""
	var primary_name = get_trait_name(primary_trait)
	var secondary_name = get_trait_name(secondary_trait)
	
	var intensity_desc = ""
	if trait_intensity > 1.3:
		intensity_desc = "muito "
	elif trait_intensity < 0.8:
		intensity_desc = "levemente "
	
	return intensity_desc + primary_name + " e " + secondary_name

func get_trait_name(trait: int) -> String:
	"""Converte enum para nome legível"""
	match trait:
		Enums.PersonalityTrait.CURIOUS:
			return "curioso"
		Enums.PersonalityTrait.AGGRESSIVE:
			return "agressivo"
		Enums.PersonalityTrait.LAZY:
			return "preguiçoso"
		Enums.PersonalityTrait.SOLITARY:
			return "solitário"
		Enums.PersonalityTrait.SOCIAL:
			return "sociável"
		Enums.PersonalityTrait.TERRITORIAL:
			return "territorial"
		Enums.PersonalityTrait.PEACEFUL:
			return "pacífico"
		Enums.PersonalityTrait.ENERGETIC:
			return "energético"
		_:
			return "misterioso"

# === NOVAS FUNÇÕES PARA DECORAÇÕES (ATUALIZADA PARA QUANTIDADES) ===

func get_decoration_preferences_text() -> String:
	"""NOVO: Retorna texto das preferências mostrando quantidades e porcentagens"""
	
	var text = "Preferências de Decoração:\n"
	text += "(Total ideal: " + str(total_ideal_decorations) + " decorações)\n\n"
	
	# Ordena por quantidade (maior para menor)
	var sorted_preferences = []
	for category in decoration_preferences:
		var quantity = decoration_preferences[category]
		var percentage = 0.0
		if total_ideal_decorations > 0:
			percentage = (float(quantity) / float(total_ideal_decorations)) * 100.0
		
		sorted_preferences.append({
			"category": category,
			"quantity": quantity,
			"percentage": percentage
		})
	
	sorted_preferences.sort_custom(self, "_sort_preferences_by_quantity")
	
	# Adiciona cada preferência ao texto
	for pref in sorted_preferences:
		if pref.quantity > 0:  # Só mostra categorias que o dragão quer
			var category_name = get_category_display_name(pref.category)
			var quantity = pref.quantity
			var percentage = int(pref.percentage)
			text += "• " + category_name + ": " + str(quantity) + " unidades (" + str(percentage) + "%)\n"
	
	return text

func _sort_preferences_by_quantity(a: Dictionary, b: Dictionary) -> bool:
	"""Função de ordenação para preferências por quantidade"""
	return a.quantity > b.quantity

func get_category_display_name(category: String) -> String:
	"""Retorna nome amigável da categoria"""
	
	match category:
		"natureza":
			return "Vegetação"
		"pedras":
			return "Pedras"
		"cristais":
			return "Cristais"
		"agua":
			return "Água"
		"estruturas":
			return "Estruturas"
		_:
			return category.capitalize()

func get_satisfaction_status_text() -> String:
	"""Retorna texto do status de satisfação"""
	
	var status = ""
	
	if decoration_satisfaction >= 80:
		status = "Muito Satisfeito"
	elif decoration_satisfaction >= 60:
		status = "Satisfeito"
	elif decoration_satisfaction >= 40:
		status = "Neutro"
	elif decoration_satisfaction >= 20:
		status = "Insatisfeito"
	else:
		status = "Muito Insatisfeito"
	
	return "Satisfação com Decorações: " + str(int(decoration_satisfaction)) + "% (" + status + ")"

func get_satisfaction_area_radius() -> float:
	"""Retorna raio da área de satisfação"""
	return satisfaction_area_radius

func get_current_decoration_summary(dragon_position: Vector2, decoration_nodes: Array = []) -> String:
	"""NOVO: Retorna resumo das decorações atuais na área"""
	
	var decorations_in_area = get_decorations_in_area(dragon_position, decoration_nodes)
	var category_counts = count_decorations_by_category(decorations_in_area)
	var total_current = decorations_in_area.size()
	
	var text = "Decorações atuais na área (" + str(total_current) + "/" + str(total_ideal_decorations) + "):\n"
	
	for category in decoration_preferences:
		var ideal = decoration_preferences[category]
		var current = category_counts.get(category, 0)
		var category_name = get_category_display_name(category)
		
		if ideal > 0:  # Só mostra categorias que o dragão quer
			var status_icon = ""
			if current == ideal:
				status_icon = "✓"
			elif current < ideal:
				status_icon = "↑"
			else:
				status_icon = "↓"
			
			text += "• " + category_name + ": " + str(current) + "/" + str(ideal) + " " + status_icon + "\n"
	
	return text
