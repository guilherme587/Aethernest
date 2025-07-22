# Criar um script de teste para verificar o combate
class_name CombatTester
extends Node

func _ready():
	# Conecta tecla de debug
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_F1:
				test_dragon_combat()
			KEY_F2:
				force_dragon_anger()

func test_dragon_combat():
	"""Testa combate entre dragões"""
	
	var dragons = get_tree().get_nodes_in_group("dragons")
	
	if dragons.size() < 2:
		print("Precisa de pelo menos 2 dragões para testar combate!")
		return
	
	var attacker = dragons[0]
	var victim = dragons[1]
	
	print("=== TESTE DE COMBATE ===")
	print("Atacante: ", attacker.stats.dragon_name, " (Dano: ", attacker.stats.damage, ")")
	print("Vítima: ", victim.stats.dragon_name, " (Vida: ", victim.stats.health, "/", victim.stats.max_health, ")")
	
	# Força ataque
	if attacker.behavior:
		attacker.behavior.target_dragon = victim
		attacker.behavior.attack_dragon(0.1)
	
	print("Após ataque - Vítima vida: ", victim.stats.health, "/", victim.stats.max_health)
	print("=== FIM TESTE ===")

func force_dragon_anger():
	"""Força um dragão a ficar com raiva"""
	
	var dragons = get_tree().get_nodes_in_group("dragons")
	
	if dragons.size() == 0:
		print("Nenhum dragão encontrado!")
		return
	
	var dragon = dragons[0]
	
	# Reduz satisfação para causar raiva
	dragon.stats.satisfaction = 0
	
	# Força check de raiva
	if dragon.behavior:
		dragon.behavior.become_angry()
	
	print("Forçou ", dragon.stats.dragon_name, " a ficar com raiva!")
