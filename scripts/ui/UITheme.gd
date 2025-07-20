## UITheme.gd
## Tema customizado para a interface
#
#class_name UITheme
#extends Resource
#
#static func create_dark_theme() -> Theme:
#	"""Cria tema escuro para a interface"""
#
#	var theme = Theme.new()
#
#	# Estilo para painéis
#	var panel_style = StyleBoxFlat.new()
#	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
#	panel_style.border_color = Color(0.4, 0.7, 1.0, 0.8)
#	panel_style.border_width_left = 1
#	panel_style.border_width_right = 1
#	panel_style.border_width_top = 1
#	panel_style.border_width_bottom = 1
#	panel_style.corner_radius_top_left = 5
#	panel_style.corner_radius_top_right = 5
#	panel_style.corner_radius_bottom_left = 5
#	panel_style.corner_radius_bottom_right = 5
#
#	theme.set_stylebox("panel", "Panel", panel_style)
#
#	# Estilo para botões
#	var button_normal = StyleBoxFlat.new()
#	button_normal.bg_color = Color(0.3, 0.3, 0.4, 1.0)
#	button_normal.corner_radius_top_left = 3
#	button_normal.corner_radius_top_right = 3
#	button_normal.corner_radius_bottom_left = 3
#	button_normal.corner_radius_bottom_right = 3
#
#	var button_hover = StyleBoxFlat.new()
#	button_hover.bg_color = Color(0.4, 0.4, 0.5, 1.0)
#	button_hover.corner_radius_top_left = 3
#	button_hover.corner_radius_top_right = 3
#	button_hover.corner_radius_bottom_left = 3
#	button_hover.corner_radius_bottom_right = 3
#
#	theme.set_stylebox("normal", "Button", button_normal)
#	theme.set_stylebox("hover", "Button", button_hover)
#
#	return theme
