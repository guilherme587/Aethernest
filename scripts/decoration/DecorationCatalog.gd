# DecorationCatalog.gd - Catálogo de itens decorativos
class_name DecorationCatalog
extends Resource

# Catálogo de itens
var items_catalog: Dictionary = {}

func _init():
	"""Inicialização do catálogo"""
	load_catalog()

func load_catalog():
	"""Carrega catálogo de itens"""
	
	# Plantas e Natureza
	add_catalog_item({
		"id": "tree_oak",
		"name": "Carvalho",
		"description": "Uma árvore majestosa de carvalho",
		"category": "natureza",
		"price": 50,
		"texture_path": "res://assets/decorations/tree_oak.png",
		"can_rotate": true,
		"snap_to_grid": false
	})
	
	add_catalog_item({
		"id": "flower_red", 
		"name": "Flor Vermelha",
		"description": "Uma bela flor vermelha",
		"category": "natureza",
		"price": 10,
		"texture_path": "res://assets/decorations/flower_red.png",
		"can_rotate": false,
		"snap_to_grid": true
	})
	
	add_catalog_item({
		"id": "rock_large",
		"name": "Pedra Grande", 
		"description": "Uma pedra grande e resistente",
		"category": "pedras",
		"price": 30,
		"texture_path": "res://assets/decorations/rock_large.png",
		"can_rotate": true,
		"snap_to_grid": false
	})
	
	add_catalog_item({
		"id": "crystal_blue",
		"name": "Cristal Azul",
		"description": "Um cristal mágico azul brilhante", 
		"category": "cristais",
		"price": 100,
		"texture_path": "res://assets/decorations/crystal_blue.png",
		"can_rotate": false,
		"snap_to_grid": true
	})

func add_catalog_item(item_data: Dictionary):
	"""Adiciona item ao catálogo"""
	
	var id = item_data.get("id", "")
	if id != "":
		items_catalog[id] = item_data

func get_item_data(item_id: String) -> Dictionary:
	"""Retorna dados de um item"""
	
	return items_catalog.get(item_id, {})

func get_items_by_category(category: String) -> Array:
	"""Retorna itens de uma categoria"""
	
	var items = []
	
	for item_id in items_catalog:
		var item_data = items_catalog[item_id]
		if item_data.get("category", "") == category:
			items.append({
				"id": item_id,
				"data": item_data
			})
	
	return items

func get_all_categories() -> Array:
	"""Retorna todas as categorias disponíveis"""
	
	var categories = []
	
	for item_id in items_catalog:
		var item_data = items_catalog[item_id]
		var category = item_data.get("category", "geral")
		if not categories.has(category):
			categories.append(category)
	
	categories.sort()
	return categories
