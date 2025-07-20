# CameraController.gd - Controle de câmera com mouse e zoom direcional
extends Camera2D

# === CONFIGURAÇÕES DE MOVIMENTAÇÃO ===
export var edge_detection_margin: float = 0.065  # Porcentagem da tela para ativar movimento (0.0 - 1.0)
export var move_speed: float = 500.0  # Velocidade base de movimento
export var smooth_factor: float = 0.1  # Suavização do movimento (0-1, menor = mais suave)

# === CONFIGURAÇÕES DE ACELERAÇÃO ===
export var enable_acceleration: bool = true  # Ativar/desativar aceleração gradual
export var max_speed_multiplier: float = 3.0  # Fator multiplicador para velocidade máxima
export var time_to_max_speed: float = 2.5  # Tempo em segundos para atingir velocidade máxima
export var direction_stability_time: float = 0.5  # Tempo necessário na mesma direção para acelerar

# === CONFIGURAÇÕES DE ZOOM ===
export var zoom_speed: float = 0.1  # Velocidade do zoom
export var min_zoom: float = 0.3  # Zoom máximo (mais próximo)
export var max_zoom: float = 3.0  # Zoom mínimo (mais longe)
export var zoom_smooth_factor: float = 0.15  # Suavização do zoom
export var require_ctrl_for_zoom: bool = true  # Requer Ctrl pressionado para zoom
export var zoom_towards_mouse: bool = true  # Zoom na direção do mouse

# === CONFIGURAÇÕES DE CURSOR ===
export var enable_dynamic_cursor: bool = true  # Ativar cursor dinâmico
export var cursor_change_threshold: float = 10.0  # Velocidade mínima para mudar cursor

# === CONFIGURAÇÕES OPCIONAIS ===
export var enable_edge_movement: bool = true  # Ativar/desativar movimento por borda
export var enable_zoom: bool = true  # Ativar/desativar zoom
export var invert_zoom: bool = false  # Inverter direção do zoom
export var enable_keyboard_movement: bool = true  # Movimento com WASD

# === VARIÁVEIS INTERNAS ===
var viewport_size: Vector2
var mouse_position: Vector2
var target_position: Vector2
var target_zoom: Vector2
var is_moving: bool = false

# Margens calculadas em pixels (atualizadas automaticamente)
var edge_margin_pixels: int

# Velocidades do teclado
var keyboard_velocity: Vector2 = Vector2.ZERO

# Variáveis para zoom direcional
var zoom_pivot: Vector2 = Vector2.ZERO
var world_mouse_position: Vector2 = Vector2.ZERO

# Variáveis para cursor dinâmico
var current_movement_direction: Vector2 = Vector2.ZERO
var movement_velocity: Vector2 = Vector2.ZERO
var previous_position: Vector2 = Vector2.ZERO

# Variáveis para aceleração gradual
var current_speed_multiplier: float = 1.0
var movement_start_time: float = 0.0
var stable_direction: Vector2 = Vector2.ZERO
var stable_direction_time: float = 0.0
var last_movement_direction: Vector2 = Vector2.ZERO
var is_accelerating: bool = false

# Cursores personalizados (definidos como constantes)
enum CursorDirection {
	DEFAULT,
	NORTH,
	NORTHEAST,
	EAST,
	SOUTHEAST,
	SOUTH,
	SOUTHWEST,
	WEST,
	NORTHWEST
}

var current_cursor: int = CursorDirection.DEFAULT

