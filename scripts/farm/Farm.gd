# Farm.gd - Classe individual de fazenda
class_name Farm
extends StaticBody2D

# Propriedades da fazenda
var farm_type: int
var farm_level: int = 1
var farm_data: Dictionary
var current_state: int = 0  # FarmState.IDLE

# Produção
var production_timer: float = 0.0
var production_time: float = 30.0
var production_amount: int = 3
var storage_capacity: int = 15
var current_storage: int = 0

# Componentes visuais
var sprite: Sprite
var level_indicator: Label
var progress_bar: ProgressBar
var storage_label: Label

# Sinais
signal production_complete(farm, food_type, amount, level)
signal farm_clicked(farm)
signal farm_upgraded(farm, new_level)

func _ready():
	"""Inicialização da fazenda"""
	
	add_to_group("farms")
	
	# Configura colisão
	collision_layer = 8  # Layer para fazendas
	collision_mask = 0
	
	setup_visual_components()
	connect_signals()

func initialize_farm():
	"""Inicializa fazenda com dados específicos"""
	
	if farm_data.empty():
		print("Erro: Dados da fazenda não definidos")
		return
	
	update_farm_stats()
	start_production()

func update_farm_stats():
	"""Atualiza estatísticas baseadas no nível"""
	
	var level_data = farm_data.levels.get(farm_level, {})
	
	production_time = level_data.get("production_time", 30.0)
	production_amount = level_data.get("production_amount", 3)
	storage_capacity = level_data.get("storage_capacity", 15)
	
	update_visual_info()

func setup_visual_components():
	"""Configura componentes visuais"""
	
	# Sprite principal
	sprite = Sprite.new()
	sprite.name = "Sprite"
	add_child(sprite)
	
	# Indicador de nível
	level_indicator = Label.new()
	level_indicator.name = "LevelIndicator"
	level_indicator.align = Label.ALIGN_CENTER
	level_indicator.rect_position = Vector2(-15, -50)
	level_indicator.rect_size = Vector2(30, 20)
	level_indicator.add_color_override("font_color", Color.yellow)
	add_child(level_indicator)
	
	# Barra de progresso
	progress_bar = ProgressBar.new()
	progress_bar.name = "ProgressBar"
	progress_bar.rect_position = Vector2(-30, 35)
	progress_bar.rect_size = Vector2(60, 8)
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	add_child(progress_bar)
	
	# Label de armazenamento
	storage_label = Label.new()
	storage_label.name = "StorageLabel"
	storage_label.align = Label.ALIGN_CENTER
	storage_label.rect_position = Vector2(-25, 45)
	storage_label.rect_size = Vector2(50, 15)
	storage_label.add_color_override("font_color", Color.white)
	add_child(storage_label)
	
	# Colisão
	var collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(32, 32)
	collision_shape.shape = shape
	add_child(collision_shape)
	
	update_visual_appearance()

func update_visual_appearance():
	"""Atualiza aparência visual baseada no tipo e nível"""
	
	if not farm_data.empty():
		# Cor baseada no tipo
		var color = farm_data.get("color", Color.gray)
		modulate = color
		
		# Intensidade baseada no nível
		var intensity = 0.7 + (farm_level * 0.15)
		modulate = modulate * intensity
		
		# Tamanho baseado no nível
		var scale_factor = 0.8 + (farm_level * 0.1)
		scale = Vector2(scale_factor, scale_factor)

func update_visual_info():
	"""Atualiza informações visuais"""
	
	if level_indicator:
		level_indicator.text = "Lv." + str(farm_level)
	
	if storage_label:
		storage_label.text = str(current_storage) + "/" + str(storage_capacity)

func connect_signals():
	"""Conecta sinais"""
	
	connect("input_event", self, "_on_input_event")

func _on_input_event(viewport, event, shape_idx):
	"""Processa cliques na fazenda"""
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			emit_signal("farm_clicked", self)

func start_production():
	"""Inicia produção"""
	
	current_state = 1  # FarmState.PRODUCING
	production_timer = 0.0
	print("Fazenda iniciou produção: ", farm_data.get("name", "Unknown"))

func _process(delta):
	"""Atualiza produção"""
	
	if current_state == 1:  # PRODUCING
		production_timer += delta
		
		# Atualiza barra de progresso
		if progress_bar:
			var progress = (production_timer / production_time) * 100.0
			progress_bar.value = progress
		
		# Verifica se produção completou
		if production_timer >= production_time:
			complete_production()

func complete_production():
	"""Completa produção"""
	
	if current_storage >= storage_capacity:
		print("Armazenamento cheio! Produção perdida.")
		start_production()  # Recomeça produção
		return
	
	# Adiciona à capacidade local
	var produced = min(production_amount, storage_capacity - current_storage)
	current_storage += produced
	
	current_state = 2  # FarmState.READY
	
	# Emite sinal para manager
	var food_type = farm_data.get("food_type", "unknown")
	emit_signal("production_complete", self, food_type, produced, farm_level)
	
	update_visual_info()
	
	print("Produção completa: ", produced, "x ", food_type, " nível ", farm_level)
	
	# Inicia nova produção automaticamente
	call_deferred("start_production")

func collect_food() -> Dictionary:
	"""Coleta comida da fazenda"""
	
	if current_storage <= 0:
		return {}
	
	var collected = {
		"type": farm_data.get("food_type", "unknown"),
		"amount": current_storage,
		"level": farm_level
	}
	
	current_storage = 0
	update_visual_info()
	
	return collected

func can_upgrade() -> bool:
	"""Verifica se pode ser melhorada"""
	
	return farm_level < 3

func get_upgrade_cost() -> int:
	"""Retorna custo de melhoria"""
	
	var level_data = farm_data.levels.get(farm_level, {})
	return level_data.get("upgrade_cost", 0)

func upgrade_farm() -> bool:
	"""Melhora a fazenda"""
	
	if not can_upgrade():
		return false
	
	farm_level += 1
	update_farm_stats()
	update_visual_appearance()
	
	emit_signal("farm_upgraded", self, farm_level)
	
	print("Fazenda melhorada para nível ", farm_level)
	return true

func get_storage_capacity() -> int:
	"""Retorna capacidade de armazenamento"""
	return storage_capacity

func get_farm_info() -> Dictionary:
	"""Retorna informações da fazenda"""
	
	return {
		"type": farm_type,
		"level": farm_level,
		"name": farm_data.get("name", "Unknown"),
		"food_type": farm_data.get("food_type", "unknown"),
		"production_time": production_time,
		"production_amount": production_amount,
		"storage_capacity": storage_capacity,
		"current_storage": current_storage,
		"upgrade_cost": get_upgrade_cost(),
		"can_upgrade": can_upgrade()
	}

func save_farm_data() -> Dictionary:
	"""Salva dados da fazenda"""
	
	return {
		"position": global_position,
		"farm_type": farm_type,
		"farm_level": farm_level,
		"current_storage": current_storage,
		"production_timer": production_timer
	}

func load_farm_data(data: Dictionary):
	"""Carrega dados da fazenda"""
	
	global_position = data.get("position", Vector2.ZERO)
	farm_type = data.get("farm_type", 0)
	farm_level = data.get("farm_level", 1)
	current_storage = data.get("current_storage", 0)
	production_timer = data.get("production_timer", 0.0)
	
	update_farm_stats()
	update_visual_appearance()
