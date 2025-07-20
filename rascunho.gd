extends Node

# Script para gerar a estrutura completa da cena DragonManager
# Execute este script no Godot 3.6 para criar a hierarquia de nós

func _ready():
	create_dragon_manager_scene()

func create_dragon_manager_scene():
	# Criar o nó raiz
	var dragon_manager = Node2D.new()
	dragon_manager.name = "DragonManager"
	
	# Criar UILayer
	var ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	dragon_manager.add_child(ui_layer)
	
	# Criar DragonInfoUI
	var dragon_info_ui = Control.new()
	dragon_info_ui.name = "DragonInfoUI"
	dragon_info_ui.set_script(load("res://scripts/ui/DragonInfoUI.gd"))
	ui_layer.add_child(dragon_info_ui)
	
	# Criar MainPanel
	var main_panel = Panel.new()
	main_panel.name = "MainPanel"
	dragon_info_ui.add_child(main_panel)
	
	# Criar VBox principal
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	main_panel.add_child(vbox)
	
	# Criar Header
	create_header(vbox)
	
	# Criar DescriptionPanel
	create_description_panel(vbox)
	
	# Criar PersonalityPanel
	create_personality_panel(vbox)
	
	# Criar StatsContainer
	create_stats_container(vbox)
	
	# Criar AttributesPanel
	create_attributes_panel(vbox)
	
	# Criar StatePanel
	create_state_panel(vbox)
	
	# Criar BehaviorPanel
	create_behavior_panel(vbox)
	
	# Adicionar a cena à árvore atual
	get_tree().current_scene.add_child(dragon_manager)
	
	print("Estrutura DragonManager criada com sucesso!")

func create_header(parent):
	var header = Control.new()
	header.name = "Header"
	parent.add_child(header)
	
	var hbox = HBoxContainer.new()
	hbox.name = "HBox"
	header.add_child(hbox)
	
	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = "Dragon Name"
	hbox.add_child(name_label)
	
	var level_label = Label.new()
	level_label.name = "LevelLabel"
	level_label.text = "Level 1"
	hbox.add_child(level_label)
	
	var close_button = Button.new()
	close_button.name = "CloseButton"
	close_button.text = "X"
	hbox.add_child(close_button)

func create_description_panel(parent):
	var description_panel = Panel.new()
	description_panel.name = "DescriptionPanel"
	parent.add_child(description_panel)
	
	var description_label = RichTextLabel.new()
	description_label.name = "DescriptionLabel"
	description_label.bbcode_enabled = true
	description_label.bbcode_text = "[color=gray]Dragon description goes here...[/color]"
	description_panel.add_child(description_label)

func create_personality_panel(parent):
	var personality_panel = Panel.new()
	personality_panel.name = "PersonalityPanel"
	parent.add_child(personality_panel)
	
	var personality_label = Label.new()
	personality_label.name = "PersonalityLabel"
	personality_label.text = "Personality: Calm"
	personality_panel.add_child(personality_label)

func create_stats_container(parent):
	var stats_container = VBoxContainer.new()
	stats_container.name = "StatsContainer"
	parent.add_child(stats_container)
	
	# Criar barras de stats
	create_stat_bar(stats_container, "SatietyBar", "Saciedade", 75)
	create_stat_bar(stats_container, "SatisfactionBar", "Satisfação", 80)
	create_stat_bar(stats_container, "EnergyBar", "Energia", 60)
	create_stat_bar(stats_container, "HealthBar", "Saúde", 100)

func create_stat_bar(parent, bar_name, label_text, value):
	var stat_bar = Control.new()
	stat_bar.name = bar_name
	parent.add_child(stat_bar)
	
	var label = Label.new()
	label.name = "Label"
	label.text = label_text + ":"
	stat_bar.add_child(label)
	
	var progress_bar = ProgressBar.new()
	progress_bar.name = "ProgressBar"
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.value = value
	stat_bar.add_child(progress_bar)
	
	var value_label = Label.new()
	value_label.name = "ValueLabel"
	value_label.text = str(value) + "/100"
	stat_bar.add_child(value_label)

func create_attributes_panel(parent):
	var attributes_panel = Panel.new()
	attributes_panel.name = "AttributesPanel"
	parent.add_child(attributes_panel)
	
	var attributes_grid = GridContainer.new()
	attributes_grid.name = "AttributesGrid"
	attributes_grid.columns = 2
	attributes_panel.add_child(attributes_grid)
	
	# Adicionar alguns atributos de exemplo
	var attributes = [
		["Força", "15"],
		["Agilidade", "12"],
		["Inteligência", "18"],
		["Resistência", "14"]
	]
	
	for attr in attributes:
		var attr_label = Label.new()
		attr_label.text = attr[0] + ":"
		attributes_grid.add_child(attr_label)
		
		var attr_value = Label.new()
		attr_value.text = attr[1]
		attributes_grid.add_child(attr_value)

func create_state_panel(parent):
	var state_panel = Panel.new()
	state_panel.name = "StatePanel"
	parent.add_child(state_panel)
	
	var state_label = Label.new()
	state_label.name = "StateLabel"
	state_label.text = "Estado: Descansando"
	state_panel.add_child(state_label)
	
	var state_icon = TextureRect.new()
	state_icon.name = "StateIcon"
	state_panel.add_child(state_icon)

func create_behavior_panel(parent):
	var behavior_panel = Panel.new()
	behavior_panel.name = "BehaviorPanel"
	parent.add_child(behavior_panel)
	
	var behavior_log = RichTextLabel.new()
	behavior_log.name = "BehaviorLog"
	behavior_log.bbcode_enabled = true
	behavior_log.bbcode_text = "[color=lightblue]Log de Comportamento:[/color]\n• Dragon acordou\n• Dragon está explorando\n• Dragon encontrou comida"
	behavior_panel.add_child(behavior_log)
