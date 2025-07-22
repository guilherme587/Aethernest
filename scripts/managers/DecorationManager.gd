# DecorationManager.gd - Manager com colocação baseada no tamanho da ferramenta
extends Node2D

# Estados do editor
var is_decoration_mode: bool = false
var selected_item: DecorationItem = null

# UI
var decoration_ui: DecorationUI
var ui_canvas_layer: CanvasLayer

# Sistema de ferramentas
enum ToolMode {
	NONE,
	BRUSH,
	PENCIL,
	ERASER
}

var current_tool: int = ToolMode.NONE
var selected_item_id: String = ""
var is_mouse_pressed: bool = false
var tool_size: float = 50.0

# Cursor customizado
var cursor_overlay: Control
var cursor_circle: Node2D

# Configurações
var current_camera: Camera2D
var world_node: Node2D

# Lista de itens decorativos
var decoration_items: Array = []

# Configurações da ferramenta
var brush_place_interval: float = 0.1
var brush_timer: float = 0.0

# NOVO: Configurações de densidade de colocação
var items_density: float = 0.5  # Agora será controlada pela UI
var min_item_spacing: float = 15.0  # Espaçamento mínimo entre itens


# Sinais
signal decoration_mode_changed(enabled)
signal item_selected_changed(item)

func _ready():
	"""Inicialização do gerenciador"""
	
	call_deferred("find_world_components")
	create_cursor_overlay()
	print("DecorationManager inicializado")

func create_cursor_overlay():
	"""Cria overlay do cursor customizado"""
	
	cursor_overlay = Control.new()
	cursor_overlay.name = "CursorOverlay"
	cursor_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cursor_overlay.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	
	cursor_circle = Node2D.new()
	cursor_circle.name = "CursorCircle"
	cursor_overlay.add_child(cursor_circle)
	
	cursor_overlay.visible = false

func add_cursor_to_scene():
	"""Adiciona cursor à cena principal"""
	
	if cursor_overlay.get_parent():
		cursor_overlay.get_parent().remove_child(cursor_overlay)
	
	if ui_canvas_layer:
		ui_canvas_layer.add_child(cursor_overlay)
	else:
		get_tree().current_scene.add_child(cursor_overlay)

func find_world_components():
	"""Encontra componentes do mundo"""
	
	current_camera = get_active_camera2d()
	if not current_camera:
		var cameras = get_tree().get_nodes_in_group("cameras")
		if cameras.size() > 0:
			current_camera = cameras[0]
	
	world_node = get_tree().current_scene
	
	print("Componentes encontrados - Camera: ", current_camera, " World: ", world_node)

func get_active_camera2d():
	"""Encontra câmera ativa"""
	var camera_list = get_tree().get_nodes_in_group("cameras_2d")
	for cam in camera_list:
		if cam is Camera2D and cam.current:
			return cam
	return null

func _input(event):
	"""Processa inputs globais"""
	
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_B:
				toggle_decoration_mode()
			KEY_ESCAPE:
				if is_decoration_mode:
					set_decoration_mode(false)
			KEY_DELETE:
				if selected_item:
					delete_selected_item()
			KEY_R:
				if selected_item and selected_item.can_rotate:
					selected_item.rotate_item(PI/4)
	
	if is_decoration_mode:
		handle_decoration_input(event)

func handle_decoration_input(event):
	"""Processa inputs do editor de decoração"""
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				is_mouse_pressed = true
				handle_tool_action()
			else:
				is_mouse_pressed = false
				brush_timer = 0.0
		
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			select_decoration_at_mouse()
	
	elif event is InputEventMouseMotion:
		update_cursor_position(event.position)
		
		if is_mouse_pressed:
			handle_continuous_action()

func update_cursor_position(mouse_pos: Vector2):
	"""Atualiza posição do cursor customizado"""
	
	if not cursor_overlay.visible:
		return
	
	cursor_circle.position = mouse_pos
	cursor_circle.update()

func handle_tool_action():
	"""CORRIGIDO: Executa ação da ferramenta com tamanho correto"""
	
	if not decoration_ui.can_place_item():
		return
	
	match current_tool:
		ToolMode.BRUSH:
			place_items_in_area()
			brush_timer = 0.0
		
		ToolMode.PENCIL:
			place_items_in_area()
		
		ToolMode.ERASER:
			erase_items_at_mouse()

