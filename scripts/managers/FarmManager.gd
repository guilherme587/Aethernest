# FarmManager.gd - Sistema completo de fazendas
class_name FarmManager
extends Node2D

# Tipos de fazenda
enum FarmType {
	FISH_FARM,      # 0
	MEAT_FARM,      # 1
	VEGETABLE_FARM, # 2
	MINERAL_FARM,   # 3
	MAGICAL_FARM,   # 4
	INSECT_FARM,    # 5
	FRUIT_FARM,     # 6 - NOVO TIPO
	DAIRY_FARM,     # 7 - NOVO TIPO
	HONEY_FARM      # 8 - NOVO TIPO
}

# Estados da fazenda
enum FarmState {
	IDLE,           # Parada
	PRODUCING,      # Produzindo
	READY,          # Pronta para coleta
	UPGRADING       # Sendo melhorada
}

# Inventário global de alimentos
var food_inventory: Dictionary = {
	"fish": {"level_1": 0, "level_2": 0, "level_3": 0},
	"meat": {"level_1": 0, "level_2": 0, "level_3": 0},
	"vegetable": {"level_1": 0, "level_2": 0, "level_3": 0},
	"mineral": {"level_1": 0, "level_2": 0, "level_3": 0},
	"magical": {"level_1": 0, "level_2": 0, "level_3": 0},
	"insect": {"level_1": 0, "level_2": 0, "level_3": 0},
	"fruit": {"level_1": 0, "level_2": 0, "level_3": 0},     # NOVO
	"dairy": {"level_1": 0, "level_2": 0, "level_3": 0},     # NOVO
	"honey": {"level_1": 0, "level_2": 0, "level_3": 0}      # NOVO
}

# Lista de fazendas ativas
var active_farms: Array = []

# UI
var farm_ui: FarmUI
var ui_canvas_layer: CanvasLayer
var inventory_ui: FoodInventoryUI

# Configurações
var is_farm_mode: bool = false
var placement_farm_type: int = -1

# Data dos tipos de fazenda
var farm_data: Dictionary = {}

# Sinais
signal farm_placed(farm)
signal food_produced(farm, food_type, amount)
signal inventory_updated

func _ready():
	"""Inicialização do sistema de fazendas"""
	
	setup_farm_data()
	setup_ui()
	
	print("FarmManager inicializado")

