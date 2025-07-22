# FoodInventoryUI.gd - Interface do inventário de alimentos
class_name FoodInventoryUI
extends Control

# Componentes da UI
var main_panel: Panel
var header_section: VBoxContainer
var tabs_container: TabContainer
var footer_section: VBoxContainer
var close_button: Button

# Labels informativos
var title_label: Label
var info_label: Label
var selected_food_label: Label

# Dados do inventário
var inventory_data: Dictionary = {}
var selected_food: Dictionary = {}

# Configurações visuais
var food_icons: Dictionary = {
	"fish": "🐟fish",
	"meat": "meat🥩", 
	"vegetable": "🥬vegetable",
	"mineral": "💎mineral",
	"magical": "✨magical",
	"insect": "insect🦗",
	"fruit": "fruit🍎",      # NOVO
	"dairy": "dairy🥛",      # NOVO
	"honey": "🍯honey"       # NOVO
}

var food_colors: Dictionary = {
	"fish": Color.blue,
	"meat": Color.red,
	"vegetable": Color.green,
	"mineral": Color.purple,
	"magical": Color.gold,
	"insect": Color.orange,
	"fruit": Color(1.0, 0.5, 0.0),    # NOVO - Laranja
	"dairy": Color(0.9, 0.9, 0.7),    # NOVO - Bege
	"honey": Color(1.0, 0.8, 0.0)     # NOVO - Dourado
}

var food_names: Dictionary = {
	"fish": "Peixes",
	"meat": "Carnes",
	"vegetable": "Vegetais", 
	"mineral": "Minérios",
	"magical": "Alimentos Mágicos",
	"insect": "Insetos",
	"fruit": "Frutas",        # NOVO
	"dairy": "Laticínios",    # NOVO
	"honey": "Mel"            # NOVO
}

# Sinais
signal food_used(food_type, level, amount)
signal inventory_closed

func _ready():
	"""Inicialização da UI"""
	
	create_ui()
	visible = false

func create_ui():
	"""Cria interface do inventário"""
	
	# Posicionamento central
	position_ui_center()
	
	# Painel principal
	main_panel = Panel.new()
	main_panel.set_anchors_and_margins_preset(Control.PRESET_WIDE)
	main_panel.modulate = Color(1, 1, 1, 0.95)
	add_child(main_panel)
	
	create_header_section()
	create_tabs_section()
	create_footer_section()

func position_ui_center():
	"""Posiciona UI no centro da tela"""
	
	var viewport_size = get_viewport().size
	var panel_width = 500
	var panel_height = 400
	
	var pos_x = (viewport_size.x - panel_width) / 2
	var pos_y = (viewport_size.y - panel_height) / 2
	
	set_anchors_and_margins_preset(Control.PRESET_TOP_LEFT)
	rect_position = Vector2(pos_x, pos_y)
	rect_size = Vector2(panel_width, panel_height)

func create_header_section():
	"""Cria seção do cabeçalho"""
	
	header_section = VBoxContainer.new()
	header_section.rect_position = Vector2(10, 10)
	header_section.rect_size = Vector2(480, 60)
	header_section.add_constant_override("separation", 5)
	main_panel.add_child(header_section)
	
	# Título
	title_label = Label.new()
	title_label.text = "🍖 INVENTÁRIO DE ALIMENTOS"
	title_label.align = Label.ALIGN_CENTER
	title_label.add_color_override("font_color", Color.gold)
	header_section.add_child(title_label)
	
	# Informações
	info_label = Label.new()
	info_label.text = "Clique nos alimentos para usar em dragões"
	info_label.align = Label.ALIGN_CENTER
	info_label.add_color_override("font_color", Color.lightgray)
	header_section.add_child(info_label)
	
	# Alimento selecionado
	selected_food_label = Label.new()
	selected_food_label.text = ""
	selected_food_label.align = Label.ALIGN_CENTER
	selected_food_label.add_color_override("font_color", Color.yellow)
	header_section.add_child(selected_food_label)

