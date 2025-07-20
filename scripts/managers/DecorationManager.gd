# DecorationManager.gd - Gerenciador corrigido para câmera
extends Node2D

# Estados
var is_decoration_mode: bool = false
var selected_item: DecorationItem = null
var is_placing_item: bool = false
var placement_item: DecorationItem = null

# UI - será CanvasLayer para ficar fixo na tela
var decoration_ui: DecorationUI
var ui_canvas_layer: CanvasLayer

# Configurações
var current_camera: Camera2D
var world_node: Node2D

# Lista de itens decorativos
var decoration_items: Array = []

# Sinais
signal decoration_mode_changed(enabled)
signal item_selected_changed(item)

func _ready():
	"""Inicialização do gerenciador"""
	
	# Busca câmera e mundo
	call_deferred("find_world_components")
	
	print("DecorationManager inicializado")

func find_world_components():
	"""Encontra componentes do mundo"""
	
	# Busca câmera
	current_camera = get_active_camera2d()
	if not current_camera:
		var cameras = get_tree().get_nodes_in_group("cameras")
		if cameras.size() > 0:
			current_camera = cameras[0]
	
	# Busca nó do mundo
	world_node = get_tree().current_scene
	
	print("Componentes encontrados - Camera: ", current_camera, " World: ", world_node)


func get_active_camera2d():
	var camera_list = get_tree().get_nodes_in_group("cameras_2d")
	for cam in camera_list:
		if cam is Camera2D and cam.current:
			return cam
	return null


func _input(event):
	"""Processa inputs globais"""
	
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_B:  # Ativa/desativa modo decoração
				toggle_decoration_mode()
			KEY_ESCAPE:  # Cancela colocação ou sai do modo
				if is_placing_item:
					cancel_placement()
				else:
					set_decoration_mode(false)
			KEY_DELETE:  # Deleta item selecionado
				if selected_item:
					delete_selected_item()
			KEY_R:  # Rotaciona item selecionado
				if selected_item and selected_item.can_rotate:
					selected_item.rotate_item(PI/4)
	
	# Processos específicos do modo decoração
	if is_decoration_mode:
		handle_decoration_input(event)

func handle_decoration_input(event):
	"""Processa inputs do modo decoração"""
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if is_placing_item:
				place_current_item()
			else:
				# Verifica clique em decorações
				check_decoration_click()
		
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			if is_placing_item:
				cancel_placement()
	
	elif event is InputEventMouseMotion:
		if is_placing_item and placement_item:
			# CORRIGIDO: Usa posição correta da câmera
			placement_item.global_position = get_world_mouse_position()

func check_decoration_click():
	"""Verifica clique em decorações"""
	
	var mouse_world_pos = get_world_mouse_position()
	
	# Verifica todos os itens decorativos
	var closest_item = null
	var closest_distance = INF
	
	for item in decoration_items:
		if is_instance_valid(item):
			var distance = item.global_position.distance_to(mouse_world_pos)
			
			# Verifica se o clique está dentro do item
			var item_size = Vector2(64, 64)  # Tamanho padrão
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
	"""CORRIGIDO: Retorna posição do mouse no mundo considerando câmera"""
	
	return get_global_mouse_position()
	if not current_camera:
		return get_viewport().get_mouse_position()
	
	# Pega posição do mouse na viewport
	var viewport = get_viewport()
	var mouse_screen_pos = viewport.get_mouse_position()
	
	# Converte para posição no mundo considerando câmera
	var viewport_size = viewport.size
	var camera_center = current_camera.global_position
	var camera_zoom = current_camera.zoom
	
	# Calcula offset do mouse em relação ao centro da tela
	var mouse_offset = (mouse_screen_pos - viewport_size * 0.5)
	
	# Aplica zoom e adiciona à posição da câmera
	var world_position = camera_center + mouse_offset * camera_zoom
	
	return world_position

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
	
	print("Entrando no modo de decoração")
	
	# Cria CanvasLayer para UI fixa
	if not ui_canvas_layer:
		ui_canvas_layer = CanvasLayer.new()
		ui_canvas_layer.name = "DecorationUI_Layer"
		ui_canvas_layer.layer = 100  # Layer alto para ficar por cima
		get_tree().current_scene.add_child(ui_canvas_layer)
	
	# Cria UI de decoração no CanvasLayer
	if not decoration_ui:
		decoration_ui = preload("res://scripts/ui/DecorationUI.gd").new()
		ui_canvas_layer.add_child(decoration_ui)
		decoration_ui.connect("item_selected_for_placement", self, "_on_item_selected_for_placement")
		decoration_ui.connect("decoration_mode_exit", self, "_on_decoration_mode_exit")
	
	decoration_ui.show_ui()