func setup_farm_data():
	"""Configura dados das fazendas"""
	
	farm_data = {
		FarmType.FISH_FARM: {
			"name": "Fazenda de Peixes",
			"description": "Produz peixes nutritivos que aumentam força e agressividade",
			"food_type": "fish",
			"icon": "🐟fish",
			"color": Color.blue,
			"levels": {
				1: {
					"production_time": 30.0,     # 30 segundos
					"production_amount": 3,       # 3 peixes por ciclo
					"storage_capacity": 15,       # Máximo 15 peixes
					"upgrade_cost": 100
				},
				2: {
					"production_time": 20.0,     # 20 segundos
					"production_amount": 5,       # 5 peixes por ciclo
					"storage_capacity": 30,       # Máximo 30 peixes
					"upgrade_cost": 250
				},
				3: {
					"production_time": 15.0,     # 15 segundos
					"production_amount": 8,       # 8 peixes por ciclo
					"storage_capacity": 50,       # Máximo 50 peixes
					"upgrade_cost": 0            # Nível máximo
				}
			}
		},
		
		FarmType.MEAT_FARM: {
			"name": "Fazenda de Carnes",
			"description": "Produz carnes que restauram muita vida",
			"food_type": "meat",
			"icon": "🥩meat",
			"color": Color.red,
			"levels": {
				1: {
					"production_time": 45.0,
					"production_amount": 2,
					"storage_capacity": 10,
					"upgrade_cost": 150
				},
				2: {
					"production_time": 30.0,
					"production_amount": 4,
					"storage_capacity": 20,
					"upgrade_cost": 300
				},
				3: {
					"production_time": 20.0,
					"production_amount": 6,
					"storage_capacity": 35,
					"upgrade_cost": 0
				}
			}
		},
		
		FarmType.VEGETABLE_FARM: {
			"name": "Fazenda de Vegetais",
			"description": "Produz vegetais que acalmam e reduzem agressividade",
			"food_type": "vegetable",
			"icon": "vegetable🥬",
			"color": Color.green,
			"levels": {
				1: {
					"production_time": 25.0,
					"production_amount": 4,
					"storage_capacity": 20,
					"upgrade_cost": 80
				},
				2: {
					"production_time": 18.0,
					"production_amount": 6,
					"storage_capacity": 35,
					"upgrade_cost": 200
				},
				3: {
					"production_time": 12.0,
					"production_amount": 10,
					"storage_capacity": 60,
					"upgrade_cost": 0
				}
			}
		},
		
		FarmType.MINERAL_FARM: {
			"name": "Fazenda de Minérios",
			"description": "Produz cristais que restauram energia rapidamente",
			"food_type": "mineral",
			"icon": "💎mineral",
			"color": Color.purple,
			"levels": {
				1: {
					"production_time": 60.0,
					"production_amount": 2,
					"storage_capacity": 8,
					"upgrade_cost": 200
				},
				2: {
					"production_time": 40.0,
					"production_amount": 3,
					"storage_capacity": 15,
					"upgrade_cost": 400
				},
				3: {
					"production_time": 25.0,
					"production_amount": 5,
					"storage_capacity": 25,
					"upgrade_cost": 0
				}
			}
		},
		
		FarmType.MAGICAL_FARM: {
			"name": "Fazenda Mágica",
			"description": "Produz alimentos mágicos com múltiplos benefícios",
			"food_type": "magical",
			"icon": "magical✨",
			"color": Color.gold,
			"levels": {
				1: {
					"production_time": 90.0,
					"production_amount": 1,
					"storage_capacity": 5,
					"upgrade_cost": 500
				},
				2: {
					"production_time": 60.0,
					"production_amount": 2,
					"storage_capacity": 8,
					"upgrade_cost": 1000
				},
				3: {
					"production_time": 40.0,
					"production_amount": 3,
					"storage_capacity": 12,
					"upgrade_cost": 0
				}
			}
		},
		
		FarmType.INSECT_FARM: {
			"name": "Fazenda de Insetos",
			"description": "Produz insetos ricos em proteína que aumentam velocidade",
			"food_type": "insect",
			"icon": "🦗insect",
			"color": Color.orange,
			"levels": {
				1: {
					"production_time": 20.0,
					"production_amount": 5,
					"storage_capacity": 25,
					"upgrade_cost": 120
				},
				2: {
					"production_time": 15.0,
					"production_amount": 8,
					"storage_capacity": 40,
					"upgrade_cost": 280
				},
				3: {
					"production_time": 10.0,
					"production_amount": 12,
					"storage_capacity": 70,
					"upgrade_cost": 0
				}
			}
		},
		
		# NOVA FAZENDA: Frutas
		FarmType.FRUIT_FARM: {
			"name": "Fazenda de Frutas",
			"description": "Produz frutas doces que aumentam satisfação e energia",
			"food_type": "fruit",
			"icon": "🍎fruit",
			"color": Color(1.0, 0.5, 0.0),  # Laranja
			"levels": {
				1: {
					"production_time": 35.0,     # 35 segundos
					"production_amount": 4,       # 4 frutas por ciclo
					"storage_capacity": 18,       # Máximo 18 frutas
					"upgrade_cost": 90
				},
				2: {
					"production_time": 25.0,     # 25 segundos
					"production_amount": 6,       # 6 frutas por ciclo
					"storage_capacity": 32,       # Máximo 32 frutas
					"upgrade_cost": 220
				},
				3: {
					"production_time": 18.0,     # 18 segundos
					"production_amount": 9,       # 9 frutas por ciclo
					"storage_capacity": 55,       # Máximo 55 frutas
					"upgrade_cost": 0            # Nível máximo
				}
			}
		},
		
		# NOVA FAZENDA: Laticínios
		FarmType.DAIRY_FARM: {
			"name": "Fazenda de Laticínios",
			"description": "Produz leite e queijos que fortalecem ossos e aumentam defesa",
			"food_type": "dairy",
			"icon": "dairy",
			"color": Color(0.9, 0.9, 0.7),  # Bege claro
			"levels": {
				1: {
					"production_time": 50.0,
					"production_amount": 2,
					"storage_capacity": 12,
					"upgrade_cost": 160
				},
				2: {
					"production_time": 35.0,
					"production_amount": 4,
					"storage_capacity": 22,
					"upgrade_cost": 320
				},
				3: {
					"production_time": 25.0,
					"production_amount": 6,
					"storage_capacity": 40,
					"upgrade_cost": 0
				}
			}
		},
		
		# NOVA FAZENDA: Mel
		FarmType.HONEY_FARM: {
			"name": "Fazenda de Mel",
			"description": "Produz mel puro que cura venenos e aumenta regeneração",
			"food_type": "honey",
			"icon": "🍯honey",
			"color": Color(1.0, 0.8, 0.0),  # Dourado
			"levels": {
				1: {
					"production_time": 70.0,
					"production_amount": 1,
					"storage_capacity": 6,
					"upgrade_cost": 180
				},
				2: {
					"production_time": 50.0,
					"production_amount": 2,
					"storage_capacity": 10,
					"upgrade_cost": 360
				},
				3: {
					"production_time": 35.0,
					"production_amount": 3,
					"storage_capacity": 18,
					"upgrade_cost": 0
				}
			}
		}
	}

