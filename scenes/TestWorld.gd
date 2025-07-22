# TestWorld.gd
extends Node2D

onready var dragon_manager: DragonManager = $DragonManager
onready var camera: Camera2D = $Camera2D

func _ready():
	# Configura câmera
	camera.current = true
	var Enums = preload("res://scripts/utils/Enums.gd")
	print(Enums.DragonType.FIRE)

	# Conecta sinais do gerenciador
	dragon_manager.connect("dragon_spawned", self, "_on_dragon_spawned")
	dragon_manager.connect("dragon_selected", self, "_on_dragon_selected")
	
	"""Inicialização do sistema de decoração do jogo"""
	
	# Adiciona o DecorationManager
	var decoration_manager = preload("res://scripts/managers/DecorationManager.gd").new()
	decoration_manager.name = "DecorationManager"
	add_child(decoration_manager)
	
	# Adiciona o FarmManager
	var farm_manager = preload("res://scripts/managers/FarmManager.gd").new()
	farm_manager.name = "farm_manager"
	add_child(farm_manager)
	
	print("Jogo inicializado com modo de decoração")
	print("Pressione B para ativar/desativar modo decoração")

func _input(event):
	"""Controles de teste"""
	
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_SPACE:
				# Spawna novo dragão
				dragon_manager.spawn_dragon_at_random_position()
			KEY_R:
				# Remove dragão selecionado
				if dragon_manager.selected_dragon != null:
					dragon_manager.remove_dragon(dragon_manager.selected_dragon)

func _on_dragon_spawned(dragon: Dragon):
	"""Responde quando novo dragão é criado"""
	
	print("Novo dragão criado: ", dragon.stats.dragon_name)

func _on_dragon_selected(dragon: Dragon):
	"""Responde quando dragão é selecionado"""
	
	print("Dragão selecionado: ", dragon.stats.dragon_name)
	
	# Move câmera para o dragão selecionado
	var tween = create_tween()
	tween.tween_property(camera, "global_position", dragon.global_position, 0.5)
