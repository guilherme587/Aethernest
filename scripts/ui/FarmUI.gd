# FarmUI.gd - Interface principal do sistema de fazendas
class_name FarmUI
extends Control

# Componentes da UI
var main_panel: Panel
var header_section: VBoxContainer
var farm_selection_section: VBoxContainer
var farm_details_section: VBoxContainer
var close_button: Button

# Labels informativos
var mode_label: Label
var info_label: Label
var selected_farm_label: Label

# Grid de seleção de fazendas
var farm_grid: GridContainer

# Detalhes da fazenda selecionada
var details_panel: Panel
var details_content: VBoxContainer
var upgrade_button: Button
var collect_button: Button

# Estado
var selected_farm_type: int = -1
var current_selected_farm = null

# Dados das fazendas (referência do manager)
var farm_data: Dictionary

# Sinais
signal farm_type_selected(farm_type)
signal farm_mode_exit
signal farm_upgraded(farm)
signal food_collected(farm)

func _ready():
	"""Inicialização da UI"""
	
	create_ui()
	visible = false

func create_ui():
	"""Cria interface das fazendas"""
	
	# Posicionamento à esquerda da tela
	position_ui_to_left()
	
	# Painel principal
	main_panel = Panel.new()
	main_panel.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	main_panel.modulate = Color(1, 1, 1, 0.95)
	add_child(main_panel)
	
	create_header_section()
	create_farm_selection_section()
	create_farm_details_section()
	create_close_button()

func position_ui_to_left():
	"""Posiciona UI no lado esquerdo da tela"""
	
	var viewport_size = get_viewport().size
	var panel_width = 400
	var panel_height = 600
	var margin = 20
	
	set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT)
	rect_position = Vector2(margin, margin)
	rect_size = Vector2(panel_width, panel_height)

func create_header_section():
	"""Cria seção do cabeçalho"""
	
	header_section = VBoxContainer.new()
	header_section.rect_position = Vector2(10, 10)
	header_section.rect_size = Vector2(380, 60)
	header_section.add_constant_override("separation", 5)
	main_panel.add_child(header_section)
	
	# Título
	mode_label = Label.new()
	mode_label.text = "🏭 SISTEMA DE FAZENDAS"
	mode_label.align = Label.ALIGN_CENTER
	mode_label.add_color_override("font_color", Color.gold)
	header_section.add_child(mode_label)
	
	# Informações
	info_label = Label.new()
	info_label.text = "Selecione um tipo de fazenda para colocar no mapa"
	info_label.align = Label.ALIGN_CENTER
	info_label.add_color_override("font_color", Color.lightgray)
	info_label.autowrap = true
	header_section.add_child(info_label)
	
	# Fazenda selecionada
	selected_farm_label = Label.new()
	selected_farm_label.text = "Nenhuma fazenda selecionada"
	selected_farm_label.align = Label.ALIGN_CENTER
	selected_farm_label.add_color_override("font_color", Color.yellow)
	header_section.add_child(selected_farm_label)

func create_farm_selection_section():
	"""Cria seção de seleção de fazendas"""
	
	farm_selection_section = VBoxContainer.new()
	farm_selection_section.rect_position = Vector2(10, 80)
	farm_selection_section.rect_size = Vector2(380, 300)
	farm_selection_section.add_constant_override("separation", 10)
	main_panel.add_child(farm_selection_section)
	
	# Título da seção
	var selection_title = Label.new()
	selection_title.text = "TIPOS DE FAZENDA"
	selection_title.align = Label.ALIGN_CENTER
	selection_title.add_color_override("font_color", Color.cyan)
	farm_selection_section.add_child(selection_title)
	
	# Scroll para fazendas
	var scroll = ScrollContainer.new()
	scroll.rect_min_size.y = 260
	scroll.scroll_horizontal_enabled = false
	farm_selection_section.add_child(scroll)
	
	# Grid de fazendas
	farm_grid = GridContainer.new()
	farm_grid.columns = 2
	farm_grid.add_constant_override("hseparation", 10)
	farm_grid.add_constant_override("vseparation", 10)
	scroll.add_child(farm_grid)