func setup_ui():
	"""Configura interfaces do usuário"""
	
	# Canvas layer para UIs
	ui_canvas_layer = CanvasLayer.new()
	ui_canvas_layer.name = "FarmUI_Layer"
	ui_canvas_layer.layer = 90
	get_tree().current_scene.add_child(ui_canvas_layer)
	
	# UI principal de fazendas
	farm_ui = preload("res://scripts/ui/FarmUI.gd").new()
	farm_ui.connect("farm_type_selected", self, "_on_farm_type_selected")
	farm_ui.connect("farm_mode_exit", self, "_on_farm_mode_exit")
	ui_canvas_layer.add_child(farm_ui)
	
	# UI de inventário de alimentos
	inventory_ui = preload("res://scripts/ui/FoodInventoryUI.gd").new()
	inventory_ui.connect("food_used", self, "_on_food_used")
	inventory_ui.connect("inventory_closed", self, "_on_inventory_closed")
	ui_canvas_layer.add_child(inventory_ui)

func _input(event):
	"""Processa inputs globais"""
	
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_F:  # Abre modo fazenda
				toggle_farm_mode()
			KEY_I:  # Abre inventário
				toggle_inventory()
			KEY_ESCAPE:
				if is_farm_mode:
					exit_farm_mode()

func toggle_farm_mode():
	"""Alterna modo de fazenda"""
	
	if is_farm_mode:
		exit_farm_mode()
	else:
		enter_farm_mode()

func enter_farm_mode():
	"""Entra no modo fazenda"""
	
	is_farm_mode = true
	farm_ui.show_ui()
	print("Modo fazenda ativado")

func exit_farm_mode():
	"""Sai do modo fazenda"""
	
	is_farm_mode = false
	placement_farm_type = -1
	farm_ui.hide_ui()
	print("Modo fazenda desativado")

func toggle_inventory():
	"""Alterna inventário de alimentos"""
	
	if inventory_ui.visible:
		inventory_ui.hide_ui()
	else:
		inventory_ui.show_ui(food_inventory)

func _on_farm_type_selected(farm_type: int):
	"""Tipo de fazenda selecionado para colocação"""
	
	placement_farm_type = farm_type
	print("Selecionado para colocação: ", get_farm_name(farm_type))

func _on_farm_mode_exit():
	"""Sair do modo fazenda"""
	exit_farm_mode()

func _on_inventory_closed():
	"""Inventário fechado"""
	pass

func _on_food_used(food_type: String, level: int, amount: int):
	"""Alimento usado do inventário"""
	
	var level_key = "level_" + str(level)
	if food_inventory.has(food_type) and food_inventory[food_type].has(level_key):
		food_inventory[food_type][level_key] = max(0, food_inventory[food_type][level_key] - amount)
		emit_signal("inventory_updated")
		print("Usado: ", amount, "x ", food_type, " nível ", level)

