# 📜 Version History / Changelog (English)

<p align="center">
  <a href="CHANGELOG-PT-BR.md"><img src="https://img.shields.io/badge/Changelog-Portugu%C3%AAs%20(Brasil)-green?style=for-the-badge" alt="PT-BR"></a>
  <a href="CHANGELOG-EN.md"><img src="https://img.shields.io/badge/Changelog-English-blue?style=for-the-badge" alt="EN"></a>
  <a href="README-EN.md"><img src="https://img.shields.io/badge/Back%20to-README-orange?style=for-the-badge" alt="README"></a>
</p>

---

## 🚀 [v1.1.0] — 2026-09-28

* **🎮 PlayStation Controller Physical Buttons Protection (START & SELECT):**
  * Intelligent differentiation between hardware controller buttons and natural language verbs/menus across all 40 languages.
  * Uppercase buttons (START, SELECT) and controller button combinations (SELECT + START + L1, L1 + ... + START) remain strictly in English, exactly as stamped on original Sony hardware worldwide.
  * Natural verbs and phrases (To start a graphical interface..., Select which titles appear..., Start menu, Start Mode) localize smoothly and naturally.
  * Post-translation fail-safe sweeps prevent button combinations or qualifiers like botón START from being localized to INICIO or SELECCIONAR.

* **👤 Developer Name Immunity (CosmicScale):**
  * The upstream developer and reverse engineer's name **CosmicScale** (or **Cosmic Scale**) is strictly shielded across all 6 submodules and the master suite, preventing literal translation errors (e.g., *"Escala Cósmica"*, *"Kosmische Skala"*, *"Échelle Cosmique"*).

* **💻 Literal Inline Code Preservation (XYZICODE):**
  * Inline backticked code (`list-builder.py`) is now held directly in memory during Markdown tokenization without HTML tags.
  * Prevents Google Translate from mutating tags to `<código>` or capitalizing/modifying filenames and commands.

* **🧱 Pure HTML Spacer Lines Bugfix:**
  * Lines containing solely HTML layout tags (`<p></p>`, `<div></div>`) are recognized and bypassed prior to translation engine calls.
  * Fixed regex greed (`\D*`) in token restoration, preventing adjacent tag collisions like `<p>1_XYZ`.

* **🏷️ Visual Identity and Version Bump (v1.1.0 / V1.1):**
  * Bumped suite version to **v1.1.0** (V1.1 in launcher batch and interactive console banners across all 40 languages).
  * Updated Autonomous AI Agent Guidelines (`AGENTS.md` and `AGENTS_PTBR.md`) with the formal definition of Invariant 19.

---

## ⚡ [v1.0.0] — 2026-09-25

* **Official Launch:** Public release of the PSBBN Multilingual Translation Suite supporting 40 languages and 6 integrated modules.
* **POSIX Permission Injection:** Direct Windows POSIX 0755 binary permission injection for `bnupdate.tar.gz`.
* **XML Normalization:** Universal quote normalization for XML attributes with apostrophe/elision immunity in Romance languages.
