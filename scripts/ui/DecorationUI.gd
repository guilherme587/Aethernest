# DecorationUI.gd - Editor com controle de tamanho e densidade
class_name DecorationUI
extends Control

# Componentes da UI
var main_panel: Panel
var toolbar: HBoxContainer
var size_control_section: VBoxContainer
var density_control_section: VBoxContainer  # NOVA SEÇÃO
var category_tabs: TabContainer
var close_button: Button
var mode_label: Label
var info_label: Label

# Botões da toolbar
var brush_button: Button
var pencil_button: Button
var eraser_button: Button
var clear_selection_button: Button

# Controles de tamanho
var size_label: Label
var size_slider: HSlider
var size_value_label: Label

# NOVOS: Controles de densidade
var density_label: Label
var density_slider: HSlider
var density_value_label: Label

# Configurações
var item_button_size: Vector2 = Vector2(80, 80)
var items_per_row: int = 4

# Estado do editor
enum ToolMode {
	NONE,
	BRUSH,
	PENCIL,
	ERASER
}

var current_tool: int = ToolMode.NONE
var selected_item_id: String = ""
var is_mouse_pressed: bool = false

# Configurações de tamanho e densidade
var tool_size: float = 50.0
var min_tool_size: float = 10.0
var max_tool_size: float = 150.0

var items_density: float = 0.5  # Densidade de itens (0.1 a 1.0)
var min_density: float = 0.1    # 10% densidade mínima
var max_density: float = 1.0    # 100% densidade máxima

# Catálogo
var catalog: DecorationCatalog

# Sinais
signal tool_changed(tool_mode, item_id, tool_size, density)
signal decoration_mode_exit

func _ready():
	"""Inicialização da UI"""
	
	catalog = DecorationCatalog.new()
	
	create_ui()
	populate_categories()
	visible = false

func create_ui():
	"""Cria interface do editor - POSICIONADA À DIREITA"""
	
	position_ui_to_right()
	
	# Painel principal - AUMENTADO para densidade
	main_panel = Panel.new()
	main_panel.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	main_panel.modulate = Color(1, 1, 1, 0.95)
	add_child(main_panel)
	
	# Label do modo
	mode_label = Label.new()
	mode_label.text = "🎨 EDITOR DE DECORAÇÃO"
	mode_label.align = Label.ALIGN_CENTER
	mode_label.rect_position = Vector2(10, 10)
	mode_label.rect_size = Vector2(330, 25)
	mode_label.add_color_override("font_color", Color.cyan)
	main_panel.add_child(mode_label)
	
	# Toolbar de ferramentas
	create_toolbar()
	
	# Seção de controle de tamanho
	create_size_control_section()
	
	# NOVA: Seção de controle de densidade
	create_density_control_section()
	
	# Label de informações - REPOSICIONADO
	info_label = Label.new()
	info_label.text = "Selecione uma ferramenta e um item"
	info_label.align = Label.ALIGN_CENTER
	info_label.rect_position = Vector2(10, 185)  # Movido para baixo
	info_label.rect_size = Vector2(330, 20)
	info_label.add_color_override("font_color", Color.lightgray)
	info_label.autowrap = true
	main_panel.add_child(info_label)
	
	# Tabs de categorias - REPOSICIONADO
	category_tabs = TabContainer.new()
	category_tabs.rect_position = Vector2(10, 215)  # Movido para baixo
	category_tabs.rect_size = Vector2(330, 250)     # Reduzido um pouco
	main_panel.add_child(category_tabs)
	
	# Botão fechar - REPOSICIONADO
	close_button = Button.new()
	close_button.text = "FECHAR EDITOR (ESC)"
	close_button.rect_position = Vector2(10, 475)
	close_button.rect_size = Vector2(330, 25)
	close_button.connect("pressed", self, "_on_close_pressed")
	main_panel.add_child(close_button)

func position_ui_to_right():
	"""Posiciona UI no lado direito da tela"""
	
	var viewport_size = get_viewport().size
	var panel_width = 350
	var panel_height = 510  # Mesmo tamanho, reorganizado internamente
	var margin = 20
	
	var pos_x = viewport_size.x - panel_width - margin
	var pos_y = margin
	
	set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT)
	rect_position = Vector2(pos_x, pos_y)
	rect_size = Vector2(panel_width, panel_height)