func handle_continuous_action():
	"""Ação contínua enquanto mouse pressionado"""
	
	if not decoration_ui.can_place_item():
		return
	
	match current_tool:
		ToolMode.BRUSH:
			brush_timer += get_process_delta_time()
			if brush_timer >= brush_place_interval:
				place_items_in_area()
				brush_timer = 0.0
		
		ToolMode.ERASER:
			erase_items_at_mouse()

func place_items_in_area():
	"""NOVO: Coloca itens na área definida pelo tamanho da ferramenta"""
	
	if selected_item_id == "":
		return
	
	var mouse_world_pos = get_world_mouse_position()
	var radius = tool_size
	
	# Calcula quantos itens colocar baseado no tamanho da área
	var area = PI * radius * radius
	var items_to_place = calculate_items_for_area(area)
	
	print("Colocando ", items_to_place, " itens em área de raio ", radius)
	
	# Gera posições aleatórias dentro do círculo
	var positions = generate_positions_in_circle(mouse_world_pos, radius, items_to_place)
	
	# Coloca itens nas posições geradas
	for pos in positions:
		place_single_item_at_position(pos)

func calculate_items_for_area(area: float) -> int:
	"""ATUALIZADO: Calcula quantos itens colocar baseado na área e densidade da UI"""
	
	# Fator base: 1 item para cada 500 pixels² na densidade máxima
	var base_factor = area / 500.0
	
	# CORRIGIDO: Usa densidade da UI ao invés da variável local
	var items_count = int(base_factor * items_density)
	
	# Limites mínimo e máximo
	items_count = max(1, items_count)
	items_count = min(20, items_count)
	
	# Ajusta baseado na ferramenta
	match current_tool:
		ToolMode.PENCIL:
			# Lápis coloca menos itens, mais preciso
			items_count = max(1, int(items_count * 0.4))  # Reduzido para ser mais preciso
		ToolMode.BRUSH:
			# Pincel coloca mais itens, cobertura maior
			items_count = int(items_count * 1.3)  # Aumentado para maior cobertura
	
	return items_count

func generate_positions_in_circle(center: Vector2, radius: float, count: int) -> Array:
	"""Gera posições aleatórias dentro de um círculo"""
	
	var positions = []
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var attempts = 0
	var max_attempts = count * 10  # Limite para evitar loop infinito
	
	while positions.size() < count and attempts < max_attempts:
		attempts += 1
		
		# Gera posição aleatória dentro do círculo
		var angle = rng.randf() * TAU
		var distance = rng.randf() * radius
		
		# Distribui mais uniformemente usando raiz quadrada
		distance = sqrt(distance / radius) * radius
		
		var pos = center + Vector2(cos(angle), sin(angle)) * distance
		
		# Verifica se a posição é válida (não muito próxima de outras)
		if is_position_valid(pos, positions):
			positions.append(pos)
	
	print("Gerou ", positions.size(), " posições válidas de ", count, " solicitadas")
	return positions

func is_position_valid(pos: Vector2, existing_positions: Array) -> bool:
	"""Verifica se a posição é válida (não muito próxima de itens existentes)"""
	
	# Verifica distância de outras posições que serão colocadas
	for existing_pos in existing_positions:
		if pos.distance_to(existing_pos) < min_item_spacing:
			return false
	
	# Verifica distância de itens já colocados no mundo
	for item in decoration_items:
		if is_instance_valid(item):
			if pos.distance_to(item.global_position) < min_item_spacing:
				return false
	
	return true

func place_single_item_at_position(position: Vector2):
	"""Coloca um único item em uma posição específica"""
	
	var item_data = decoration_ui.get_catalog().get_item_data(selected_item_id)
	if item_data.empty():
		return
	
	var new_item = create_decoration_item(item_data)
	if new_item:
		world_node.add_child(new_item)
		new_item.global_position = position
		
		# Variação aleatória na rotação (se permitido)
		if new_item.can_rotate:
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			new_item.rotation = rng.randf() * TAU
		
		decoration_items.append(new_item)
		
		new_item.connect("item_clicked", self, "_on_decoration_item_clicked")
		new_item.connect("item_deleted", self, "_on_decoration_item_deleted")