func create_tabs_section():
	"""Cria seção de abas por tipo de alimento"""
	
	tabs_container = TabContainer.new()
	tabs_container.rect_position = Vector2(10, 80)
	tabs_container.rect_size = Vector2(480, 270)
	main_panel.add_child(tabs_container)

func create_footer_section():
	"""Cria seção do rodapé"""
	
	footer_section = VBoxContainer.new()
	footer_section.rect_position = Vector2(10, 360)
	footer_section.rect_size = Vector2(480, 30)
	main_panel.add_child(footer_section)
	
	# Botão fechar
	close_button = Button.new()
	close_button.text = "FECHAR INVENTÁRIO (I)"
	close_button.rect_size = Vector2(480, 30)
	close_button.connect("pressed", self, "_on_close_pressed")
	footer_section.add_child(close_button)

func show_ui(inventory_dict: Dictionary):
	"""Mostra a UI com dados do inventário"""
	
	inventory_data = inventory_dict
	visible = true
	position_ui_center()
	
	populate_food_tabs()

func populate_food_tabs():
	"""Popula abas com tipos de alimento"""
	
	# Limpa abas existentes
	for child in tabs_container.get_children():
		child.queue_free()
	
	# Cria aba para cada tipo de alimento
	for food_type in inventory_data:
		create_food_tab(food_type, inventory_data[food_type])

func create_food_tab(food_type: String, food_levels: Dictionary):
	"""Cria aba para um tipo de alimento"""
	
	# Container da aba
	var tab_container = VBoxContainer.new()
	tab_container.name = food_names.get(food_type, food_type.capitalize())
	tabs_container.add_child(tab_container)
	
	# Cabeçalho da aba
	var tab_header = HBoxContainer.new()
	tab_container.add_child(tab_header)
	
	var icon_label = Label.new()
	icon_label.text = food_icons.get(food_type, "🍽️")
	icon_label.rect_min_size.x = 30
	tab_header.add_child(icon_label)
	
	var total_amount = 0
	for level in food_levels:
		total_amount += food_levels[level]
	
	var total_label = Label.new()
	total_label.text = "Total: " + str(total_amount) + " unidades"
	total_label.add_color_override("font_color", food_colors.get(food_type, Color.white))
	tab_header.add_child(total_label)
	
	# Scroll para níveis
	var scroll = ScrollContainer.new()
	scroll.rect_min_size.y = 200
	scroll.scroll_horizontal_enabled = false
	tab_container.add_child(scroll)
	
	# Container para níveis
	var levels_container = VBoxContainer.new()
	levels_container.add_constant_override("separation", 10)
	scroll.add_child(levels_container)
	
	# Cria item para cada nível
	for level_key in food_levels:
		var level = int(level_key.split("_")[1])  # "level_1" -> 1
		var amount = food_levels[level_key]
		create_food_level_item(levels_container, food_type, level, amount)