func handle_farm_placement(event):
	"""Processa colocação de fazendas"""
	
	if not is_farm_mode or placement_farm_type == -1:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		place_farm_at_mouse()

func place_farm_at_mouse():
	"""Coloca fazenda na posição do mouse"""
	
	var mouse_pos = get_global_mouse_position()
	
	# Verifica se posição é válida (não muito próximo de outras fazendas)
	if not is_farm_position_valid(mouse_pos):
		print("Posição inválida para fazenda")
		return
	
	var farm = create_farm(placement_farm_type, mouse_pos)
	if farm:
		get_tree().current_scene.add_child(farm)
		active_farms.append(farm)
		
		farm.connect("production_complete", self, "_on_farm_production_complete")
		farm.connect("farm_clicked", self, "_on_farm_clicked")
		
		emit_signal("farm_placed", farm)
		print("Fazenda colocada: ", get_farm_name(placement_farm_type))

func is_farm_position_valid(position: Vector2) -> bool:
	"""Verifica se posição é válida para fazenda"""
	
	var min_distance = 100.0
	
	for farm in active_farms:
		if is_instance_valid(farm):
			if farm.global_position.distance_to(position) < min_distance:
				return false
	
	return true

func create_farm(farm_type: int, position: Vector2):
	"""Cria uma nova fazenda"""
	
	var farm = preload("res://scripts/farm/Farm.gd").new()
	
	farm.global_position = position
	farm.farm_type = farm_type
	farm.farm_level = 1
	farm.farm_data = farm_data[farm_type]
	
	farm.initialize_farm()
	
	return farm

func _on_farm_production_complete(farm, food_type: String, amount: int, level: int):
	"""Produção de fazenda completa"""
	
	var level_key = "level_" + str(level)
	
	# Verifica capacidade de armazenamento
	var current_amount = food_inventory[food_type][level_key]
	var max_storage = get_max_storage_for_food(food_type, level)
	
	if current_amount + amount <= max_storage:
		# Adiciona ao inventário
		food_inventory[food_type][level_key] += amount
		emit_signal("food_produced", farm, food_type, amount)
		emit_signal("inventory_updated")
		print("Produzido: ", amount, "x ", food_type, " nível ", level)
	else:
		# Armazenamento lotado, comida estraga
		var spoiled = amount - (max_storage - current_amount)
		food_inventory[food_type][level_key] = max_storage
		emit_signal("inventory_updated")
		print("ATENÇÃO: ", spoiled, " ", food_type, " estragaram por falta de espaço!")

func get_max_storage_for_food(food_type: String, level: int) -> int:
	"""Retorna capacidade máxima de armazenamento global para um tipo de comida"""
	
	var total_capacity = 0
	
	# Soma capacidade de todas as fazendas do mesmo tipo
	for farm in active_farms:
		if is_instance_valid(farm) and farm.farm_data.food_type == food_type:
			total_capacity += farm.get_storage_capacity()
	
	return int(max(100, total_capacity))  # Mínimo 100 por tipo

func _on_farm_clicked(farm):
	"""Fazenda foi clicada"""
	
	# Abre interface da fazenda específica
	farm_ui.show_farm_details(farm)

func get_farm_name(farm_type: int) -> String:
	"""Retorna nome da fazenda"""
	
	if farm_data.has(farm_type):
		return farm_data[farm_type].name
	return "Fazenda Desconhecida"