func erase_items_at_mouse():
	"""Apaga itens na área definida pelo tamanho da ferramenta"""
	
	var mouse_world_pos = get_world_mouse_position()
	var items_to_erase = []
	
	# Usa tool_size como raio da borracha
	for item in decoration_items:
		if is_instance_valid(item):
			var distance = item.global_position.distance_to(mouse_world_pos)
			if distance <= tool_size:
				items_to_erase.append(item)
	
	print("Apagando ", items_to_erase.size(), " itens em raio de ", tool_size)
	
	for item in items_to_erase:
		remove_decoration_item(item)

func select_decoration_at_mouse():
	"""Seleciona decoração na posição do mouse"""
	
	var mouse_world_pos = get_world_mouse_position()
	var closest_item = null
	var closest_distance = INF
	
	for item in decoration_items:
		if is_instance_valid(item):
			var distance = item.global_position.distance_to(mouse_world_pos)
			
			var item_size = Vector2(64, 64)
			if item.sprite and item.sprite.texture:
				item_size = item.sprite.texture.get_size() * item.scale
			
			var click_radius = max(item_size.x, item_size.y) * 0.5
			
			if distance < click_radius and distance < closest_distance:
				closest_item = item
				closest_distance = distance
	
	if closest_item:
		select_item(closest_item)
	else:
		deselect_all()

func get_world_mouse_position() -> Vector2:
	"""Retorna posição do mouse no mundo"""
	return get_global_mouse_position()

func toggle_decoration_mode():
	"""Alterna modo de decoração"""
	set_decoration_mode(not is_decoration_mode)

func set_decoration_mode(enabled: bool):
	"""Define modo de decoração"""
	
	if is_decoration_mode == enabled:
		return
	
	is_decoration_mode = enabled
	
	if enabled:
		enter_decoration_mode()
	else:
		exit_decoration_mode()
	
	emit_signal("decoration_mode_changed", enabled)

func enter_decoration_mode():
	"""Entra no modo de decoração"""
	
	print("Entrando no editor de decoração")
	
	if not ui_canvas_layer:
		ui_canvas_layer = CanvasLayer.new()
		ui_canvas_layer.name = "DecorationUI_Layer"
		ui_canvas_layer.layer = 100
		get_tree().current_scene.add_child(ui_canvas_layer)
	
	if not decoration_ui:
		decoration_ui = preload("res://scripts/ui/DecorationUI.gd").new()
		ui_canvas_layer.add_child(decoration_ui)
		decoration_ui.connect("tool_changed", self, "_on_tool_changed")
		decoration_ui.connect("decoration_mode_exit", self, "_on_decoration_mode_exit")
	
	add_cursor_to_scene()
	setup_custom_cursor()
	
	decoration_ui.show_ui()

func exit_decoration_mode():
	"""Sai do modo de decoração"""
	
	print("Saindo do editor de decoração")
	
	current_tool = ToolMode.NONE
	selected_item_id = ""
	is_mouse_pressed = false
	tool_size = 50.0
	
	restore_default_cursor()
	deselect_all()
	
	if decoration_ui:
		decoration_ui.hide_ui()

func setup_custom_cursor():
	"""Configura cursor customizado"""
	
	cursor_overlay.visible = true
	
	if not cursor_circle.is_connected("draw", self, "_draw_cursor_circle_content"):
		cursor_circle.connect("draw", self, "_draw_cursor_circle_content")
	
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _draw_cursor_circle_content():
	"""Desenha conteúdo do círculo do cursor"""
	
	if not cursor_overlay.visible:
		return
	
	var color = Color.white
	var thickness = 2.0
	
	match current_tool:
		ToolMode.BRUSH:
			color = Color.green
		ToolMode.PENCIL:
			color = Color.blue
		ToolMode.ERASER:
			color = Color.red
		_:
			color = Color.white
	
	# Desenha círculo principal
	cursor_circle.draw_arc(Vector2.ZERO, tool_size, 0, TAU, 64, color, thickness)
	
	# Desenha cruz no centro
	var cross_size = 5.0
	cursor_circle.draw_line(Vector2(-cross_size, 0), Vector2(cross_size, 0), color, thickness)
	cursor_circle.draw_line(Vector2(0, -cross_size), Vector2(0, cross_size), color, thickness)
	
	# NOVO: Desenha pontos indicando onde itens serão colocados
	if current_tool == ToolMode.BRUSH or current_tool == ToolMode.PENCIL:
		draw_placement_preview()

