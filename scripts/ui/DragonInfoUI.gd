# DragonInfoUI.gd - Interface completa com preferências de decoração
class_name DragonInfoUI
extends Control

var Enums = preload("res://scripts/utils/Enums.gd")

# Componentes principais
var main_panel: Panel
var scroll_container: ScrollContainer
var content_vbox: VBoxContainer

# Seções
var header_section: VBoxContainer
var stats_section: VBoxContainer
var personality_section: VBoxContainer
var decoration_section: VBoxContainer  # NOVA SEÇÃO
var attributes_section: VBoxContainer
var state_section: VBoxContainer

# Labels principais
var dragon_name_label: Label
var level_label: Label
var description_label: RichTextLabel
var personality_label: Label
var state_label: Label

# NOVOS: Labels de decoração
var decoration_preferences_label: Label
var decoration_satisfaction_label: Label
var decoration_status_label: Label

# Barras de status
var satiety_bar: ProgressBar
var satisfaction_bar: ProgressBar
var energy_bar: ProgressBar
var health_bar: ProgressBar
var decoration_satisfaction_bar: ProgressBar  # NOVA BARRA

# Labels das barras
var satiety_label: Label
var satisfaction_label: Label
var energy_label: Label
var health_label: Label
var decoration_satisfaction_bar_label: Label  # NOVO LABEL

# Atributos
var attributes_grid: GridContainer

# Botão fechar
var close_button: Button

var current_dragon: Dragon = null
var is_positioned = false
var is_updating_attributes = false

# NOVO: Visualização da área de satisfação
var area_visualization: Node2D
var area_toggle_button: Button

signal close_requested

func _ready():
	create_interface()
	set_initial_position()
	visible = false

func create_interface():
	"""Cria toda a interface programaticamente"""

	# Painel principal - AUMENTADO para acomodar nova seção
	main_panel = Panel.new()
	main_panel.rect_size = Vector2(350, 650)  # Aumentado
	add_child(main_panel)

	# Container de scroll
	scroll_container = ScrollContainer.new()
	scroll_container.rect_position = Vector2(10, 10)
	scroll_container.rect_size = Vector2(330, 630)  # Aumentado
	scroll_container.scroll_horizontal_enabled = false
	main_panel.add_child(scroll_container)

	# Container principal vertical
	content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_constant_override("separation", 5)
	scroll_container.add_child(content_vbox)

	# Cria seções
	create_header_section()
	create_stats_section()
	create_personality_section()
	create_decoration_section()  # NOVA SEÇÃO
	create_attributes_section()
	create_state_section()
	create_close_button()

	call_deferred("adjust_scroll_container")

func adjust_scroll_container():
	"""Ajusta o container de scroll para funcionar corretamente"""

	content_vbox.rect_size = content_vbox.get_combined_minimum_size()
	var total_height = content_vbox.rect_size.y + 80  # Mais espaço
	content_vbox.rect_min_size.y = total_height

func set_initial_position():
	"""Define posição inicial sem yield"""

	var panel_width = 350
	var panel_height = 650  # Aumentado
	var margin_right = 20
	var margin_top = 20

	var global_x = margin_right
	var global_y = margin_top

	rect_position = Vector2(global_x, global_y)
	rect_size = Vector2(panel_width, panel_height)

	is_positioned = true

func position_interface():
	"""Reposiciona interface quando necessário"""

	if not is_positioned:
		set_initial_position()
		return

	var viewport_size = get_viewport().size
	var panel_width = 350
	var panel_height = 650  # Aumentado
	var margin_right = 20
	var margin_top = 20

	var desired_x = margin_right
	var desired_y = margin_top

	if abs(rect_position.x - desired_x) > 5 or abs(rect_position.y - desired_y) > 5:
		rect_position = Vector2(desired_x, desired_y)

func _on_viewport_size_changed():
	"""Reposiciona quando a tela muda de tamanho"""

	if visible and is_positioned:
		call_deferred("position_interface")

# === MANTÉM TODAS AS FUNÇÕES EXISTENTES ===

func create_header_section():
	"""Cria seção do cabeçalho"""

	header_section = VBoxContainer.new()
	header_section.name = "HeaderSection"
	content_vbox.add_child(header_section)

	var title_label = Label.new()
	title_label.text = "INFORMAÇÕES DO DRAGÃO"
	title_label.align = Label.ALIGN_CENTER
	title_label.add_color_override("font_color", Color.cyan)
	header_section.add_child(title_label)

	var separator1 = HSeparator.new()
	header_section.add_child(separator1)

	dragon_name_label = Label.new()
	dragon_name_label.text = "Nome do Dragão"
	dragon_name_label.align = Label.ALIGN_CENTER
	dragon_name_label.add_color_override("font_color", Color.white)
	header_section.add_child(dragon_name_label)

	level_label = Label.new()
	level_label.text = "Nível: 1"
	level_label.align = Label.ALIGN_CENTER
	level_label.add_color_override("font_color", Color.yellow)
	header_section.add_child(level_label)

	description_label = RichTextLabel.new()
	description_label.rect_min_size.y = 80
	description_label.bbcode_enabled = true
	description_label.bbcode_text = "[center][i]Descrição do dragão aparecerá aqui...[/i][/center]"
	header_section.add_child(description_label)

	var separator2 = HSeparator.new()
	header_section.add_child(separator2)