func _ready():
	"""Inicialização da câmera"""
	
	# Configura a câmera
	current = true
	
	# Pega tamanho inicial da viewport
	viewport_size = get_viewport().size
	
	# Calcula margem em pixels
	update_edge_margin()
	
	# Posição e zoom iniciais
	target_position = global_position
	target_zoom = zoom
	previous_position = global_position
	
	# Conecta sinal de redimensionamento da tela
	get_viewport().connect("size_changed", self, "_on_viewport_size_changed")
	
	print("CameraController inicializado")
	print("- Margem das bordas: ", edge_detection_margin * 100, "% (", edge_margin_pixels, "px)")
	print("- Velocidade base: ", move_speed)
	print("- Velocidade máxima: ", move_speed * max_speed_multiplier, " (", max_speed_multiplier, "x)")
	print("- Tempo para vel. máxima: ", time_to_max_speed, "s")
	print("- Estabilidade direcional: ", direction_stability_time, "s")
	print("- Zoom min/max: ", min_zoom, " - ", max_zoom)
	print("- Zoom requer Ctrl: ", require_ctrl_for_zoom)
	print("- Zoom direcional: ", zoom_towards_mouse)
	print("- Cursor dinâmico: ", enable_dynamic_cursor)
	print("- Aceleração: ", enable_acceleration)

func _process(delta):
	"""Atualização principal"""
	
	# Atualiza posição do mouse no mundo
	update_world_mouse_position()
	
	# Calcula velocidade de movimento
	calculate_movement_velocity(delta)
	
	# Atualiza sistema de aceleração
	if enable_acceleration:
		update_acceleration_system(delta)
	
	if enable_edge_movement:
		handle_edge_movement(delta)
	
	if enable_keyboard_movement:
		handle_keyboard_movement(delta)
	
	# Aplica movimento suave
	apply_smooth_movement(delta)
	
	# Aplica zoom suave
	apply_smooth_zoom(delta)
	
	# Atualiza cursor baseado no movimento
	if enable_dynamic_cursor:
		update_dynamic_cursor()

func _input(event):
	"""Processa inputs de zoom e outros eventos"""
	
	if enable_zoom and event is InputEventMouseButton:
		handle_zoom_input(event)

func update_world_mouse_position():
	"""Atualiza a posição do mouse no espaço do mundo"""
	mouse_position = get_viewport().get_mouse_position()
	world_mouse_position = get_global_mouse_position()

func calculate_movement_velocity(delta):
	"""Calcula a velocidade atual de movimento da câmera"""
	if delta > 0:
		movement_velocity = (global_position - previous_position) / delta
		current_movement_direction = movement_velocity.normalized()
	previous_position = global_position

func update_acceleration_system(delta):
	"""Atualiza o sistema de aceleração gradual"""
	
	# Detecta direção atual do movimento (edge + keyboard)
	var current_input_direction = Vector2.ZERO
	
	# Movimento por borda da tela
	if enable_edge_movement:
		if mouse_position.x <= edge_margin_pixels:
			current_input_direction.x -= 1
		elif mouse_position.x >= viewport_size.x - edge_margin_pixels:
			current_input_direction.x += 1
		
		if mouse_position.y <= edge_margin_pixels:
			current_input_direction.y -= 1
		elif mouse_position.y >= viewport_size.y - edge_margin_pixels:
			current_input_direction.y += 1
	
	# Movimento por teclado
	if enable_keyboard_movement:
		if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
			current_input_direction.x -= 1
		if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
			current_input_direction.x += 1
		if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
			current_input_direction.y -= 1
		if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
			current_input_direction.y += 1
	
	# Normaliza a direção
	if current_input_direction != Vector2.ZERO:
		current_input_direction = current_input_direction.normalized()
	
	# Verifica se há movimento
	if current_input_direction == Vector2.ZERO:
		# Sem movimento - reseta aceleração
		reset_acceleration()
		return
	
	# Verifica se a direção mudou significativamente
	var direction_threshold = 0.8  # Cos de ~36 graus
	var direction_similarity = 0.0
	
	if stable_direction != Vector2.ZERO:
		direction_similarity = stable_direction.dot(current_input_direction)
	
	if direction_similarity < direction_threshold:
		# Direção mudou - reinicia aceleração
		stable_direction = current_input_direction
		stable_direction_time = 0.0
		movement_start_time = 0.0
		current_speed_multiplier = 1.0
		is_accelerating = false
	else:
		# Mesma direção - acumula tempo
		stable_direction_time += delta
		
		# Verifica se já passou o tempo de estabilidade
		if stable_direction_time >= direction_stability_time and not is_accelerating:
			# Inicia aceleração
			is_accelerating = true
			movement_start_time = 0.0
		
		# Se está acelerando, atualiza multiplicador
		if is_accelerating:
			movement_start_time += delta
			
			# Calcula progresso da aceleração (0.0 a 1.0)
			var acceleration_progress = min(movement_start_time / time_to_max_speed, 1.0)
			
			# Aplica curva suave de aceleração (ease-out)
			acceleration_progress = ease_out_quad(acceleration_progress)
			
			# Calcula multiplicador atual
			current_speed_multiplier = 1.0 + (max_speed_multiplier - 1.0) * acceleration_progress

