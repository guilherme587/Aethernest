# DecorationItem.gd - Item decorativo base (versão corrigida)
class_name DecorationItem
extends StaticBody2D

# Propriedades do item
export var item_name: String = "Decoração"
export var item_description: String = "Um item decorativo"
export var item_price: int = 10
export var item_category: String = "geral"
export var can_rotate: bool = true
export var snap_to_grid: bool = false
export var grid_size: int = 32

# Estados
var is_selected: bool = false
var is_placement_mode: bool = false

# Componentes visuais
var sprite: Sprite
var selection_outline: Node2D
var collision_shape: CollisionShape2D

# Sinais
signal item_clicked(item)
signal item_deleted(item)

func _ready():
	"""Inicialização do item decorativo"""
	
	# Configura collision layer para decorações
	collision_layer = 4  # Layer 3 para decorações
	collision_mask = 0   # Não colide com nada
	
	# Busca componentes - CORRIGIDO
	call_deferred("setup_components")

func setup_components():
	"""Configura componentes após a árvore estar pronta"""
	
	# Busca componentes
	sprite = get_node_or_null("Sprite")
	collision_shape = get_node_or_null("CollisionShape2D")
	
	# Cria outline de seleção
	create_selection_outline()
	
	# Conecta sinais
	if not is_connected("input_event", self, "_on_input_event"):
		connect("input_event", self, "_on_input_event")
	
	# Estado inicial
	set_selected(false)
	
	# Adiciona ao grupo de decorações
	add_to_group("decorations")

func create_selection_outline():
	"""Cria o outline de seleção"""
	
	selection_outline = Node2D.new()
	selection_outline.name = "SelectionOutline"
	add_child(selection_outline)
	
	# Se tem sprite, cria outline baseado nele
	if sprite and sprite.texture:
		var outline_sprite = Sprite.new()
		outline_sprite.texture = sprite.texture
		outline_sprite.modulate = Color.cyan
		outline_sprite.modulate.a = 0.5
		outline_sprite.scale = Vector2(1.1, 1.1)
		selection_outline.add_child(outline_sprite)
	else:
		# Outline genérico se não tem sprite
		var outline_rect = ColorRect.new()
		outline_rect.color = Color.cyan
		outline_rect.color.a = 0.3
		outline_rect.rect_size = Vector2(70, 70)
		outline_rect.rect_position = Vector2(-35, -35)
		selection_outline.add_child(outline_rect)
	
	selection_outline.visible = false

func _on_input_event(viewport, event, shape_idx):
	"""Processa eventos de input no item"""
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			emit_signal("item_clicked", self)
		elif event.button_index == BUTTON_RIGHT:
			delete_item()

func set_selected(selected: bool):
	"""Define se o item está selecionado"""
	
	is_selected = selected
	
	if selection_outline:
		selection_outline.visible = selected
	
	if selected:
		modulate = Color(1.2, 1.2, 1.2)
	else:
		modulate = Color.white

func set_placement_mode(enabled: bool):
	"""Define modo de colocação"""
	
	is_placement_mode = enabled
	
	if enabled:
		modulate = Color(1, 1, 1, 0.7)
		collision_layer = 0
	else:
		modulate = Color.white
		collision_layer = 4

func move_to_position(new_position: Vector2):
	"""Move o item para nova posição"""
	
	if snap_to_grid:
		new_position = snap_position_to_grid(new_position)
	
	global_position = new_position

func snap_position_to_grid(pos: Vector2) -> Vector2:
	"""Ajusta posição ao grid"""
	
	var snapped_x = round(pos.x / grid_size) * grid_size
	var snapped_y = round(pos.y / grid_size) * grid_size
	return Vector2(snapped_x, snapped_y)

func rotate_item(angle: float):
	"""Rotaciona o item"""
	
	if can_rotate:
		rotation += angle

func delete_item():
	"""Deleta o item"""
	
	emit_signal("item_deleted", self)
	queue_free()

func get_item_data() -> Dictionary:
	"""Retorna dados do item para salvar"""
	
	return {
		"name": item_name,
		"category": item_category,
		"position": global_position,
		"rotation": rotation,
		"scale": scale
	}

func load_item_data(data: Dictionary):
	"""Carrega dados do item"""
	
	if data.has("position"):
		global_position = data.position
	if data.has("rotation"):
		rotation = data.rotation
	if data.has("scale"):
		scale = data.scale
