# Enums.gd - Singleton Global
# Não usar class_name aqui, será registrado como singleton

# Estados comportamentais dos dragões
enum DragonState {
	WANDERING,      # Vagando livremente
	SEEKING_FOOD,   # Procurando comida
	EATING,         # Comendo
	RESTING,        # Descansando
	TERRITORIAL,    # Defendendo território
	AGGRESSIVE,     # Comportamento agressivo
	FLEEING,        # Fugindo de algo
	SLEEPING,       # Dormindo
	ENRAGED         # NOVO: Estado de raiva destrutiva
}

# Tipos de personalidade
enum PersonalityTrait {
	CURIOUS,        # Explora mais, se move bastante
	AGGRESSIVE,     # Ataca facilmente, territorial
	LAZY,           # Se move menos, descansa mais
	SOLITARY,       # Prefere ficar sozinho
	SOCIAL,         # Gosta de estar perto de outros
	TERRITORIAL,    # Defende área específica
	PEACEFUL,       # Evita conflitos
	ENERGETIC      # Sempre ativo, menos descanso
}

# Tipos de dragão
enum DragonType {
	FIRE,
	ICE,
	EARTH,
	WIND,
	CRYSTAL,
	SHADOW
}

# Níveis de satisfação
enum SatisfactionLevel {
	MISERABLE,      # 0-20
	UNHAPPY,        # 21-40
	NEUTRAL,        # 41-60
	CONTENT,        # 61-80
	HAPPY           # 81-100
}