func get_food_effects(food_type: String, level: int) -> Dictionary:
	"""Retorna efeitos do alimento no dragão"""
	
	var base_effects = {
		"fruit": {
			"health_restore": 18,
			"satisfaction_boost": 30,
			"energy_restore": 20,
			"speed_boost": 5,
			"duration": 70.0
		},
		"dairy": {
			"health_restore": 25,
			"defense_boost": 20,
			"strength_boost": 8,
			"bone_strength": 15,
			"duration": 100.0
		},
		"honey": {
			"health_restore": 35,
			"poison_cure": 100,
			"regeneration_boost": 25,
			"energy_restore": 15,
			"duration": 150.0
		},
		"fish": {
			"health_restore": 20,
			"strength_boost": 15,
			"aggression_boost": 20,
			"duration": 60.0
		},
		"meat": {
			"health_restore": 40,
			"strength_boost": 10,
			"energy_restore": 10,
			"duration": 45.0
		},
		"vegetable": {
			"health_restore": 15,
			"aggression_reduction": 30,
			"satisfaction_boost": 25,
			"duration": 90.0
		},
		"mineral": {
			"health_restore": 10,
			"energy_restore": 50,
			"speed_boost": 10,
			"duration": 120.0
		},
		"magical": {
			"health_restore": 60,
			"energy_restore": 40,
			"all_stats_boost": 20,
			"duration": 180.0
		},
		"insect": {
			"health_restore": 12,
			"speed_boost": 25,
			"energy_restore": 15,
			"duration": 75.0
		}
	}
	
	var effects = base_effects.get(food_type, {})
	
	# Multiplica efeitos baseado no nível
	var level_multiplier = 1.0 + (level - 1) * 0.5  # Nível 1: 1.0x, Nível 2: 1.5x, Nível 3: 2.0x
	
	for effect in effects:
		if effect != "duration":
			effects[effect] = int(effects[effect] * level_multiplier)
	
	return effects

func feed_dragon(dragon, food_type: String, level: int):
	"""Alimenta um dragão com comida específica"""
	
	var level_key = "level_" + str(level)
	
	# Verifica se tem comida
	if food_inventory[food_type][level_key] <= 0:
		print("Não há ", food_type, " nível ", level, " disponível")
		return false
	
	# Aplica efeitos
	var effects = get_food_effects(food_type, level)
	apply_food_effects(dragon, effects)
	
	# Remove do inventário
	food_inventory[food_type][level_key] -= 1
	emit_signal("inventory_updated")
	
	print("Dragão alimentado com ", food_type, " nível ", level)
	return true

func apply_food_effects(dragon, effects: Dictionary):
	"""Aplica efeitos da comida no dragão"""
	
	if not dragon or not dragon.stats:
		return
	
	# Efeitos imediatos
	if effects.has("health_restore"):
		dragon.stats.health = min(dragon.stats.max_health, dragon.stats.health + effects.health_restore)
	
	if effects.has("energy_restore"):
		dragon.stats.energy = min(dragon.stats.max_energy, dragon.stats.energy + effects.energy_restore)
	
	# Efeitos temporários (implementar sistema de buffs)
	if effects.has("strength_boost"):
		apply_temporary_buff(dragon, "strength", effects.strength_boost, effects.get("duration", 60.0))
	
	if effects.has("speed_boost"):
		apply_temporary_buff(dragon, "speed", effects.speed_boost, effects.get("duration", 60.0))
	
	if effects.has("aggression_boost"):
		apply_temporary_buff(dragon, "aggression", effects.aggression_boost, effects.get("duration", 60.0))
	
	if effects.has("aggression_reduction"):
		apply_temporary_buff(dragon, "aggression", -effects.aggression_reduction, effects.get("duration", 60.0))
	
	if effects.has("satisfaction_boost"):
		dragon.stats.modify_satisfaction(effects.satisfaction_boost)

func apply_temporary_buff(dragon, stat_type: String, value: int, duration: float):
	"""Aplica buff temporário (implementar sistema de buffs completo depois)"""
	
	# Por enquanto, aplica efeito direto
	match stat_type:
		"strength":
			dragon.stats.strength += value
		"speed":
			dragon.stats.base_speed += value
		"aggression":
			if dragon.personality:
				# Simula mudança temporária de agressividade
				pass
	
	print("Buff aplicado: ", stat_type, " +", value, " por ", duration, "s")

func save_farm_data() -> Dictionary:
	"""Salva dados das fazendas"""
	
	var save_data = {
		"food_inventory": food_inventory,
		"farms": []
	}
	
	for farm in active_farms:
		if is_instance_valid(farm):
			save_data.farms.append(farm.save_farm_data())
	
	return save_data

func load_farm_data(data: Dictionary):
	"""Carrega dados das fazendas"""
	
	if data.has("food_inventory"):
		food_inventory = data.food_inventory
		emit_signal("inventory_updated")
	
	if data.has("farms"):
		for farm_data in data.farms:
			# Recriar fazendas salvas
			pass