func create_stats_section():
	"""Cria seção de estatísticas"""

	stats_section = VBoxContainer.new()
	stats_section.name = "StatsSection"
	content_vbox.add_child(stats_section)

	var stats_title = Label.new()
	stats_title.text = "ESTATÍSTICAS"
	stats_title.align = Label.ALIGN_CENTER
	stats_title.add_color_override("font_color", Color.lightgreen)
	stats_section.add_child(stats_title)

	create_stat_bar(stats_section, "SACIEDADE", "satiety")
	create_stat_bar(stats_section, "SATISFAÇÃO", "satisfaction")
	create_stat_bar(stats_section, "ENERGIA", "energy")
	create_stat_bar(stats_section, "VIDA", "health")

	var separator = HSeparator.new()
	stats_section.add_child(separator)

func create_stat_bar(parent: VBoxContainer, title: String, type: String):
	"""Cria uma barra de estatística"""

	var container = VBoxContainer.new()
	container.add_constant_override("separation", 3)
	parent.add_child(container)

	var label = Label.new()
	label.text = title + ": 0/100"
	container.add_child(label)

	var progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = 50
	progress_bar.rect_min_size.y = 20
	container.add_child(progress_bar)

	var spacer = Control.new()
	spacer.rect_min_size.y = 3
	container.add_child(spacer)

	match type:
		"satiety":
			satiety_label = label
			satiety_bar = progress_bar
		"satisfaction":
			satisfaction_label = label
			satisfaction_bar = progress_bar
		"energy":
			energy_label = label
			energy_bar = progress_bar
		"health":
			health_label = label
			health_bar = progress_bar

func create_personality_section():
	"""Cria seção de personalidade"""

	personality_section = VBoxContainer.new()
	personality_section.name = "PersonalitySection"
	content_vbox.add_child(personality_section)

	var personality_title = Label.new()
	personality_title.text = "PERSONALIDADE"
	personality_title.align = Label.ALIGN_CENTER
	personality_title.add_color_override("font_color", Color.pink)
	personality_section.add_child(personality_title)

	personality_label = Label.new()
	personality_label.text = "Personalidade será mostrada aqui..."
	personality_label.autowrap = true
	personality_label.rect_min_size.x = 300
	personality_section.add_child(personality_label)

	var separator = HSeparator.new()
	personality_section.add_child(separator)

func create_decoration_section():
	"""NOVA: Cria seção de decorações"""
	
	decoration_section = VBoxContainer.new()
	decoration_section.name = "DecorationSection"
	content_vbox.add_child(decoration_section)
	
	# Título da seção
	var decoration_title = Label.new()
	decoration_title.text = "PREFERÊNCIAS DE DECORAÇÃO"
	decoration_title.align = Label.ALIGN_CENTER
	decoration_title.add_color_override("font_color", Color.gold)
	decoration_section.add_child(decoration_title)
	
	# Barra de satisfação com decorações
	var satisfaction_container = VBoxContainer.new()
	satisfaction_container.add_constant_override("separation", 3)
	decoration_section.add_child(satisfaction_container)
	
	decoration_satisfaction_bar_label = Label.new()
	decoration_satisfaction_bar_label.text = "SATISFAÇÃO COM DECORAÇÕES: 50/100"
	satisfaction_container.add_child(decoration_satisfaction_bar_label)
	
	decoration_satisfaction_bar = ProgressBar.new()
	decoration_satisfaction_bar.min_value = 0
	decoration_satisfaction_bar.max_value = 100
	decoration_satisfaction_bar.value = 50
	decoration_satisfaction_bar.rect_min_size.y = 20
	satisfaction_container.add_child(decoration_satisfaction_bar)
	
	# Status da satisfação
	decoration_status_label = Label.new()
	decoration_status_label.text = "Status: Analisando..."
	decoration_status_label.add_color_override("font_color", Color.lightblue)
	decoration_section.add_child(decoration_status_label)
	
	# Preferências de decoração
	decoration_preferences_label = Label.new()
	decoration_preferences_label.text = "Carregando preferências..."
	decoration_preferences_label.autowrap = true
	decoration_preferences_label.rect_min_size.x = 300
	decoration_section.add_child(decoration_preferences_label)
	
	# Botão para mostrar/esconder área de satisfação
	area_toggle_button = Button.new()
	area_toggle_button.text = "Mostrar Área de Satisfação"
	area_toggle_button.rect_min_size.y = 25
	area_toggle_button.connect("pressed", self, "_on_area_toggle_pressed")
	decoration_section.add_child(area_toggle_button)
	
	# Separador
	var separator = HSeparator.new()
	decoration_section.add_child(separator)

func _on_area_toggle_pressed():
	"""NOVO: Alterna visualização da área de satisfação"""
	
	if not current_dragon:
		return
	
	if area_visualization and is_instance_valid(area_visualization):
		# Remove visualização
		area_visualization.queue_free()
		area_visualization = null
		area_toggle_button.text = "Mostrar Área de Satisfação"
	else:
		# Cria visualização
		create_area_visualization()
		area_toggle_button.text = "Esconder Área de Satisfação"

func create_area_visualization():
	"""NOVO: Cria visualização da área de satisfação"""
	
	if not current_dragon:
		return
	
	area_visualization = Node2D.new()
	area_visualization.name = "SatisfactionAreaVisualization"
	current_dragon.add_child(area_visualization)
	
	# Círculo da área de satisfação
	var circle_points = []
	var radius = current_dragon.personality.get_satisfaction_area_radius()
	var segments = 64
	
	for i in range(segments + 1):
		var angle = i * 2 * PI / segments
		var point = Vector2(cos(angle), sin(angle)) * radius
		circle_points.append(point)
	
	# Cria linha do círculo
	var line = Line2D.new()
	line.points = PoolVector2Array(circle_points)
	line.width = 3.0
	line.default_color = Color.gold
	line.default_color.a = 0.7
	area_visualization.add_child(line)
	
	# Cria área preenchida
	var area_polygon = Polygon2D.new()
	area_polygon.polygon = PoolVector2Array(circle_points)
	area_polygon.color = Color.gold
	area_polygon.color.a = 0.1
	area_visualization.add_child(area_polygon)
	
	# Label indicativa
	var label = Label.new()
	label.text = "Área de Satisfação"
	label.rect_position = Vector2(-50, -radius - 20)
	label.add_color_override("font_color", Color.gold)
	area_visualization.add_child(label)
	
	print("Área de satisfação visualizada - Raio: ", radius)

