# DragonManager.gd - Versão com interface programática
# DragonManager.gd - Versão com CanvasLayer
class_name DragonManager
extends Node2D

var dragon_scene = preload("res://scenes/Dragon.tscn")
var active_dragons: Array = []

# Interface usando CanvasLayer para controle absoluto
var ui_canvas_layer: CanvasLayer
var dragon_info_ui: DragonInfoUI

var selected_dragon: Dragon = null

signal dragon_spawned(dragon)
signal dragon_selected(dragon)

func _ready():
	setup_ui()
	call_deferred("spawn_test_dragons")

func setup_ui():
	"""Cria interface usando CanvasLayer"""
	
	# Cria CanvasLayer para UI
	ui_canvas_layer = CanvasLayer.new()
	ui_canvas_layer.layer = 10  # Layer alto para ficar por cima
	add_child(ui_canvas_layer)
	
	# Cria interface
	dragon_info_ui = DragonInfoUI.new()
	dragon_info_ui.connect("close_requested", self, "_on_info_ui_close_requested")
	ui_canvas_layer.add_child(dragon_info_ui)


func spawn_test_dragons():
	"""Spawna dragões de teste"""
	for i in range(3):
		spawn_dragon_at_random_position()

func _input(event):
	"""Input global"""
	
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_SPACE:
				spawn_dragon_at_random_position()
			KEY_R:
				if selected_dragon:
					remove_dragon(selected_dragon)

func spawn_dragon_at_random_position() -> Dragon:
	"""Spawna dragão em posição aleatória"""
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var spawn_position = Vector2(
		rng.randf_range(-400, 400),
		rng.randf_range(-300, 300)
	)
	
	return spawn_dragon_at_position(spawn_position)

func spawn_dragon_at_position(position: Vector2) -> Dragon:
	"""Spawna dragão na posição especificada"""
	
	var dragon = dragon_scene.instance()
	dragon.global_position = position
	
	dragon.connect("dragon_clicked", self, "_on_dragon_clicked")
	dragon.connect("stats_updated", self, "_on_dragon_stats_updated")
	
	add_child(dragon)
	active_dragons.append(dragon)
	
	emit_signal("dragon_spawned", dragon)
	
	return dragon

func _on_dragon_clicked(dragon: Dragon):
	"""Dragão clicado"""
	
	select_dragon(dragon)

func select_dragon(dragon: Dragon):
	"""Seleciona dragão"""
	
	selected_dragon = dragon
	dragon_info_ui.show_dragon_info(dragon)
	emit_signal("dragon_selected", dragon)

func deselect_dragon():
	"""Deseleciona dragão"""
	
	selected_dragon = null
	dragon_info_ui.hide_dragon_info()

func _on_info_ui_close_requested():
	"""Fechar interface"""
	
	deselect_dragon()

func _on_dragon_stats_updated(dragon: Dragon):
	"""Stats atualizados"""
	pass

func remove_dragon(dragon: Dragon):
	"""Remove dragão"""
	
	if selected_dragon == dragon:
		deselect_dragon()
	
	active_dragons.erase(dragon)
	dragon.queue_free()