func create_toolbar():
	"""Cria barra de ferramentas"""
	
	toolbar = HBoxContainer.new()
	toolbar.rect_position = Vector2(10, 40)
	toolbar.rect_size = Vector2(330, 40)
	toolbar.add_constant_override("separation", 5)
	main_panel.add_child(toolbar)
	
	# Botão Pincel
	brush_button = Button.new()
	brush_button.text = "🖌️ Pincel"
	brush_button.rect_min_size = Vector2(75, 35)
	brush_button.hint_tooltip = "Pintura contínua - Mantenha pressionado para pintar"
	brush_button.connect("pressed", self, "_on_tool_selected", [ToolMode.BRUSH])
	toolbar.add_child(brush_button)
	
	# Botão Lápis
	pencil_button = Button.new()
	pencil_button.text = "✏️ Lápis"
	pencil_button.rect_min_size = Vector2(75, 35)
	pencil_button.hint_tooltip = "Colocação unitária - Um clique, um item"
	pencil_button.connect("pressed", self, "_on_tool_selected", [ToolMode.PENCIL])
	toolbar.add_child(pencil_button)
	
	# Botão Borracha
	eraser_button = Button.new()
	eraser_button.text = "🧹 Borracha"
	eraser_button.rect_min_size = Vector2(75, 35)
	eraser_button.hint_tooltip = "Apagar itens - Mantenha pressionado para apagar"
	eraser_button.connect("pressed", self, "_on_tool_selected", [ToolMode.ERASER])
	toolbar.add_child(eraser_button)
	
	# Botão Limpar Seleção
	clear_selection_button = Button.new()
	clear_selection_button.text = "❌ Limpar"
	clear_selection_button.rect_min_size = Vector2(75, 35)
	clear_selection_button.hint_tooltip = "Limpar seleção atual"
	clear_selection_button.connect("pressed", self, "_on_clear_selection")
	toolbar.add_child(clear_selection_button)

func create_size_control_section():
	"""Cria seção de controle de tamanho"""
	
	size_control_section = VBoxContainer.new()
	size_control_section.rect_position = Vector2(10, 85)
	size_control_section.rect_size = Vector2(330, 45)
	size_control_section.add_constant_override("separation", 5)
	main_panel.add_child(size_control_section)
	
	# Container horizontal para label e valor
	var size_header = HBoxContainer.new()
	size_control_section.add_child(size_header)
	
	# Label do tamanho
	size_label = Label.new()
	size_label.text = "Tamanho da Ferramenta:"
	size_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_header.add_child(size_label)
	
	# Label do valor atual
	size_value_label = Label.new()
	size_value_label.text = str(int(tool_size)) + "px"
	size_value_label.align = Label.ALIGN_RIGHT
	size_value_label.rect_min_size.x = 50
	size_value_label.add_color_override("font_color", Color.yellow)
	size_header.add_child(size_value_label)
	
	# Slider de tamanho
	size_slider = HSlider.new()
	size_slider.min_value = min_tool_size
	size_slider.max_value = max_tool_size
	size_slider.value = tool_size
	size_slider.step = 5.0
	size_slider.rect_min_size.y = 20
	size_slider.connect("value_changed", self, "_on_size_changed")
	size_control_section.add_child(size_slider)

func create_density_control_section():
	"""NOVA: Cria seção de controle de densidade"""
	
	density_control_section = VBoxContainer.new()
	density_control_section.rect_position = Vector2(10, 135)
	density_control_section.rect_size = Vector2(330, 45)
	density_control_section.add_constant_override("separation", 5)
	main_panel.add_child(density_control_section)
	
	# Container horizontal para label e valor
	var density_header = HBoxContainer.new()
	density_control_section.add_child(density_header)
	
	# Label da densidade
	density_label = Label.new()
	density_label.text = "Densidade de Itens:"
	density_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	density_header.add_child(density_label)
	
	# Label do valor atual
	density_value_label = Label.new()
	density_value_label.text = str(int(items_density * 100)) + "%"
	density_value_label.align = Label.ALIGN_RIGHT
	density_value_label.rect_min_size.x = 50
	density_value_label.add_color_override("font_color", Color.lightgreen)
	density_header.add_child(density_value_label)
	
	# Slider de densidade
	density_slider = HSlider.new()
	density_slider.min_value = min_density
	density_slider.max_value = max_density
	density_slider.value = items_density
	density_slider.step = 0.1
	density_slider.rect_min_size.y = 20
	density_slider.connect("value_changed", self, "_on_density_changed")
	density_control_section.add_child(density_slider)

func _on_size_changed(new_value: float):
	"""Tamanho da ferramenta mudou"""
	
	tool_size = new_value
	size_value_label.text = str(int(tool_size)) + "px"
	
	update_info_text()
	emit_signal("tool_changed", current_tool, selected_item_id, tool_size, items_density)

