## CustomStatusBar.gd - Versão Godot 3.6
## Barra de status customizada com animações
#
#class_name CustomStatusBar
#extends Control
#
#onready var label: Label = $Label
#onready var progress_bar: ProgressBar = $ProgressBar
#onready var value_label: Label = $ValueLabel
#onready var tween: Tween = $Tween
#
#var target_value: float = 0.0
#var current_display_value: float = 0.0
#var animation_speed: float = 2.0
#
#func _ready():
#	set_process(true)
#
#func _process(delta):
#	# Anima mudanças de valor suavemente
#	if abs(current_display_value - target_value) > 0.1:
#		current_display_value = lerp(current_display_value, target_value, animation_speed * delta)
#		progress_bar.value = current_display_value
#		update_value_display()
#
#func set_values(label_text: String, current: float, maximum: float, icon: String = ""):
#	"""Define valores da barra"""
#
#	label.text = icon + " " + label_text
#	target_value = (current / maximum) * 100.0
#
#	# Atualiza cor baseado no valor
#	update_color(target_value)
#
#func update_value_display():
#	"""Atualiza display do valor"""
#
#	var display_percentage = int(current_display_value)
#	value_label.text = str(display_percentage) + "%"
#
#func update_color(percentage: float):
#	"""Atualiza cor baseado na porcentagem"""
#
#	var bar_color = Color.green
#	if percentage < 25:
#		bar_color = Color.red
#	elif percentage < 50:
#		bar_color = Color.orange
#	elif percentage < 75:
#		bar_color = Color.yellow
#
#	# Anima mudança de cor usando Tween do Godot 3.6
#	tween.interpolate_property(progress_bar, "modulate", progress_bar.modulate, bar_color, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
#	tween.start()