# === MANTÉM OUTRAS FUNÇÕES EXISTENTES ===

func create_attributes_section():
	"""Cria seção de atributos"""

	attributes_section = VBoxContainer.new()
	attributes_section.name = "AttributesSection"
	content_vbox.add_child(attributes_section)

	var attributes_title = Label.new()
	attributes_title.text = "ATRIBUTOS"
	attributes_title.align = Label.ALIGN_CENTER
	attributes_title.add_color_override("font_color", Color.orange)
	attributes_section.add_child(attributes_title)

	attributes_grid = GridContainer.new()
	attributes_grid.columns = 2
	attributes_grid.add_constant_override("hseparation", 10)
	attributes_grid.add_constant_override("vseparation", 3)
	attributes_section.add_child(attributes_grid)

	var separator = HSeparator.new()
	attributes_section.add_child(separator)

func create_state_section():
	"""Cria seção de estado"""

	state_section = VBoxContainer.new()
	state_section.name = "StateSection"
	content_vbox.add_child(state_section)

	var state_title = Label.new()
	state_title.text = "ESTADO ATUAL"
	state_title.align = Label.ALIGN_CENTER
	state_title.add_color_override("font_color", Color.violet)
	state_section.add_child(state_title)

	state_label = Label.new()
	state_label.text = "Estado: Desconhecido"
	state_label.align = Label.ALIGN_CENTER
	state_label.add_color_override("font_color", Color.white)
	state_section.add_child(state_label)

func create_close_button():
	"""Cria botão de fechar"""

	close_button = Button.new()
	close_button.text = "FECHAR"
	close_button.rect_min_size.y = 30
	close_button.connect("pressed", self, "_on_close_pressed")
	content_vbox.add_child(close_button)

	var final_spacer = Control.new()
	final_spacer.rect_min_size.y = 20
	content_vbox.add_child(final_spacer)

func show_dragon_info(dragon: Dragon):
	"""Mostra informações do dragão"""

	if not dragon or not is_instance_valid(dragon):
		return

	current_dragon = dragon

	# Conecta sinais existentes
	if not dragon.is_connected("stats_updated", self, "_on_dragon_stats_updated"):
		dragon.connect("stats_updated", self, "_on_dragon_stats_updated")

	if not dragon.behavior.is_connected("state_changed", self, "_on_dragon_state_changed"):
		dragon.behavior.connect("state_changed", self, "_on_dragon_state_changed")
	
	# NOVO: Conecta sinal de satisfação com decorações
	if not dragon.personality.is_connected("decoration_satisfaction_changed", self, "_on_decoration_satisfaction_changed"):
		dragon.personality.connect("decoration_satisfaction_changed", self, "_on_decoration_satisfaction_changed")

	update_all_info()

	if not is_positioned:
		set_initial_position()

	visible = true

func hide_dragon_info():
	"""Esconde interface"""

	visible = false
	
	# Remove visualização da área se existir
	if area_visualization and is_instance_valid(area_visualization):
		area_visualization.queue_free()
		area_visualization = null

	# Desconecta sinais
	if current_dragon and is_instance_valid(current_dragon):
		if current_dragon.is_connected("stats_updated", self, "_on_dragon_stats_updated"):
			current_dragon.disconnect("stats_updated", self, "_on_dragon_stats_updated")

		if current_dragon.behavior.is_connected("state_changed", self, "_on_dragon_state_changed"):
			current_dragon.behavior.disconnect("state_changed", self, "_on_dragon_state_changed")
		
		# NOVO: Desconecta sinal de decorações
		if current_dragon.personality.is_connected("decoration_satisfaction_changed", self, "_on_decoration_satisfaction_changed"):
			current_dragon.personality.disconnect("decoration_satisfaction_changed", self, "_on_decoration_satisfaction_changed")

	current_dragon = null

func update_all_info():
	"""Atualiza todas as informações"""

	if not current_dragon:
		return

	# Informações existentes
	dragon_name_label.text = current_dragon.stats.dragon_name
	level_label.text = "Nível: " + str(current_dragon.stats.level)

	var type_color = get_dragon_type_color(current_dragon.stats.dragon_type)
	dragon_name_label.add_color_override("font_color", type_color)

	description_label.bbcode_text = generate_description()

	update_personality_info()
	update_stats()
	call_deferred("update_attributes")
	update_state()
	
	# NOVO: Atualiza informações de decoração
	update_decoration_info()
	
	call_deferred("adjust_scroll_container")

func update_decoration_info():
	"""NOVO: Atualiza informações de decoração"""
	
	if not current_dragon or not current_dragon.personality:
		return
	
	# Atualiza satisfação atual
	var decoration_nodes = get_tree().get_nodes_in_group("decorations")
	current_dragon.personality.update_decoration_satisfaction(current_dragon.global_position, decoration_nodes)
	
	
	# Atualiza barra de satisfação
	var satisfaction = current_dragon.personality.decoration_satisfaction
	decoration_satisfaction_bar.value = satisfaction
	decoration_satisfaction_bar_label.text = "SATISFAÇÃO COM DECORAÇÕES: " + str(int(satisfaction)) + "/100"
	
	# Cor da barra baseada na satisfação
	if satisfaction >= 80:
		decoration_satisfaction_bar.modulate = Color.green
	elif satisfaction >= 60:
		decoration_satisfaction_bar.modulate = Color.yellow
	elif satisfaction >= 40:
		decoration_satisfaction_bar.modulate = Color.orange
	else:
		decoration_satisfaction_bar.modulate = Color.red
	
	# Status da satisfação
	decoration_status_label.text = current_dragon.personality.get_satisfaction_status_text()
	
	# Preferências de decoração
	decoration_preferences_label.text = current_dragon.personality.get_decoration_preferences_text()

