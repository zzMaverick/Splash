# 🎣 Splash — Jogo de Pesca em Godot 4

Projeto desenvolvido para a disciplina **Computação Gráfica (CMP 1170 – 2025/2)**, com o objetivo de demonstrar, de forma integrada, conceitos de **modelagem 3D, mapeamento UV, texturas PBR, iluminação, HUD e jogabilidade básica**, utilizando a **Godot Engine 4**.

---

## 📌 Descrição Geral

Este projeto consiste em um **jogo simples de pesca**, onde o jogador controla um personagem em um cenário 3D e utiliza uma **vara de pesca** para capturar peixes por meio de um **mini game interativo**.

O foco principal do trabalho está na correta aplicação dos conceitos de **Computação Gráfica**, especialmente:

* Organização hierárquica da cena
* Modelagem geométrica
* Mapeamento UV e texturização
* Iluminação e materiais
* Interface (HUD) funcional

---

## 🎮 Controles

* **W A S D** → Movimentação do personagem
* **Clique do mouse** → Arremessar a boia de pesca
* **Clique do mouse (mini game)** → Aumentar a barra de captura do peixe

---

## 🐟 Mecânica de Pesca (Mini Game)

1. O jogador arremessa a **boia** utilizando o clique do mouse.
2. Ao atingir a água, um **mini game** é iniciado.
3. Durante o mini game:

   * O **clique do mouse** faz a barra subir.
   * A barra diminui automaticamente ao longo do tempo.
4. Condições:

   * ❌ Se a barra chegar a **0%**, o peixe é perdido.
   * ✅ Se a barra chegar a **100%**, o peixe é capturado com sucesso.

Essa mecânica foi implementada para fornecer feedback visual claro e interação direta com o jogador.

---

## 🧱 Modelagem 3D e Hierarquia

* O projeto utiliza **modelos 3D organizados hierarquicamente** dentro da cena.
* Foram utilizadas primitivas e meshes de forma consciente.
* A **vara de pesca** é um dos principais objetos modelados e integrados ao gameplay.

---

## 🗺️ Mapeamento UV e Texturas

* Foram aplicados **mapas UV corretos** para evitar estiramentos e costuras visíveis.
* O **mapeamento UV foi utilizado para pintar a skin da vara de pesca**, garantindo coerência visual.
* As texturas contribuem diretamente para a leitura visual e o estilo do jogo.

---

## 🎨 Materiais

* Utilização de **materiais PBR**, respeitando os princípios trabalhados na disciplina:

  * Albedo (Diffuse)
  * Normal Map (quando aplicável)
  * Roughness / Metallic
* Os materiais foram ajustados visando equilíbrio entre **qualidade visual e desempenho**.

---

## 💡 Iluminação

* O cenário possui:

  * ☀️ **Luz direcional** para iluminação global
  * 💡 **Luz dinâmica** para reforçar volume, contraste e profundidade
* As sombras e intensidades foram configuradas de forma consciente, considerando o custo de renderização.

---

## 🖥️ HUD

O jogo apresenta um **HUD funcional**, responsável por:

* Exibir informações durante o mini game de pesca
* Comunicar estados importantes ao jogador (sucesso ou falha na captura)
* Manter boa legibilidade sem interferir na jogabilidade

Foram aplicados conceitos de composição visual, cores e preenchimento no 2D.

---

## ▶️ Execução do Projeto

O protótipo funciona de ponta a ponta, contendo:

* Tela inicial
* Jogabilidade básica
* Mini game de pesca
* Condição de sucesso (captura do peixe)
* Condição de falha (perda do peixe)

---

## 📁 Estrutura do Projeto

```
Splash/
├── Materiais/        # Materiais e texturas
├── fonts/            # Fontes utilizadas
├── models/           # Modelos 3D
├── scenes/           # Cenas do jogo
├── script/           # Scripts em GDScript
├── project.godot     # Arquivo principal do projeto
└── README.md
```

---

## ⚠️ Limitações Atuais

* Quantidade reduzida de missões, focadas apenas em demonstrar o funcionamento da mecânica principal
* Mecânica de pesca simples
* Cenário único

---

## 🚀 Possíveis Melhorias

* Adicionar diferentes tipos de peixes
* Variação de dificuldade no mini game
* Melhorias visuais no HUD
* Sons ambientes e efeitos sonoros
* Expansão do cenário e novos pontos de pesca

---

## 📚 Contexto Acadêmico

Projeto desenvolvido como **Exercício Avaliativo da disciplina de Computação Gráfica**, demonstrando a aplicação prática dos conteúdos abordados ao longo do semestre, incluindo modelagem, texturização, iluminação, renderização e interface.

---

## 👤 Autor

Projeto desenvolvido por **@zzMaverick**.

---

🎮 *Este projeto tem fins acadêmicos e educacionais.*