func ease_out_quad(t: float) -> float:
	"""Função de easing para aceleração mais suave"""
	return 1.0 - (1.0 - t) * (1.0 - t)

func reset_acceleration():
	"""Reseta o sistema de aceleração"""
	current_speed_multiplier = 1.0
	stable_direction = Vector2.ZERO
	stable_direction_time = 0.0
	movement_start_time = 0.0
	is_accelerating = false

func get_current_move_speed() -> float:
	"""Retorna a velocidade atual considerando aceleração"""
	if enable_acceleration:
		return move_speed * current_speed_multiplier
	else:
		return move_speed

func update_edge_margin():
	"""Atualiza a margem da borda baseada na porcentagem da tela"""
	
	# Usa a menor dimensão da tela para calcular a margem
	var reference_size = min(viewport_size.x, viewport_size.y)
	edge_margin_pixels = int(reference_size * edge_detection_margin)
	
	# Garante que a margem não seja menor que 1 pixel
	edge_margin_pixels = max(edge_margin_pixels, 1)

func handle_edge_movement(delta):
	"""Detecta movimento nas bordas da tela usando porcentagem"""
	
	var movement = Vector2.ZERO
	
	# Verifica bordas da tela usando pixels calculados da porcentagem
	if mouse_position.x <= edge_margin_pixels:
		# Borda esquerda
		movement.x = -1
	elif mouse_position.x >= viewport_size.x - edge_margin_pixels:
		# Borda direita
		movement.x = 1
	
	if mouse_position.y <= edge_margin_pixels:
		# Borda superior
		movement.y = -1
	elif mouse_position.y >= viewport_size.y - edge_margin_pixels:
		# Borda inferior
		movement.y = 1
	
	# Aplica movimento se houver (usando velocidade com aceleração)
	if movement != Vector2.ZERO:
		is_moving = true
		target_position += movement.normalized() * get_current_move_speed() * delta
	else:
		is_moving = false

func handle_keyboard_movement(delta):
	"""Movimento com teclado WASD"""
	
	keyboard_velocity = Vector2.ZERO
	
	# Detecta teclas pressionadas
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		keyboard_velocity.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		keyboard_velocity.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		keyboard_velocity.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		keyboard_velocity.y += 1
	
	# Aplica movimento do teclado (usando velocidade com aceleração)
	if keyboard_velocity != Vector2.ZERO:
		target_position += keyboard_velocity.normalized() * get_current_move_speed() * delta