func _on_decoration_satisfaction_changed(new_value: float):
	"""NOVO: Satisfação com decorações mudou"""
	
	if visible:
		update_decoration_info()

# === MANTÉM TODAS AS OUTRAS FUNÇÕES EXISTENTES ===

func generate_description() -> String:
	"""Gera descrição do dragão"""

	var personality = current_dragon.personality

	match personality.primary_trait:
		Enums.PersonalityTrait.CURIOUS:
			return "[center][color=lightblue]Este dragão adora explorar cada cantinho do mundo. Sempre em busca de novas aventuras![/color][/center]"
		Enums.PersonalityTrait.AGGRESSIVE:
			return "[center][color=red]Um dragão feroz que não hesita em mostrar suas garras. Cuidado ao se aproximar![/color][/center]"
		Enums.PersonalityTrait.LAZY:
			return "[center][color=brown]Prefere passar o dia descansando sob o sol. A preguiça é sua especialidade.[/color][/center]"
		Enums.PersonalityTrait.SOLITARY:
			return "[center][color=gray]Um solitário que valoriza sua privacidade. Gosta de ficar sozinho.[/color][/center]"
		Enums.PersonalityTrait.SOCIAL:
			return "[center][color=yellow]Adora a companhia de outros dragões. Muito sociável e amigável![/color][/center]"
		Enums.PersonalityTrait.TERRITORIAL:
			return "[center][color=orange]Guarda zelosamente seu território pessoal. Não gosta de invasores.[/color][/center]"
		Enums.PersonalityTrait.PEACEFUL:
			return "[center][color=green]Um pacifista que evita conflitos a todo custo. Prefere a harmonia.[/color][/center]"
		Enums.PersonalityTrait.ENERGETIC:
			return "[center][color=cyan]Sempre cheio de energia e pronto para ação. Nunca para quieto![/color][/center]"
		_:
			return "[center][i]Um dragão misterioso com segredos por descobrir...[/i][/center]"

func update_personality_info():
	"""Atualiza informações de personalidade"""

	var text = "Personalidade: " + current_dragon.personality.get_personality_description()
	text += "\n\nCaracterísticas:"
	text += "\n• Território preferido: " + str(int(current_dragon.personality.territory_size)) + "m"
	text += "\n• Distância social: " + str(int(current_dragon.personality.social_distance)) + "m"
	text += "\n• Área de exploração: " + str(int(current_dragon.personality.exploration_range)) + "m"

	personality_label.text = text

func update_stats():
	"""Atualiza barras de estatística"""

	var stats = current_dragon.stats

	satiety_label.text = "SACIEDADE: " + str(int(stats.satiety)) + "/" + str(int(stats.max_satiety))
	satiety_bar.value = (stats.satiety / stats.max_satiety) * 100
	update_bar_color(satiety_bar, satiety_bar.value)

	satisfaction_label.text = "SATISFAÇÃO: " + str(int(stats.satisfaction)) + "/100"
	satisfaction_bar.value = stats.satisfaction
	update_bar_color(satisfaction_bar, satisfaction_bar.value)

	energy_label.text = "ENERGIA: " + str(int(stats.energy)) + "/" + str(int(stats.max_energy))
	energy_bar.value = (stats.energy / stats.max_energy) * 100
	update_bar_color(energy_bar, energy_bar.value)

	health_label.text = "VIDA: " + str(int(stats.health)) + "/" + str(int(stats.max_health))
	health_bar.value = (stats.health / stats.max_health) * 100
	update_bar_color(health_bar, health_bar.value)

func update_bar_color(bar: ProgressBar, percentage: float):
	"""Atualiza cor da barra baseado na porcentagem"""

	if percentage < 25:
		bar.modulate = Color.red
	elif percentage < 50:
		bar.modulate = Color.orange
	elif percentage < 75:
		bar.modulate = Color.yellow
	else:
		bar.modulate = Color.green

func update_attributes():
	"""Atualiza atributos sem causar piscar"""

	if is_updating_attributes:
		return

	is_updating_attributes = true

	for child in attributes_grid.get_children():
		child.queue_free()

	call_deferred("_add_new_attributes")

func _add_new_attributes():
	"""Adiciona novos atributos após limpeza"""

	if not current_dragon:
		is_updating_attributes = false
		return

	var stats = current_dragon.stats

	add_attribute("Velocidade:", str(int(stats.base_speed)))
	add_attribute("Força:", str(int(stats.strength)))
	add_attribute("Dano:", str(int(stats.damage)))
	add_attribute("Vida Máxima:", str(int(stats.max_health)))
	add_attribute("Velocidade Real:", str(int(stats.get_effective_speed())))
	add_attribute("Experiência:", str(int(stats.experience)) + "/" + str(int(stats.max_experience)))

	is_updating_attributes = false

func add_attribute(name: String, value: String):
	"""Adiciona um atributo ao grid"""

	var name_label = Label.new()
	name_label.text = name
	name_label.add_color_override("font_color", Color.lightgray)
	attributes_grid.add_child(name_label)

	var value_label = Label.new()
	value_label.text = value
	value_label.add_color_override("font_color", Color.white)
	attributes_grid.add_child(value_label)

