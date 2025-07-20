# DecorationUI.gd - Interface fixa na tela (independente de zoom)
class_name DecorationUI
extends Control

# Componentes da UI
var main_panel: Panel
var category_tabs: TabContainer
var close_button: Button
var mode_label: Label
var info_label: Label

# Configurações
var item_button_size: Vector2 = Vector2(80, 80)
var items_per_row: int = 4

# Catálogo
var catalog: DecorationCatalog

# Sinais
signal item_selected_for_placement(item_id)
signal decoration_mode_exit

func _ready():
	"""Inicialização da UI"""
	
	# Cria catálogo
	catalog = DecorationCatalog.new()
	
	create_ui()
	populate_categories()
	visible = false

func create_ui():
	"""Cria interface do modo decoração - FIXA NA TELA"""
	
	# Configura control principal para ser fixo na tela
	set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT)
	rect_position = Vector2(20, 20)
	rect_size = Vector2(350, 450)
	
	# Painel principal com fundo sólido
	main_panel = Panel.new()
	main_panel.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	main_panel.modulate = Color(1, 1, 1, 0.95)  # Ligeiramente transparente
	add_child(main_panel)
	
	# Label do modo
	mode_label = Label.new()
	mode_label.text = "🎨 MODO DECORAÇÃO"
	mode_label.align = Label.ALIGN_CENTER
	mode_label.rect_position = Vector2(10, 10)
	mode_label.rect_size = Vector2(330, 25)
	mode_label.add_color_override("font_color", Color.cyan)
	main_panel.add_child(mode_label)
	
	# Label de informações
	info_label = Label.new()
	info_label.text = "Clique em um item para colocar | ESC para sair"
	info_label.align = Label.ALIGN_CENTER
	info_label.rect_position = Vector2(10, 35)
	info_label.rect_size = Vector2(330, 20)
	info_label.add_color_override("font_color", Color.lightgray)
	info_label.autowrap = true
	main_panel.add_child(info_label)
	
	# Tabs de categorias
	category_tabs = TabContainer.new()
	category_tabs.rect_position = Vector2(10, 65)
	category_tabs.rect_size = Vector2(330, 340)
	main_panel.add_child(category_tabs)
	
	# Botão fechar
	close_button = Button.new()
	close_button.text = "SAIR MODO DECORAÇÃO (ESC)"
	close_button.rect_position = Vector2(10, 415)
	close_button.rect_size = Vector2(330, 25)
	close_button.connect("pressed", self, "_on_close_pressed")
	main_panel.add_child(close_button)

func populate_categories():
	"""Popula as abas de categorias"""
	
	var categories = catalog.get_all_categories()
	
	for category in categories:
		create_category_tab(category)

func create_category_tab(category: String):
	"""Cria uma aba de categoria"""
	
	# Container da categoria
	var category_container = VBoxContainer.new()
	category_container.name = category.capitalize()
	category_tabs.add_child(category_container)
	
	# Scroll container
	var scroll = ScrollContainer.new()
	scroll.rect_min_size.y = 310
	scroll.scroll_horizontal_enabled = false
	category_container.add_child(scroll)
	
	# Grid de itens
	var grid = GridContainer.new()
	grid.columns = items_per_row
	grid.add_constant_override("hseparation", 8)
	grid.add_constant_override("vseparation", 8)
	scroll.add_child(grid)
	
	# Adiciona itens da categoria
	var items = catalog.get_items_by_category(category)
	
	for item_info in items:
		create_item_button(grid, item_info.id, item_info.data)

func create_item_button(parent: GridContainer, item_id: String, item_data: Dictionary):
	"""Cria botão para um item"""
	
	var button = Button.new()
	button.rect_min_size = Vector2(70, 70)
	button.hint_tooltip = item_data.get("description", "")
	
	# Container vertical para organizar conteúdo
	var vbox = VBoxContainer.new()
	button.add_child(vbox)
	
	# Ícone/preview do item
	var icon_container = CenterContainer.new()
	icon_container.rect_min_size.y = 45
	vbox.add_child(icon_container)
	
	var icon = TextureRect.new()
	icon.rect_min_size = Vector2(40, 40)
	icon.expand = true
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Carrega textura se disponível
	var texture_path = item_data.get("texture_path", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		icon.texture = load(texture_path)
	else:
		# Preview colorido se não tem textura
		var preview_texture = create_preview_texture(item_data.get("category", "geral"))
		icon.texture = preview_texture
	
	icon_container.add_child(icon)
	
	# Nome do item
	var label = Label.new()
	label.text = item_data.get("name", item_id)
	label.align = Label.ALIGN_CENTER
	label.autowrap = true
	label.rect_min_size.y = 20
#	label.clip_contents = true
	vbox.add_child(label)
	
	# Conecta sinal
	button.connect("pressed", self, "_on_item_button_pressed", [item_id])
	
	parent.add_child(button)

func create_preview_texture(category: String) -> ImageTexture:
	"""Cria preview colorido baseado na categoria"""
	
	var color = Color.gray
	match category:
		"natureza":
			color = Color.green
		"pedras":
			color = Color(0.5, 0.4, 0.3)  # Marrom
		"cristais":
			color = Color.magenta
		"agua":
			color = Color.blue
		"estruturas":
			color = Color(0.6, 0.6, 0.6)  # Cinza claro
		_:
			color = Color.gray
	
	var texture = ImageTexture.new()
	var image = Image.new()
	image.create(32, 32, false, Image.FORMAT_RGB8)
	image.fill(color)
	texture.create_from_image(image)
	return texture

func _on_item_button_pressed(item_id: String):
	"""Botão de item pressionado"""
	
	print("Item selecionado para colocação: ", item_id)
	emit_signal("item_selected_for_placement", item_id)
	
	# Feedback visual
	info_label.text = "Clique no mundo para colocar | Clique direito para cancelar"
	info_label.add_color_override("font_color", Color.yellow)

func _on_close_pressed():
	"""Botão fechar pressionado"""
	
	emit_signal("decoration_mode_exit")

func show_ui():
	"""Mostra a UI"""
	
	visible = true
	info_label.text = "Clique em um item para colocar | ESC para sair"
	info_label.add_color_override("font_color", Color.lightgray)
	self.rect_position = get_global_mouse_position()

func hide_ui():
	"""Esconde a UI"""
	
	visible = false

func get_catalog() -> DecorationCatalog:
	"""Retorna o catálogo"""
	return catalog

func _process(_delta):
	"""Mantém UI sempre visível e fixa"""
	
	# Garante que a UI está sempre por cima e visível
	if visible:
		# Opcional: Reposiciona se sair da tela
		var viewport_size = get_viewport().size
		if rect_position.x + rect_size.x > viewport_size.x:
			rect_position.x = viewport_size.x - rect_size.x - 20
		if rect_position.y + rect_size.y > viewport_size.y:
			rect_position.y = viewport_size.y - rect_size.y - 20