func create_farm_details_section():
	"""Cria seção de detalhes da fazenda"""
	
	farm_details_section = VBoxContainer.new()
	farm_details_section.rect_position = Vector2(10, 390)
	farm_details_section.rect_size = Vector2(380, 150)
	farm_details_section.add_constant_override("separation", 5)
	main_panel.add_child(farm_details_section)
	
	# Título
	var details_title = Label.new()
	details_title.text = "DETALHES DA FAZENDA"
	details_title.align = Label.ALIGN_CENTER
	details_title.add_color_override("font_color", Color.lightgreen)
	farm_details_section.add_child(details_title)
	
	# Painel de detalhes
	details_panel = Panel.new()
	details_panel.rect_min_size.y = 120
	details_panel.modulate = Color(0.2, 0.2, 0.2, 0.8)
	farm_details_section.add_child(details_panel)
	
	# Conteúdo dos detalhes
	details_content = VBoxContainer.new()
	details_content.rect_position = Vector2(10, 10)
	details_content.rect_size = Vector2(360, 100)
	details_content.add_constant_override("separation", 3)
	details_panel.add_child(details_content)
	
	# Botões de ação
	var buttons_container = HBoxContainer.new()
	buttons_container.add_constant_override("separation", 10)
	farm_details_section.add_child(buttons_container)
	
	collect_button = Button.new()
	collect_button.text = "🗂️ Coletar"
	collect_button.rect_min_size = Vector2(100, 25)
	collect_button.connect("pressed", self, "_on_collect_pressed")
	collect_button.disabled = true
	buttons_container.add_child(collect_button)
	
	upgrade_button = Button.new()
	upgrade_button.text = "⬆️ Melhorar"
	upgrade_button.rect_min_size = Vector2(100, 25)
	upgrade_button.connect("pressed", self, "_on_upgrade_pressed")
	upgrade_button.disabled = true
	buttons_container.add_child(upgrade_button)

func create_close_button():
	"""Cria botão de fechar"""
	
	close_button = Button.new()
	close_button.text = "FECHAR FAZENDAS (F)"
	close_button.rect_position = Vector2(10, 560)
	close_button.rect_size = Vector2(380, 30)
	close_button.connect("pressed", self, "_on_close_pressed")
	main_panel.add_child(close_button)

func populate_farm_types(farm_data_dict: Dictionary):
	"""Popula tipos de fazenda disponíveis"""
	
	farm_data = farm_data_dict
	
	# Limpa grid existente
	for child in farm_grid.get_children():
		child.queue_free()
	
	# Adiciona cada tipo de fazenda
	for farm_type in farm_data:
		create_farm_type_button(farm_type, farm_data[farm_type])

func create_farm_type_button(farm_type: int, data: Dictionary):
	"""Cria botão para um tipo de fazenda"""
	
	var button = Button.new()
	button.rect_min_size = Vector2(180, 100)
	button.hint_tooltip = data.get("description", "")
	
	# Container vertical
	var vbox = VBoxContainer.new()
	vbox.add_constant_override("separation", 5)
	button.add_child(vbox)
	
	# Ícone
	var icon_label = Label.new()
	icon_label.text = data.get("icon", "🏭")
	icon_label.align = Label.ALIGN_CENTER
	icon_label.rect_min_size.y = 40
	vbox.add_child(icon_label)
	
	# Nome
	var name_label = Label.new()
	name_label.text = data.get("name", "Fazenda")
	name_label.align = Label.ALIGN_CENTER
	name_label.autowrap = true
	name_label.rect_min_size.y = 30
	vbox.add_child(name_label)
	
	# Estatísticas nível 1
	var stats_label = Label.new()
	var level_1_data = data.levels.get(1, {})
	var time = level_1_data.get("production_time", 30)
	var amount = level_1_data.get("production_amount", 3)
	stats_label.text = str(amount) + " itens/" + str(int(time)) + "s"
	stats_label.align = Label.ALIGN_CENTER
	stats_label.add_color_override("font_color", Color.lightgray)
	vbox.add_child(stats_label)
	
	# Cor baseada no tipo
	var color = data.get("color", Color.gray)
	button.modulate = color * 1.2
	
	# Conecta sinal
	button.connect("pressed", self, "_on_farm_type_selected", [farm_type])
	
	farm_grid.add_child(button)