func update_state():
	"""Atualiza estado atual"""

	var state_name = current_dragon.get_state_name(current_dragon.behavior.current_state)
	state_label.text = "Estado: " + state_name

	match current_dragon.behavior.current_state:
		Enums.DragonState.AGGRESSIVE:
			state_label.add_color_override("font_color", Color.red)
		Enums.DragonState.RESTING:
			state_label.add_color_override("font_color", Color.blue)
		Enums.DragonState.EATING:
			state_label.add_color_override("font_color", Color.green)
		Enums.DragonState.SEEKING_FOOD:
			state_label.add_color_override("font_color", Color.orange)
		_:
			state_label.add_color_override("font_color", Color.white)

func get_dragon_type_color(dragon_type: int) -> Color:
	"""Retorna cor baseada no tipo do dragão"""

	match dragon_type:
		Enums.DragonType.FIRE:
			return Color.red
		Enums.DragonType.ICE:
			return Color.cyan
		Enums.DragonType.EARTH:
			return Color.brown
		Enums.DragonType.WIND:
			return Color.lightgreen
		Enums.DragonType.CRYSTAL:
			return Color.magenta
		Enums.DragonType.SHADOW:
			return Color.gray
		_:
			return Color.white

func _on_close_pressed():
	"""Botão fechar pressionado"""

	emit_signal("close_requested")

func _on_dragon_stats_updated(dragon: Dragon):
	"""Stats atualizados"""

	if dragon == current_dragon and visible:
		update_stats()
		update_decoration_info()  # NOVO: Atualiza decorações também
		if not is_updating_attributes:
			call_deferred("update_attributes")

func _on_dragon_state_changed(new_state: int):
	"""Estado mudou"""

	if visible:
		update_state()