func _on_density_changed(new_value: float):
	"""NOVA: Densidade mudou"""
	
	items_density = new_value
	density_value_label.text = str(int(items_density * 100)) + "%"
	
	update_info_text()
	emit_signal("tool_changed", current_tool, selected_item_id, tool_size, items_density)

func _on_tool_selected(tool_mode: int):
	"""Ferramenta selecionada"""
	
	current_tool = tool_mode
	update_toolbar_visual()
	update_info_text()
	
	emit_signal("tool_changed", current_tool, selected_item_id, tool_size, items_density)

func _on_clear_selection():
	"""Limpa seleção atual"""
	
	current_tool = ToolMode.NONE
	selected_item_id = ""
	update_toolbar_visual()
	update_info_text()
	clear_item_selection()
	
	emit_signal("tool_changed", current_tool, selected_item_id, tool_size, items_density)

func update_toolbar_visual():
	"""Atualiza visual da toolbar"""
	
	# Reset de cores
	brush_button.modulate = Color.white
	pencil_button.modulate = Color.white
	eraser_button.modulate = Color.white
	
	# Destaca ferramenta ativa
	match current_tool:
		ToolMode.BRUSH:
			brush_button.modulate = Color.yellow
		ToolMode.PENCIL:
			pencil_button.modulate = Color.yellow
		ToolMode.ERASER:
			eraser_button.modulate = Color.yellow

func update_info_text():
	"""ATUALIZADO: Atualiza texto informativo com densidade"""
	
	var size_text = " (" + str(int(tool_size)) + "px"
	var density_text = ", " + str(int(items_density * 100)) + "%)"
	var full_info = size_text + density_text
	
	match current_tool:
		ToolMode.BRUSH:
			if selected_item_id != "":
				info_label.text = "Pincel" + full_info + ": Mantenha pressionado para pintar " + get_item_name(selected_item_id)
				info_label.add_color_override("font_color", Color.green)
			else:
				info_label.text = "Pincel" + full_info + " selecionado - Escolha um item"
				info_label.add_color_override("font_color", Color.yellow)
		
		ToolMode.PENCIL:
			if selected_item_id != "":
				info_label.text = "Lápis" + full_info + ": Clique para colocar " + get_item_name(selected_item_id)
				info_label.add_color_override("font_color", Color.green)
			else:
				info_label.text = "Lápis" + full_info + " selecionado - Escolha um item"
				info_label.add_color_override("font_color", Color.yellow)
		
		ToolMode.ERASER:
			info_label.text = "Borracha (" + str(int(tool_size)) + "px): Mantenha pressionado para apagar"
			info_label.add_color_override("font_color", Color.red)
		
		ToolMode.NONE:
			info_label.text = "Selecione uma ferramenta e ajuste tamanho/densidade"
			info_label.add_color_override("font_color", Color.lightgray)

func get_item_name(item_id: String) -> String:
	"""Retorna nome do item"""
	var item_data = catalog.get_item_data(item_id)
	return item_data.get("name", item_id)

func populate_categories():
	"""Popula as abas de categorias"""
	
	var categories = catalog.get_all_categories()
	
	for category in categories:
		create_category_tab(category)

func create_category_tab(category: String):
	"""Cria uma aba de categoria"""
	
	var category_container = VBoxContainer.new()
	category_container.name = category.capitalize()
	category_tabs.add_child(category_container)
	
	var scroll = ScrollContainer.new()
	scroll.rect_min_size.y = 210  # Ajustado para novo layout
	scroll.scroll_horizontal_enabled = false
	category_container.add_child(scroll)
	
	var grid = GridContainer.new()
	grid.columns = items_per_row
	grid.add_constant_override("hseparation", 8)
	grid.add_constant_override("vseparation", 8)
	scroll.add_child(grid)
	
	var items = catalog.get_items_by_category(category)
	
	for item_info in items:
		create_item_button(grid, item_info.id, item_info.data)