func draw_placement_preview():
	"""NOVO: Desenha preview de onde os itens serão colocados"""
	
	var area = PI * tool_size * tool_size
	var items_count = calculate_items_for_area(area)
	
	# Limita preview para não ficar muito poluído
	items_count = min(items_count, 10)
	
	var preview_positions = generate_positions_in_circle(Vector2.ZERO, tool_size, items_count)
	
	var dot_color = Color.white
	dot_color.a = 0.6
	
	for pos in preview_positions:
		cursor_circle.draw_circle(pos, 2.0, dot_color)

func restore_default_cursor():
	"""Restaura cursor padrão"""
	
	cursor_overlay.visible = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_tool_changed(tool_mode: int, item_id: String, new_tool_size: float, new_density: float):
	"""ATUALIZADO: Ferramenta, item, tamanho ou densidade mudou"""
	
	current_tool = tool_mode
	selected_item_id = item_id
	tool_size = new_tool_size
	items_density = new_density  # NOVO: Usa densidade da UI
	
	# Atualiza espaçamento mínimo baseado no tamanho
	min_item_spacing = max(10.0, tool_size * 0.15)
	
	if cursor_circle:
		cursor_circle.update()
	
	print("Ferramenta: ", tool_mode, " | Item: ", item_id, " | Tamanho: ", tool_size, " | Densidade: ", int(items_density * 100), "% | Espaçamento: ", min_item_spacing)

func _on_decoration_mode_exit():
	"""Sair do modo decoração"""
	set_decoration_mode(false)

# === RESTO DAS FUNÇÕES MANTIDAS ===

func create_decoration_item(item_data: Dictionary) -> DecorationItem:
	"""Cria um item decorativo"""
	
	var item = preload("res://scripts/decoration/DecorationItem.gd").new()
	
	item.item_name = item_data.get("name", "Item")
	item.item_description = item_data.get("description", "")
	item.item_price = item_data.get("price", 0)
	item.item_category = item_data.get("category", "geral")
	item.can_rotate = item_data.get("can_rotate", true)
	item.snap_to_grid = item_data.get("snap_to_grid", false)
	
	var texture_path = item_data.get("texture_path", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		var sprite = Sprite.new()
		sprite.name = "Sprite"
		sprite.texture = load(texture_path)
		item.add_child(sprite)
		
		var collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		var shape = RectangleShape2D.new()
		if sprite.texture:
			shape.extents = sprite.texture.get_size() * 0.5
		collision_shape.shape = shape
		item.add_child(collision_shape)
	else:
		var sprite = Sprite.new()
		sprite.name = "Sprite"
		var texture = create_placeholder_texture()
		sprite.texture = texture
		item.add_child(sprite)
		
		var collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		var shape = RectangleShape2D.new()
		shape.extents = Vector2(32, 32)
		collision_shape.shape = shape
		item.add_child(collision_shape)
	
	return item

func create_placeholder_texture() -> ImageTexture:
	"""Cria textura placeholder"""
	
	var texture = ImageTexture.new()
	var image = Image.new()
	image.create(64, 64, false, Image.FORMAT_RGB8)
	image.fill(Color(0.5, 0.5, 0.5))
	texture.create_from_image(image)
	return texture

func remove_decoration_item(item: DecorationItem):
	"""Remove item decorativo"""
	
	if selected_item == item:
		selected_item = null
		emit_signal("item_selected_changed", null)
	
	decoration_items.erase(item)
	item.queue_free()

func select_item(item: DecorationItem):
	"""Seleciona um item decorativo"""
	
	if selected_item == item:
		return
	
	if selected_item:
		selected_item.set_selected(false)
	
	selected_item = item
	if selected_item:
		selected_item.set_selected(true)
	
	emit_signal("item_selected_changed", selected_item)

func deselect_all():
	"""Deseleciona todos os itens"""
	
	if selected_item:
		selected_item.set_selected(false)
		selected_item = null
		emit_signal("item_selected_changed", null)

func delete_selected_item():
	"""Deleta o item selecionado"""
	
	if selected_item:
		remove_decoration_item(selected_item)

func _on_decoration_item_clicked(item: DecorationItem):
	"""Item decorativo foi clicado"""
	select_item(item)

func _on_decoration_item_deleted(item: DecorationItem):
	"""Item decorativo foi deletado"""
	remove_decoration_item(item)