## DragonInfoUI.gd - Interface corrigida sem piscar + scroll completo
#class_name DragonInfoUI
#extends Control
#
#var Enums = preload("res://scripts/utils/Enums.gd")
#
## Componentes principais
#var main_panel: Panel
#var scroll_container: ScrollContainer
#var content_vbox: VBoxContainer
#
## Seções
#var header_section: VBoxContainer
#var stats_section: VBoxContainer
#var personality_section: VBoxContainer
#var attributes_section: VBoxContainer
#var state_section: VBoxContainer
#
## Labels principais
#var dragon_name_label: Label
#var level_label: Label
#var description_label: RichTextLabel
#var personality_label: Label
#var state_label: Label
#
## Barras de status
#var satiety_bar: ProgressBar
#var satisfaction_bar: ProgressBar
#var energy_bar: ProgressBar
#var health_bar: ProgressBar
#
## Labels das barras
#var satiety_label: Label
#var satisfaction_label: Label
#var energy_label: Label
#var health_label: Label
#
## Atributos
#var attributes_grid: GridContainer
#
## Botão fechar
#var close_button: Button
#
#var current_dragon: Dragon = null
#var is_positioned = false
#var is_updating_attributes = false
#
#signal close_requested
#
#func _ready():
#	create_interface()
#	set_initial_position()
#	visible = false
#
#func create_interface():
#	"""Cria toda a interface programaticamente"""
#
#	# Painel principal
#	main_panel = Panel.new()
#	main_panel.rect_size = Vector2(350, 500)
#	add_child(main_panel)
#
#	# Container de scroll - MELHORIA: configuração aprimorada
#	scroll_container = ScrollContainer.new()
#	scroll_container.rect_position = Vector2(10, 10)
#	scroll_container.rect_size = Vector2(330, 480)
#	scroll_container.scroll_horizontal_enabled = false  # ADICIONADO: só scroll vertical
#	main_panel.add_child(scroll_container)
#
#	# Container principal vertical - MELHORIA: tamanho flexível
#	content_vbox = VBoxContainer.new()
#	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # CORRIGIDO
#	content_vbox.add_constant_override("separation", 5)  # ADICIONADO: espaçamento consistente
#	scroll_container.add_child(content_vbox)
#
#	# Cria seções
#	create_header_section()
#	create_stats_section()
#	create_personality_section()
#	create_attributes_section()
#	create_state_section()
#	create_close_button()
#
#	# ADICIONADO: Ajusta tamanho do scroll após criar tudo
#	call_deferred("adjust_scroll_container")
#
#func adjust_scroll_container():
#	"""ADICIONADO: Ajusta o container de scroll para funcionar corretamente"""
#
#	# Força recálculo do tamanho do conteúdo
#	content_vbox.rect_size = content_vbox.get_combined_minimum_size()
#
#	# Adiciona margem extra para scroll completo + espaço para o botão
#	var total_height = content_vbox.rect_size.y + 60
#	content_vbox.rect_min_size.y = total_height
#
#func set_initial_position():
#	"""Define posição inicial sem yield"""
#
#	# Dimensões do painel
#	var panel_width = 350
#	var panel_height = 500
#	var margin_right = 20
#	var margin_top = 20
#
#	# Posição fixa no canto superior esquerdo (evita cálculos complexos)
#	var global_x = margin_right
#	var global_y = margin_top
#
#	# Define posição e tamanho
#	rect_position = Vector2(global_x, global_y)
#	rect_size = Vector2(panel_width, panel_height)
#
#	is_positioned = true
#
#func position_interface():
#	"""Reposiciona interface quando necessário"""
#
#	if not is_positioned:
#		set_initial_position()
#		return
#
#	# Só reposiciona se realmente necessário
#	var viewport_size = get_viewport().size
#	var panel_width = 350
#	var panel_height = 500
#	var margin_right = 20
#	var margin_top = 20
#
#	var desired_x = margin_right
#	var desired_y = margin_top
#
#	# Só atualiza se a posição mudou significativamente
#	if abs(rect_position.x - desired_x) > 5 or abs(rect_position.y - desired_y) > 5:
#		rect_position = Vector2(desired_x, desired_y)
#
#func _on_viewport_size_changed():
#	"""Reposiciona quando a tela muda de tamanho"""
#
#	if visible and is_positioned:
#		call_deferred("position_interface")
#
#func create_header_section():
#	"""Cria seção do cabeçalho"""
#
#	header_section = VBoxContainer.new()
#	header_section.name = "HeaderSection"
#	content_vbox.add_child(header_section)
#
#	# Título
#	var title_label = Label.new()
#	title_label.text = "INFORMAÇÕES DO DRAGÃO"
#	title_label.align = Label.ALIGN_CENTER
#	title_label.add_color_override("font_color", Color.cyan)
#	header_section.add_child(title_label)
#
#	# Separador
#	var separator1 = HSeparator.new()
#	header_section.add_child(separator1)
#
#	# Nome do dragão
#	dragon_name_label = Label.new()
#	dragon_name_label.text = "Nome do Dragão"
#	dragon_name_label.align = Label.ALIGN_CENTER
#	dragon_name_label.add_color_override("font_color", Color.white)
#	header_section.add_child(dragon_name_label)
#
#	# Nível
#	level_label = Label.new()
#	level_label.text = "Nível: 1"
#	level_label.align = Label.ALIGN_CENTER
#	level_label.add_color_override("font_color", Color.yellow)
#	header_section.add_child(level_label)
#
#	# Descrição
#	description_label = RichTextLabel.new()
#	description_label.rect_min_size.y = 80
#	description_label.bbcode_enabled = true
#	description_label.bbcode_text = "[center][i]Descrição do dragão aparecerá aqui...[/i][/center]"
#	header_section.add_child(description_label)
#
#	# Separador
#	var separator2 = HSeparator.new()
#	header_section.add_child(separator2)
#
#func create_stats_section():
#	"""Cria seção de estatísticas"""
#
#	stats_section = VBoxContainer.new()
#	stats_section.name = "StatsSection"
#	content_vbox.add_child(stats_section)
#
#	# Título da seção
#	var stats_title = Label.new()
#	stats_title.text = "ESTATÍSTICAS"
#	stats_title.align = Label.ALIGN_CENTER
#	stats_title.add_color_override("font_color", Color.lightgreen)
#	stats_section.add_child(stats_title)
#
#	# Saciedade
#	create_stat_bar(stats_section, "SACIEDADE", "satiety")
#
#	# Satisfação
#	create_stat_bar(stats_section, "SATISFAÇÃO", "satisfaction")
#
#	# Energia
#	create_stat_bar(stats_section, "ENERGIA", "energy")
#
#	# Vida
#	create_stat_bar(stats_section, "VIDA", "health")
#
#	# Separador
#	var separator = HSeparator.new()
#	stats_section.add_child(separator)
#
#func create_stat_bar(parent: VBoxContainer, title: String, type: String):
#	"""Cria uma barra de estatística"""
#
#	var container = VBoxContainer.new()
#	container.add_constant_override("separation", 3)  # ADICIONADO: espaçamento
#	parent.add_child(container)
#
#	# Label da stat
#	var label = Label.new()
#	label.text = title + ": 0/100"
#	container.add_child(label)
#
#	# Barra de progresso
#	var progress_bar = ProgressBar.new()
#	progress_bar.min_value = 0
#	progress_bar.max_value = 100
#	progress_bar.value = 50
#	progress_bar.rect_min_size.y = 20
#	container.add_child(progress_bar)
#
#	# Espaço entre barras - ADICIONADO
#	var spacer = Control.new()
#	spacer.rect_min_size.y = 3
#	container.add_child(spacer)
#
#	# Armazena referências
#	match type:
#		"satiety":
#			satiety_label = label
#			satiety_bar = progress_bar
#		"satisfaction":
#			satisfaction_label = label
#			satisfaction_bar = progress_bar
#		"energy":
#			energy_label = label
#			energy_bar = progress_bar
#		"health":
#			health_label = label
#			health_bar = progress_bar
#
#func create_personality_section():
#	"""Cria seção de personalidade"""
#
#	personality_section = VBoxContainer.new()
#	personality_section.name = "PersonalitySection"
#	content_vbox.add_child(personality_section)
#
#	# Título
#	var personality_title = Label.new()
#	personality_title.text = "PERSONALIDADE"
#	personality_title.align = Label.ALIGN_CENTER
#	personality_title.add_color_override("font_color", Color.pink)
#	personality_section.add_child(personality_title)
#
#	# Texto da personalidade - CORRIGIDO: largura para autowrap
#	personality_label = Label.new()
#	personality_label.text = "Personalidade será mostrada aqui..."
#	personality_label.autowrap = true
#	personality_label.rect_min_size.x = 300  # ADICIONADO: força largura
#	personality_section.add_child(personality_label)
#
#	# Separador
#	var separator = HSeparator.new()
#	personality_section.add_child(separator)
#
#func create_attributes_section():
#	"""Cria seção de atributos"""
#
#	attributes_section = VBoxContainer.new()
#	attributes_section.name = "AttributesSection"
#	content_vbox.add_child(attributes_section)
#
#	# Título
#	var attributes_title = Label.new()
#	attributes_title.text = "ATRIBUTOS"
#	attributes_title.align = Label.ALIGN_CENTER
#	attributes_title.add_color_override("font_color", Color.orange)
#	attributes_section.add_child(attributes_title)
#
#	# Grid de atributos - MELHORADO: espaçamento
#	attributes_grid = GridContainer.new()
#	attributes_grid.columns = 2
#	attributes_grid.add_constant_override("hseparation", 10)  # ADICIONADO
#	attributes_grid.add_constant_override("vseparation", 3)   # ADICIONADO
#	attributes_section.add_child(attributes_grid)
#
#	# Separador
#	var separator = HSeparator.new()
#	attributes_section.add_child(separator)
#
#func create_state_section():
#	"""Cria seção de estado"""
#
#	state_section = VBoxContainer.new()
#	state_section.name = "StateSection"
#	content_vbox.add_child(state_section)
#
#	# Título
#	var state_title = Label.new()
#	state_title.text = "ESTADO ATUAL"
#	state_title.align = Label.ALIGN_CENTER
#	state_title.add_color_override("font_color", Color.violet)
#	state_section.add_child(state_title)
#
#	# Estado atual
#	state_label = Label.new()
#	state_label.text = "Estado: Desconhecido"
#	state_label.align = Label.ALIGN_CENTER
#	state_label.add_color_override("font_color", Color.white)
#	state_section.add_child(state_label)
#
#func create_close_button():
#	"""Cria botão de fechar"""
#
#	close_button = Button.new()
#	close_button.text = "FECHAR"
#	close_button.rect_min_size.y = 30
#	close_button.connect("pressed", self, "_on_close_pressed")
#	content_vbox.add_child(close_button)
#
#	# ADICIONADO: Espaço final para scroll completo
#	var final_spacer = Control.new()
#	final_spacer.rect_min_size.y = 20
#	content_vbox.add_child(final_spacer)
#
#func show_dragon_info(dragon: Dragon):
#	"""Mostra informações do dragão"""
#
#	if not dragon or not is_instance_valid(dragon):
#		return
#
#	current_dragon = dragon
#
#	# Conecta sinais se não estiverem conectados
#	if not dragon.is_connected("stats_updated", self, "_on_dragon_stats_updated"):
#		dragon.connect("stats_updated", self, "_on_dragon_stats_updated")
#
#	if not dragon.behavior.is_connected("state_changed", self, "_on_dragon_state_changed"):
#		dragon.behavior.connect("state_changed", self, "_on_dragon_state_changed")
#
#	# Atualiza informações
#	update_all_info()
#
#	# Garante posicionamento
#	if not is_positioned:
#		set_initial_position()
#
#	# Mostra interface
#	visible = true
#
#	# Conecta para detectar mudanças no tamanho da tela
#	if not get_viewport().is_connected("size_changed", self, "_on_viewport_size_changed"):
#		get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
#
#func hide_dragon_info():
#	"""Esconde interface"""
#
#	visible = false
#
#	# Desconecta sinal da viewport
#	if get_viewport().is_connected("size_changed", self, "_on_viewport_size_changed"):
#		get_viewport().disconnect("size_changed", self, "_on_viewport_size_changed")
#
#	# Desconecta sinais
#	if current_dragon and is_instance_valid(current_dragon):
#		if current_dragon.is_connected("stats_updated", self, "_on_dragon_stats_updated"):
#			current_dragon.disconnect("stats_updated", self, "_on_dragon_stats_updated")
#
#		if current_dragon.behavior.is_connected("state_changed", self, "_on_dragon_state_changed"):
#			current_dragon.behavior.disconnect("state_changed", self, "_on_dragon_state_changed")
#
#	current_dragon = null
#
#func update_all_info():
#	"""Atualiza todas as informações"""
#
#	if not current_dragon:
#		return
#
#	# Header
#	dragon_name_label.text = current_dragon.stats.dragon_name
#	level_label.text = "Nível: " + str(current_dragon.stats.level)
#
#	# Cor baseada no tipo
#	var type_color = get_dragon_type_color(current_dragon.stats.dragon_type)
#	dragon_name_label.add_color_override("font_color", type_color)
#
#	# Descrição
#	description_label.bbcode_text = generate_description()
#
#	# Personalidade
#	update_personality_info()
#
#	# Stats
#	update_stats()
#
#	# Atributos
#	call_deferred("update_attributes")
#
#	# Estado
#	update_state()
#
#	# ADICIONADO: Ajusta scroll após atualizar
#	call_deferred("adjust_scroll_container")
#
#func generate_description() -> String:
#	"""Gera descrição do dragão"""
#
#	var personality = current_dragon.personality
#
#	match personality.primary_trait:
#		Enums.PersonalityTrait.CURIOUS:
#			return "[center][color=lightblue]Este dragão adora explorar cada cantinho do mundo. Sempre em busca de novas aventuras![/color][/center]"
#		Enums.PersonalityTrait.AGGRESSIVE:
#			return "[center][color=red]Um dragão feroz que não hesita em mostrar suas garras. Cuidado ao se aproximar![/color][/center]"
#		Enums.PersonalityTrait.LAZY:
#			return "[center][color=brown]Prefere passar o dia descansando sob o sol. A preguiça é sua especialidade.[/color][/center]"
#		Enums.PersonalityTrait.SOLITARY:
#			return "[center][color=gray]Um solitário que valoriza sua privacidade. Gosta de ficar sozinho.[/color][/center]"
#		Enums.PersonalityTrait.SOCIAL:
#			return "[center][color=yellow]Adora a companhia de outros dragões. Muito sociável e amigável![/color][/center]"
#		Enums.PersonalityTrait.TERRITORIAL:
#			return "[center][color=orange]Guarda zelosamente seu território pessoal. Não gosta de invasores.[/color][/center]"
#		Enums.PersonalityTrait.PEACEFUL:
#			return "[center][color=green]Um pacifista que evita conflitos a todo custo. Prefere a harmonia.[/color][/center]"
#		Enums.PersonalityTrait.ENERGETIC:
#			return "[center][color=cyan]Sempre cheio de energia e pronto para ação. Nunca para quieto![/color][/center]"
#		_:
#			return "[center][i]Um dragão misterioso com segredos por descobrir...[/i][/center]"
#
#func update_personality_info():
#	"""Atualiza informações de personalidade"""
#
#	var text = "Personalidade: " + current_dragon.personality.get_personality_description()
#	text += "\n\nCaracterísticas:"
#	text += "\n• Território preferido: " + str(int(current_dragon.personality.territory_size)) + "m"
#	text += "\n• Distância social: " + str(int(current_dragon.personality.social_distance)) + "m"
#	text += "\n• Área de exploração: " + str(int(current_dragon.personality.exploration_range)) + "m"
#
#	personality_label.text = text
#
#func update_stats():
#	"""Atualiza barras de estatística"""
#
#	var stats = current_dragon.stats
#
#	# Saciedade
#	satiety_label.text = "SACIEDADE: " + str(int(stats.satiety)) + "/" + str(int(stats.max_satiety))
#	satiety_bar.value = (stats.satiety / stats.max_satiety) * 100
#	update_bar_color(satiety_bar, satiety_bar.value)
#
#	# Satisfação
#	satisfaction_label.text = "SATISFAÇÃO: " + str(int(stats.satisfaction)) + "/100"
#	satisfaction_bar.value = stats.satisfaction
#	update_bar_color(satisfaction_bar, satisfaction_bar.value)
#
#	# Energia
#	energy_label.text = "ENERGIA: " + str(int(stats.energy)) + "/" + str(int(stats.max_energy))
#	energy_bar.value = (stats.energy / stats.max_energy) * 100
#	update_bar_color(energy_bar, energy_bar.value)
#
#	# Vida
#	health_label.text = "VIDA: " + str(int(stats.health)) + "/" + str(int(stats.max_health))
#	health_bar.value = (stats.health / stats.max_health) * 100
#	update_bar_color(health_bar, health_bar.value)
#
#func update_bar_color(bar: ProgressBar, percentage: float):
#	"""Atualiza cor da barra baseado na porcentagem"""
#
#	if percentage < 25:
#		bar.modulate = Color.red
#	elif percentage < 50:
#		bar.modulate = Color.orange
#	elif percentage < 75:
#		bar.modulate = Color.yellow
#	else:
#		bar.modulate = Color.green
#
#func update_attributes():
#	"""Atualiza atributos sem causar piscar"""
#
#	if is_updating_attributes:
#		return
#
#	is_updating_attributes = true
#
#	# Limpa atributos anteriores
#	for child in attributes_grid.get_children():
#		child.queue_free()
#
#	# Aguarda um frame para garantir limpeza
#	call_deferred("_add_new_attributes")
#
#func _add_new_attributes():
#	"""Adiciona novos atributos após limpeza"""
#
#	if not current_dragon:
#		is_updating_attributes = false
#		return
#
#	var stats = current_dragon.stats
#
#	# Adiciona atributos
#	add_attribute("Velocidade:", str(int(stats.base_speed)))
#	add_attribute("Força:", str(int(stats.strength)))
#	add_attribute("Dano:", str(int(stats.damage)))
#	add_attribute("Vida Máxima:", str(int(stats.max_health)))
#	add_attribute("Velocidade Real:", str(int(stats.get_effective_speed())))
#	add_attribute("Experiência:", str(int(stats.experience)) + "/" + str(int(stats.max_experience)))
#
#	is_updating_attributes = false
#
#func add_attribute(name: String, value: String):
#	"""Adiciona um atributo ao grid"""
#
#	var name_label = Label.new()
#	name_label.text = name
#	name_label.add_color_override("font_color", Color.lightgray)
#	attributes_grid.add_child(name_label)
#
#	var value_label = Label.new()
#	value_label.text = value
#	value_label.add_color_override("font_color", Color.white)
#	attributes_grid.add_child(value_label)
#
#func update_state():
#	"""Atualiza estado atual"""
#
#	var state_name = current_dragon.get_state_name(current_dragon.behavior.current_state)
#	state_label.text = "Estado: " + state_name
#
#	# Cor baseada no estado
#	match current_dragon.behavior.current_state:
#		Enums.DragonState.AGGRESSIVE:
#			state_label.add_color_override("font_color", Color.red)
#		Enums.DragonState.RESTING:
#			state_label.add_color_override("font_color", Color.blue)
#		Enums.DragonState.EATING:
#			state_label.add_color_override("font_color", Color.green)
#		Enums.DragonState.SEEKING_FOOD:
#			state_label.add_color_override("font_color", Color.orange)
#		_:
#			state_label.add_color_override("font_color", Color.white)
#
#func get_dragon_type_color(dragon_type: int) -> Color:
#	"""Retorna cor baseada no tipo do dragão"""
#
#	match dragon_type:
#		Enums.DragonType.FIRE:
#			return Color.red
#		Enums.DragonType.ICE:
#			return Color.cyan
#		Enums.DragonType.EARTH:
#			return Color.brown
#		Enums.DragonType.WIND:
#			return Color.lightgreen
#		Enums.DragonType.CRYSTAL:
#			return Color.magenta
#		Enums.DragonType.SHADOW:
#			return Color.gray
#		_:
#			return Color.white
#
#func _on_close_pressed():
#	"""Botão fechar pressionado"""
#
#	emit_signal("close_requested")
#
#func _on_dragon_stats_updated(dragon: Dragon):
#	"""Stats atualizados"""
#
#	if dragon == current_dragon and visible:
#		update_stats()
#		if not is_updating_attributes:  # MELHORIA: evita conflito
#			call_deferred("update_attributes")
#
#func _on_dragon_state_changed(new_state: int):
#	"""Estado mudou"""
#
#	if visible:
#		update_state()