func create_item_button(parent: GridContainer, item_id: String, item_data: Dictionary):
	"""Cria botão para um item"""
	
	var button = Button.new()
	button.rect_min_size = Vector2(70, 70)
	button.hint_tooltip = item_data.get("description", "")
	button.name = "item_" + item_id
	
	var vbox = VBoxContainer.new()
	button.add_child(vbox)
	
	var icon_container = CenterContainer.new()
	icon_container.rect_min_size.y = 45
	vbox.add_child(icon_container)
	
	var icon = TextureRect.new()
	icon.rect_min_size = Vector2(40, 40)
	icon.expand = true
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var texture_path = item_data.get("texture_path", "")
	if texture_path != "" and ResourceLoader.exists(texture_path):
		icon.texture = load(texture_path)
	else:
		var preview_texture = create_preview_texture(item_data.get("category", "geral"))
		icon.texture = preview_texture
	
	icon_container.add_child(icon)
	
	var label = Label.new()
	label.text = item_data.get("name", item_id)
	label.align = Label.ALIGN_CENTER
	label.autowrap = true
	label.rect_min_size.y = 20
	vbox.add_child(label)
	
	button.connect("pressed", self, "_on_item_button_pressed", [item_id])
	
	parent.add_child(button)

func create_preview_texture(category: String) -> ImageTexture:
	"""Cria preview colorido baseado na categoria"""
	
	var color = Color.gray
	match category:
		"natureza":
			color = Color.green
		"pedras":
			color = Color(0.5, 0.4, 0.3)
		"cristais":
			color = Color.magenta
		"agua":
			color = Color.blue
		"estruturas":
			color = Color(0.6, 0.6, 0.6)
		_:
			color = Color.gray
	
	var texture = ImageTexture.new()
	var image = Image.new()
	image.create(32, 32, false, Image.FORMAT_RGB8)
	image.fill(color)
	texture.create_from_image(image)
	return texture

func _on_item_button_pressed(item_id: String):
	"""Item selecionado"""
	
	selected_item_id = item_id
	update_item_selection_visual(item_id)
	update_info_text()
	
	# Se não tem ferramenta, seleciona lápis automaticamente
	if current_tool == ToolMode.NONE:
		current_tool = ToolMode.PENCIL
		update_toolbar_visual()
	
	print("Item selecionado: ", item_id, " | Ferramenta: ", current_tool, " | Tamanho: ", tool_size, " | Densidade: ", int(items_density * 100), "%")
	emit_signal("tool_changed", current_tool, selected_item_id, tool_size, items_density)

func update_item_selection_visual(selected_id: String):
	"""Atualiza visual de seleção dos itens"""
	
	clear_item_selection()
	
	var selected_button = find_item_button(selected_id)
	if selected_button:
		selected_button.modulate = Color.cyan

func clear_item_selection():
	"""Limpa seleção visual de todos os itens"""
	
	for tab_index in range(category_tabs.get_tab_count()):
		var tab = category_tabs.get_tab_control(tab_index)
		var buttons = get_all_buttons_in_node(tab)
		for button in buttons:
			if button.name.begins_with("item_"):
				button.modulate = Color.white

func find_item_button(item_id: String) -> Button:
	"""Encontra botão de um item específico"""
	
	for tab_index in range(category_tabs.get_tab_count()):
		var tab = category_tabs.get_tab_control(tab_index)
		var buttons = get_all_buttons_in_node(tab)
		for button in buttons:
			if button.name == "item_" + item_id:
				return button
	return null

func get_all_buttons_in_node(node: Node) -> Array:
	"""Recursivamente encontra todos os botões em um nó"""
	
	var buttons = []
	
	if node is Button:
		buttons.append(node)
	
	for child in node.get_children():
		buttons += get_all_buttons_in_node(child)
	
	return buttons

func _on_close_pressed():
	"""Fechar editor"""
	
	emit_signal("decoration_mode_exit")

func show_ui():
	"""Mostra a UI"""
	
	visible = true
	position_ui_to_right()

func hide_ui():
	"""Esconde a UI"""
	
	visible = false

func get_catalog() -> DecorationCatalog:
	"""Retorna o catálogo"""
	return catalog

func get_current_tool() -> int:
	"""Retorna ferramenta atual"""
	return current_tool

func get_selected_item_id() -> String:
	"""Retorna item selecionado"""
	return selected_item_id

func get_tool_size() -> float:
	"""Retorna tamanho da ferramenta"""
	return tool_size

func get_items_density() -> float:
	"""NOVO: Retorna densidade dos itens"""
	return items_density

func can_place_item() -> bool:
	"""Verifica se pode colocar item"""
	return current_tool != ToolMode.NONE and (current_tool == ToolMode.ERASER or selected_item_id != "")

func _process(_delta):
	"""Mantém UI sempre visível e posicionada"""
	
	if visible:
		var viewport_size = get_viewport().size
		var expected_x = viewport_size.x - rect_size.x - 20
		
		if abs(rect_position.x - expected_x) > 10:
			position_ui_to_right()