func _on_farm_type_selected(farm_type: int):
	"""Tipo de fazenda selecionado"""
	
	selected_farm_type = farm_type
	
	# Atualiza visual de seleção
	update_selection_visual(farm_type)
	
	# Atualiza labels
	var farm_name = farm_data[farm_type].get("name", "Fazenda")
	selected_farm_label.text = "Selecionado: " + farm_name
	info_label.text = "Clique no mapa para colocar a fazenda"
	info_label.add_color_override("font_color", Color.green)
	
	emit_signal("farm_type_selected", farm_type)

func update_selection_visual(selected_type: int):
	"""Atualiza visual de seleção"""
	
	# Reset de todas as fazendas
	for i in range(farm_grid.get_child_count()):
		var button = farm_grid.get_child(i)
		if button is Button:
			var farm_type = i  # Assume ordem correta
			var color = farm_data[farm_type].get("color", Color.gray)
			button.modulate = color * 1.2
	
	# Destaca selecionada
	if selected_type >= 0 and selected_type < farm_grid.get_child_count():
		var selected_button = farm_grid.get_child(selected_type)
		if selected_button is Button:
			selected_button.modulate = Color.yellow

func show_farm_details(farm):
	"""Mostra detalhes de uma fazenda específica"""
	
	current_selected_farm = farm
	
	if not farm:
		hide_farm_details()
		return
	
	var farm_info = farm.get_farm_info()
	
	# Limpa conteúdo anterior
	for child in details_content.get_children():
		child.queue_free()
	
	# Informações da fazenda
	add_detail_label("Fazenda: " + farm_info.get("name", "Unknown"))
	add_detail_label("Nível: " + str(farm_info.get("level", 1)) + "/3")
	add_detail_label("Produção: " + str(farm_info.get("production_amount", 0)) + " a cada " + str(farm_info.get("production_time", 0)) + "s")
	add_detail_label("Armazenamento: " + str(farm_info.get("current_storage", 0)) + "/" + str(farm_info.get("storage_capacity", 0)))
	
	if farm_info.get("can_upgrade", false):
		add_detail_label("Custo melhoria: " + str(farm_info.get("upgrade_cost", 0)) + " moedas")
	else:
		add_detail_label("Nível máximo atingido!")
	
	# Habilita botões
	collect_button.disabled = farm_info.get("current_storage", 0) <= 0
	upgrade_button.disabled = not farm_info.get("can_upgrade", false)

func add_detail_label(text: String):
	"""Adiciona label de detalhe"""
	
	var label = Label.new()
	label.text = text
	label.add_color_override("font_color", Color.white)
	details_content.add_child(label)

func hide_farm_details():
	"""Esconde detalhes da fazenda"""
	
	current_selected_farm = null
	
	# Limpa conteúdo
	for child in details_content.get_children():
		child.queue_free()
	
	var no_selection_label = Label.new()
	no_selection_label.text = "Clique em uma fazenda para ver detalhes"
	no_selection_label.align = Label.ALIGN_CENTER
	no_selection_label.add_color_override("font_color", Color.lightgray)
	details_content.add_child(no_selection_label)
	
	# Desabilita botões
	collect_button.disabled = true
	upgrade_button.disabled = true

func _on_collect_pressed():
	"""Botão coletar pressionado"""
	
	if current_selected_farm:
		emit_signal("food_collected", current_selected_farm)
		# Atualiza detalhes
		show_farm_details(current_selected_farm)

func _on_upgrade_pressed():
	"""Botão melhorar pressionado"""
	
	if current_selected_farm:
		emit_signal("farm_upgraded", current_selected_farm)
		# Atualiza detalhes
		show_farm_details(current_selected_farm)

func _on_close_pressed():
	"""Botão fechar pressionado"""
	
	emit_signal("farm_mode_exit")

func show_ui():
	"""Mostra a UI"""
	
	visible = true
	position_ui_to_left()
	
	# Popula fazendas se não foram populadas
	if farm_grid.get_child_count() == 0 and not farm_data.empty():
		populate_farm_types(farm_data)

func hide_ui():
	"""Esconde a UI"""
	
	visible = false
	selected_farm_type = -1
	hide_farm_details()

func _process(_delta):
	"""Mantém UI posicionada"""
	
	if visible:
		var viewport_size = get_viewport().size
		var expected_x = 20
		
		if abs(rect_position.x - expected_x) > 10:
			position_ui_to_left()