func exit_decoration_mode():
	"""Sai do modo de decoração"""
	
	print("Saindo do modo de decoração")
	
	# Cancela colocação se estiver ativa
	if is_placing_item:
		cancel_placement()
	
	# Deseleciona tudo
	deselect_all()
	
	# Esconde UI
	if decoration_ui:
		decoration_ui.hide_ui()

func _on_item_selected_for_placement(item_id: String):
	"""Item selecionado para colocação"""
	
	start_item_placement(item_id)

func _on_decoration_mode_exit():
	"""Solicitação para sair do modo decoração"""
	
	set_decoration_mode(false)

func start_item_placement(item_id: String):
	"""Inicia colocação de um item"""
	
	if is_placing_item:
		cancel_placement()
	
	# Pega dados do item do catálogo da UI
	if not decoration_ui:
		print("Erro: UI não existe")
		return
		
	var item_data = decoration_ui.get_catalog().get_item_data(item_id)
	if item_data.empty():
		print("Erro: Item não encontrado: ", item_id)
		return
	
	# Cria item
	placement_item = create_decoration_item(item_data)
	if not placement_item:
		print("Erro: Não foi possível criar item: ", item_id)
		return
	
	# Adiciona ao mundo
	world_node.add_child(placement_item)
	
	# Configura modo de colocação
	placement_item.set_placement_mode(true)
	placement_item.global_position = get_world_mouse_position()
	
	is_placing_item = true
	
	print("Iniciando colocação do item: ", item_id)

func place_current_item():
	"""Coloca o item atual na posição do mouse"""
	
	if not placement_item:
		return
	
	# CORRIGIDO: Usa posição correta no mundo
	placement_item.global_position = get_world_mouse_position()
	
	# Finaliza colocação
	placement_item.set_placement_mode(false)
	decoration_items.append(placement_item)
	
	# Conecta sinais
	placement_item.connect("item_clicked", self, "_on_decoration_item_clicked")
	placement_item.connect("item_deleted", self, "_on_decoration_item_deleted")
	
	print("Item colocado em: ", placement_item.global_position)
	
	# Limpa estado de colocação
	placement_item = null
	is_placing_item = false

func cancel_placement():
	"""Cancela colocação atual"""
	
	if placement_item:
		placement_item.queue_free()
		placement_item = null
	
	is_placing_item = false
	print("Colocação cancelada")

func create_decoration_item(item_data: Dictionary) -> DecorationItem:
	"""Cria um item decorativo a partir dos dados"""
	
	var item = preload("res://scripts/decoration/DecorationItem.gd").new()
	
	# Configura propriedades do item
	item.item_name = item_data.get("name", "Item")
	item.item_description = item_data.get("description", "")
	item.item_price = item_data.get("price", 0)
	item.item_category = item_data.get("category", "geral")
	item.can_rotate = item_data.get("can_rotate", true)
	item.snap_to_grid = item_data.get("snap_to_grid", false)
	
	# Adiciona sprite se tem textura
	var texture_path = item_data.get("texture_path", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		var sprite = Sprite.new()
		sprite.name = "Sprite"
		sprite.texture = load(texture_path)
		item.add_child(sprite)
		
		# Adiciona colisão baseada na textura
		var collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		var shape = RectangleShape2D.new()
		if sprite.texture:
			shape.extents = sprite.texture.get_size() * 0.5
		collision_shape.shape = shape
		item.add_child(collision_shape)
	else:
		# Item sem textura - cria um quadrado colorido
		var sprite = Sprite.new()
		sprite.name = "Sprite"
		var texture = create_placeholder_texture()
		sprite.texture = texture
		item.add_child(sprite)
		
		# Colisão padrão
		var collision_shape = CollisionShape2D.new()
		collision_shape.name = "CollisionShape2D"
		var shape = RectangleShape2D.new()
		shape.extents = Vector2(32, 32)
		collision_shape.shape = shape
		item.add_child(collision_shape)
	
	return item

func create_placeholder_texture() -> ImageTexture:
	"""Cria uma textura placeholder"""
	
	var texture = ImageTexture.new()
	var image = Image.new()
	image.create(64, 64, false, Image.FORMAT_RGB8)
	image.fill(Color(0.5, 0.5, 0.5))
	texture.create_from_image(image)
	return texture

func select_item(item: DecorationItem):
	"""Seleciona um item decorativo"""
	
	if selected_item == item:
		return
	
	# Deseleciona item anterior
	if selected_item:
		selected_item.set_selected(false)
	
	# Seleciona novo item
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
		selected_item.delete_item()

func _on_decoration_item_clicked(item: DecorationItem):
	"""Item decorativo foi clicado"""
	
	select_item(item)

func _on_decoration_item_deleted(item: DecorationItem):
	"""Item decorativo foi deletado"""
	
	decoration_items.erase(item)
	
	if selected_item == item:
		selected_item = null
		emit_signal("item_selected_changed", null)
