

enum Variacao {
	NORMAL,
	DOURADO,
	GELO
}

func pegar_peixe() -> Peixe:
	var total = 0
	for p in TIPO_PEIXE:
		total += p["peso"]

	var sorte = randi_range(1, total)
	var acumulado = 0

	for p in TIPO_PEIXE:
		acumulado += p["peso"]
		if sorte <= acumulado:
			return Peixe.new(
				p["nome"],
				p["peso"],
				p["raridade"]
			)

	return null