func handle_zoom_input(event):
	"""Processa zoom com scroll do mouse com zoom direcional"""
	
	# Verifica se deve aplicar zoom
	if require_ctrl_for_zoom:
		if not (Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_META)):
			return
	
	var zoom_factor = 1.0
	var zoom_direction = 0
	
	if event.button_index == BUTTON_WHEEL_UP:
		# Zoom in (aproximar)
		zoom_factor = 1.0 - zoom_speed
		zoom_direction = 1
		if invert_zoom:
			zoom_factor = 1.0 + zoom_speed
			zoom_direction = -1
	elif event.button_index == BUTTON_WHEEL_DOWN:
		# Zoom out (afastar)
		zoom_factor = 1.0 + zoom_speed
		zoom_direction = -1
		if invert_zoom:
			zoom_factor = 1.0 - zoom_speed
			zoom_direction = 1
	else:
		return
	
	# Calcula novo zoom
	var new_zoom = target_zoom * zoom_factor
	
	# Limita o zoom
	new_zoom.x = clamp(new_zoom.x, min_zoom, max_zoom)
	new_zoom.y = clamp(new_zoom.y, min_zoom, max_zoom)
	
	# Se o zoom direcional estiver ativo, ajusta a posição da câmera
	if zoom_towards_mouse and zoom_direction != 0:
		apply_directional_zoom(new_zoom, zoom_direction)
	else:
		target_zoom = new_zoom

func apply_directional_zoom(new_zoom: Vector2, zoom_direction: int):
	"""Aplica zoom mantendo o ponto sob o mouse fixo"""
	
	# Posição atual do mouse no mundo antes do zoom
	var mouse_world_before = world_mouse_position
	
	# Calcula a diferença de zoom
	var zoom_change = new_zoom.x / target_zoom.x
	
	# Calcula o offset da câmera para o mouse
	var camera_to_mouse = mouse_world_before - target_position
	
	# Ajusta a posição da câmera baseada no zoom
	if zoom_direction > 0:  # Zoom in
		# Move a câmera em direção ao mouse
		var offset_factor = (1.0 - zoom_change) * 0.5
		target_position += camera_to_mouse * offset_factor
	else:  # Zoom out
		# Move a câmera se afastando do mouse
		var offset_factor = (zoom_change - 1.0) * 0.5
		target_position -= camera_to_mouse * offset_factor
	
	# Aplica o novo zoom
	target_zoom = new_zoom

func update_dynamic_cursor():
	"""Atualiza o cursor baseado na direção do movimento"""
	
	var speed = movement_velocity.length()
	
	# Só muda o cursor se estiver se movendo rápido o suficiente
	if speed < cursor_change_threshold:
		set_cursor_shape(CursorDirection.DEFAULT)
		return
	
	# Calcula o ângulo do movimento em graus
	var angle_rad = current_movement_direction.angle()
	var angle_deg = rad2deg(angle_rad)
	
	# Normaliza o ângulo para 0-360
	if angle_deg < 0:
		angle_deg += 360
	
	# Determina a direção baseada no ângulo
	var cursor_shape = CursorDirection.DEFAULT
	
	if angle_deg >= 337.5 or angle_deg < 22.5:
		cursor_shape = CursorDirection.EAST
	elif angle_deg >= 22.5 and angle_deg < 67.5:
		cursor_shape = CursorDirection.SOUTHEAST
	elif angle_deg >= 67.5 and angle_deg < 112.5:
		cursor_shape = CursorDirection.SOUTH
	elif angle_deg >= 112.5 and angle_deg < 157.5:
		cursor_shape = CursorDirection.SOUTHWEST
	elif angle_deg >= 157.5 and angle_deg < 202.5:
		cursor_shape = CursorDirection.WEST
	elif angle_deg >= 202.5 and angle_deg < 247.5:
		cursor_shape = CursorDirection.NORTHWEST
	elif angle_deg >= 247.5 and angle_deg < 292.5:
		cursor_shape = CursorDirection.NORTH
	elif angle_deg >= 292.5 and angle_deg < 337.5:
		cursor_shape = CursorDirection.NORTHEAST
	
	set_cursor_shape(cursor_shape)