func create_food_level_item(parent: VBoxContainer, food_type: String, level: int, amount: int):
	"""Cria item para um nível específico de alimento"""
	
	# Container principal do item
	var item_container = Panel.new()
	item_container.rect_min_size.y = 80
	item_container.modulate = Color(0.2, 0.2, 0.2, 0.8)
	parent.add_child(item_container)
	
	# Container horizontal interno
	var hbox = HBoxContainer.new()
	hbox.rect_position = Vector2(10, 10)
	hbox.rect_size = Vector2(440, 60)
	hbox.add_constant_override("separation", 15)
	item_container.add_child(hbox)
	
	# Ícone e nível
	var icon_section = VBoxContainer.new()
	icon_section.rect_min_size.x = 80
	hbox.add_child(icon_section)
	
	var icon_label = Label.new()
	icon_label.text = food_icons.get(food_type, "🍽️")
	icon_label.align = Label.ALIGN_CENTER
	icon_label.rect_min_size.y = 30
	icon_section.add_child(icon_label)
	
	var level_label = Label.new()
	level_label.text = "Nível " + str(level)
	level_label.align = Label.ALIGN_CENTER
	level_label.add_color_override("font_color", get_level_color(level))
	icon_section.add_child(level_label)
	
	# Informações
	var info_section = VBoxContainer.new()
	info_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_section)
	
	var amount_label = Label.new()
	amount_label.text = "Quantidade: " + str(amount)
	amount_label.add_color_override("font_color", Color.white)
	info_section.add_child(amount_label)
	
	var effects_label = Label.new()
	effects_label.text = get_food_effects_text(food_type, level)
	effects_label.add_color_override("font_color", Color.lightblue)
	effects_label.autowrap = true
	info_section.add_child(effects_label)
	
	# Botões de ação
	var buttons_section = VBoxContainer.new()
	buttons_section.rect_min_size.x = 100
	hbox.add_child(buttons_section)
	
	var use_button = Button.new()
	use_button.text = "Usar 1x"
	use_button.rect_min_size.y = 25
	use_button.disabled = amount <= 0
	use_button.connect("pressed", self, "_on_use_food", [food_type, level, 1])
	buttons_section.add_child(use_button)
	
	var use_multiple_button = Button.new()
	use_multiple_button.text = "Usar 5x"
	use_multiple_button.rect_min_size.y = 25
	use_multiple_button.disabled = amount < 5
	use_multiple_button.connect("pressed", self, "_on_use_food", [food_type, level, 5])
	buttons_section.add_child(use_multiple_button)

func get_level_color(level: int) -> Color:
	"""Retorna cor baseada no nível"""
	
	match level:
		1:
			return Color.white
		2:
			return Color.lightblue
		3:
			return Color.gold
		_:
			return Color.gray

func get_food_effects_text(food_type: String, level: int) -> String:
	"""Retorna texto dos efeitos do alimento"""
	
	var base_effects = {
		"fish": "Vida +{health}, Força +{strength}, Agressão +{aggression}",
		"meat": "Vida +{health}, Força +{strength}, Energia +{energy}",
		"vegetable": "Vida +{health}, Satisfação +{satisfaction}, Calma +{calm}",
		"mineral": "Vida +{health}, Energia +{energy}, Velocidade +{speed}",
		"magical": "Vida +{health}, Energia +{energy}, Todos +{all}",
		"insect": "Vida +{health}, Velocidade +{speed}, Energia +{energy}",
		"fruit": "Vida +{health}, Satisfação +{satisfaction}, Energia +{energy}",
		"dairy": "Vida +{health}, Defesa +{defense}, Força +{strength}",
		"honey": "Vida +{health}, Cura Veneno, Regeneração +{regen}"
	}
	
	var template = base_effects.get(food_type, "Efeitos desconhecidos")
	var multiplier = 1.0 + (level - 1) * 0.5
	
	# Substitui valores baseados no nível
	template = template.replace("{health}", str(int(20 * multiplier)))
	template = template.replace("{strength}", str(int(15 * multiplier)))
	template = template.replace("{aggression}", str(int(20 * multiplier)))
	template = template.replace("{energy}", str(int(30 * multiplier)))
	template = template.replace("{satisfaction}", str(int(25 * multiplier)))
	template = template.replace("{calm}", str(int(30 * multiplier)))
	template = template.replace("{speed}", str(int(25 * multiplier)))
	template = template.replace("{all}", str(int(20 * multiplier)))
	
	return template

func _on_use_food(food_type: String, level: int, amount: int):
	"""Usar alimento"""
	
	emit_signal("food_used", food_type, level, amount)
	
	# Atualiza UI
	call_deferred("refresh_ui")

func refresh_ui():
	"""Atualiza a UI"""
	
	if visible:
		populate_food_tabs()

func _on_close_pressed():
	"""Fechar inventário"""
	
	emit_signal("inventory_closed")
	hide_ui()

func hide_ui():
	"""Esconde a UI"""
	
	visible = false
