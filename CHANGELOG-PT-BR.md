# 📜 Histórico de Alterações / Changelog (Português)

<p align="center">
  <a href="CHANGELOG-PT-BR.md"><img src="https://img.shields.io/badge/Changelog-Portugu%C3%AAs%20(Brasil)-green?style=for-the-badge" alt="PT-BR"></a>
  <a href="CHANGELOG-EN.md"><img src="https://img.shields.io/badge/Changelog-English-blue?style=for-the-badge" alt="EN"></a>
  <a href="README.md"><img src="https://img.shields.io/badge/Voltar%20ao-README-orange?style=for-the-badge" alt="README"></a>
</p>

---

## 🚀 [v1.1.0] — 28/09/2026

* **🎮 Proteção dos Botões Físicos do Controle PlayStation (START e SELECT):**
  * Implementada diferenciação inteligente entre botões físicos de hardware e termos em linguagem natural em todos os 40 idiomas.
  * Botões em caixa alta (START, SELECT) e combinações de botões (SELECT + START + L1, L1 + ... + START) permanecem estritamente em inglês conforme gravados nos controles originais da Sony.
  * Frases e verbos em linguagem natural (To start a graphical interface..., Select which titles appear..., Start menu, Start Mode) continuam sendo traduzidos com total naturalidade e fluidez linguística.
  * Adicionadas varreduras de segurança pós-tradução para evitar que expressões como botón START ou combinações de controle sejam traduzidas indevidamente para INICIO ou SELECCIONAR.

* **👤 Imunidade Absoluta ao Nome do Desenvolvedor (CosmicScale):**
  * O nome do desenvolvedor e engenheiro reverso upstream **CosmicScale** (ou **Cosmic Scale**) foi blindado em todos os 6 submódulos e na suíte mestre, impedindo qualquer tradução literal inadequada (ex.: *"Escala Cósmica"*, *"Kosmische Skala"*, *"Échelle Cosmique"*).

* **💻 Preservação Literal de Código Inline (XYZICODE):**
  * O código inline com crases (`list-builder.py`) agora é armazenado diretamente em memória durante a tokenização Markdown, sem o uso de tags HTML.
  * Elimina a tradução errônea de tags para `<código>` pelo Google Tradutor e impede a capitalização ou alteração indesejada de nomes de arquivos e comandos.

* **🧱 Correção de Linhas Espaçadoras de HTML Puro:**
  * Linhas contendo exclusivamente elementos HTML (como `<p></p>`, `<div></div>` ou tags de layout) agora são detectadas e preservadas integralmente antes do envio ao motor de tradução.
  * Corrigida a expressão regular de restauração que causava ganância de caracteres (`\D*`), prevenindo o surgimento de anomalias como `<p>1_XYZ`.

* **🏷️ Atualização da Identidade Visual e Versão da Suíte (v1.1.0 / V1.1):**
  * Versão da suíte atualizada para **v1.1.0** (V1.1 no executável batch e nos títulos de console de todos os 40 idiomas).
  * Atualização completa das diretrizes para agentes autônomos (`AGENTS.md` e `AGENTS_PTBR.md`) com a inclusão formal da Invariante 19.

---

## ⚡ [v1.0.0] — 25/09/2026

* **Lançamento Oficial:** Lançamento público da Suíte de Tradução Multilíngue do PSBBN com suporte a 40 idiomas e 6 módulos integrados.
* **Injeção de Permissões POSIX:** Injeção binária direta de permissões POSIX 0755 no pacote `bnupdate.tar.gz` diretamente no ambiente Windows.
* **Normalização XML:** Normalização universal de aspas em atributos XML com imunidade a apóstrofos e elisões em idiomas românicos.