func set_cursor_shape(shape: int):
	"""Define a forma do cursor"""
	
	if current_cursor == shape:
		return
	
	current_cursor = shape
	
	# Mapeia as direções para os cursors do Godot
	match shape:
		CursorDirection.DEFAULT:
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		CursorDirection.NORTH:
			Input.set_default_cursor_shape(Input.CURSOR_VSIZE)
		CursorDirection.SOUTH:
			Input.set_default_cursor_shape(Input.CURSOR_VSIZE)
		CursorDirection.EAST:
			Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
		CursorDirection.WEST:
			Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
		CursorDirection.NORTHEAST:
			Input.set_default_cursor_shape(Input.CURSOR_BDIAGSIZE)
		CursorDirection.SOUTHWEST:
			Input.set_default_cursor_shape(Input.CURSOR_BDIAGSIZE)
		CursorDirection.NORTHWEST:
			Input.set_default_cursor_shape(Input.CURSOR_FDIAGSIZE)
		CursorDirection.SOUTHEAST:
			Input.set_default_cursor_shape(Input.CURSOR_FDIAGSIZE)

func apply_smooth_movement(delta):
	"""Aplica movimento suave à câmera"""
	
	if smooth_factor <= 0:
		# Movimento instantâneo
		global_position = target_position
	else:
		# Movimento suave usando lerp
		global_position = global_position.linear_interpolate(target_position, smooth_factor)

func apply_smooth_zoom(delta):
	"""Aplica zoom suave à câmera"""
	
	if zoom_smooth_factor <= 0:
		# Zoom instantâneo
		zoom = target_zoom
	else:
		# Zoom suave usando lerp
		zoom = zoom.linear_interpolate(target_zoom, zoom_smooth_factor)

func _on_viewport_size_changed():
	"""Atualiza tamanho da viewport quando a tela muda"""
	
	viewport_size = get_viewport().size
	update_edge_margin()  # Recalcula margem quando a tela muda
	print("Viewport redimensionada para: ", viewport_size)
	print("Nova margem: ", edge_detection_margin * 100, "% (", edge_margin_pixels, "px)")

# === FUNÇÕES PÚBLICAS PARA CONTROLE EXTERNO ===

func set_camera_position(new_position: Vector2, instant: bool = false):
	"""Define posição da câmera"""
	
	target_position = new_position
	if instant:
		global_position = new_position

func set_camera_zoom(new_zoom: float, instant: bool = false):
	"""Define zoom da câmera"""
	
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	target_zoom = Vector2(new_zoom, new_zoom)
	if instant:
		zoom = target_zoom

func focus_on_position(position: Vector2, zoom_level: float = -1):
	"""Foca a câmera em uma posição específica"""
	
	set_camera_position(position)
	if zoom_level > 0:
		set_camera_zoom(zoom_level)

func reset_camera():
	"""Reseta câmera para posição e zoom inicial"""
	
	set_camera_position(Vector2.ZERO)
	set_camera_zoom(1.0)

func enable_movement(enabled: bool):
	"""Ativa/desativa movimento da câmera"""
	
	enable_edge_movement = enabled
	enable_keyboard_movement = enabled

func enable_zoom_control(enabled: bool):
	"""Ativa/desativa controle de zoom"""
	
	enable_zoom = enabled

func enable_directional_zoom(enabled: bool):
	"""Ativa/desativa zoom direcional"""
	
	zoom_towards_mouse = enabled

func enable_cursor_feedback(enabled: bool):
	"""Ativa/desativa feedback do cursor"""
	
	enable_dynamic_cursor = enabled
	if not enabled:
		set_cursor_shape(CursorDirection.DEFAULT)

func enable_speed_acceleration(enabled: bool):
	"""Ativa/desativa aceleração de velocidade"""
	
	enable_acceleration = enabled
	if not enabled:
		reset_acceleration()

# === FUNÇÕES DE DEBUG ===

