# Tree.gd - Exemplo de árvore decorativa
extends DecorationItem

export var tree_type: String = "oak"
export var growth_stage: int = 3  # 1-3, onde 3 é totalmente crescida
export var seasonal_colors: bool = true

var base_scale: Vector2

func _ready():
	"""Inicialização da árvore"""
	
	# Chama inicialização da classe pai
	._ready()
	
	# Configurações específicas da árvore
	item_name = "Árvore " + tree_type.capitalize()
	item_description = "Uma bela árvore para decorar seu mundo"
	item_category = "natureza"
	can_rotate = true
	snap_to_grid = false
	
	base_scale = scale
	
	# Ajusta escala baseada no estágio de crescimento
	update_growth_stage()

func setup_from_data(data: Dictionary):
	"""Configura árvore a partir de dados"""
	
	# Configuração básica
	.setup_from_data(data)
	
	# Configurações específicas da árvore
	if data.has("tree_type"):
		tree_type = data.tree_type
	if data.has("growth_stage"):
		growth_stage = data.growth_stage
		update_growth_stage()

func update_growth_stage():
	"""Atualiza visual baseado no estágio de crescimento"""
	
	var growth_scale = 0.5 + (growth_stage * 0.25)  # 0.75, 1.0, 1.25
	scale = base_scale * growth_scale

func get_item_data() -> Dictionary:
	"""Retorna dados da árvore para salvar"""
	
	var data = .get_item_data()
	data.tree_type = tree_type
	data.growth_stage = growth_stage
	return data