func get_camera_info() -> Dictionary:
	"""Retorna informações da câmera para debug"""
	
	return {
		"position": global_position,
		"target_position": target_position,
		"zoom": zoom,
		"target_zoom": target_zoom,
		"is_moving": is_moving,
		"mouse_position": mouse_position,
		"world_mouse_position": world_mouse_position,
		"movement_velocity": movement_velocity,
		"movement_direction": current_movement_direction,
		"current_cursor": current_cursor,
		"viewport_size": viewport_size,
		"edge_margin_percent": edge_detection_margin,
		"edge_margin_pixels": edge_margin_pixels,
		"ctrl_pressed": Input.is_key_pressed(KEY_CONTROL) or Input.is_key_pressed(KEY_META),
		"zoom_towards_mouse": zoom_towards_mouse,
		"dynamic_cursor": enable_dynamic_cursor,
		"acceleration_enabled": enable_acceleration,
		"current_speed_multiplier": current_speed_multiplier,
		"current_move_speed": get_current_move_speed(),
		"stable_direction": stable_direction,
		"stable_direction_time": stable_direction_time,
		"is_accelerating": is_accelerating,
		"acceleration_progress": movement_start_time / time_to_max_speed if time_to_max_speed > 0 else 0.0
	}

func print_camera_info():
	"""Imprime informações da câmera no console"""
	
	var info = get_camera_info()
	print("=== CAMERA INFO ===")
	for key in info:
		print(key, ": ", info[key])
	print("==================")

# === CONFIGURAÇÕES AVANÇADAS ===

func set_edge_margin(margin_percent: float):
	"""Define margem das bordas como porcentagem (0.0 - 1.0)"""
	edge_detection_margin = clamp(margin_percent, 0.0, 1.0)
	update_edge_margin()

func set_move_speed(speed: float):
	"""Define velocidade de movimento"""
	move_speed = speed

func set_zoom_limits(min_z: float, max_z: float):
	"""Define limites de zoom"""
	min_zoom = min_z
	max_zoom = max_z
	
	# Ajusta zoom atual se estiver fora dos limites
	target_zoom.x = clamp(target_zoom.x, min_zoom, max_zoom)
	target_zoom.y = clamp(target_zoom.y, min_zoom, max_zoom)

func set_smoothness(move_smooth: float, zoom_smooth: float):
	"""Define suavização do movimento e zoom"""
	smooth_factor = clamp(move_smooth, 0.0, 1.0)
	zoom_smooth_factor = clamp(zoom_smooth, 0.0, 1.0)

func set_ctrl_requirement_for_zoom(require: bool):
	"""Define se o zoom requer Ctrl pressionado"""
	require_ctrl_for_zoom = require

func set_cursor_threshold(threshold: float):
	"""Define o threshold para mudança de cursor"""
	cursor_change_threshold = threshold

func set_acceleration_settings(max_multiplier: float, time_to_max: float, stability_time: float):
	"""Define configurações de aceleração"""
	max_speed_multiplier = max_multiplier
	time_to_max_speed = time_to_max
	direction_stability_time = stability_time
	
	# Reseta aceleração para aplicar novas configurações
	reset_acceleration()

func get_current_speed_multiplier() -> float:
	"""Retorna o multiplicador atual de velocidade"""
	return current_speed_multiplier

func get_acceleration_progress() -> float:
	"""Retorna o progresso da aceleração (0.0 - 1.0)"""
	if time_to_max_speed <= 0 or not is_accelerating:
		return 0.0
	return min(movement_start_time / time_to_max_speed, 1.0)

func is_camera_accelerating() -> bool:
	"""Retorna se a câmera está atualmente acelerando"""
	return is_accelerating

func get_edge_margin_pixels() -> int:
	"""Retorna a margem atual em pixels"""
	return edge_margin_pixels

func get_edge_margin_percent() -> float:
	"""Retorna a margem atual em porcentagem"""
	return edge_detection_margin

func get_movement_direction() -> Vector2:
	"""Retorna a direção atual do movimento"""
	return current_movement_direction

func get_movement_speed() -> float:
	"""Retorna a velocidade atual do movimento"""
	return movement_velocity.length()
