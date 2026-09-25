# 🎮 PSBBN Multilingual Translation Suite — PSBBN Definitive Project

<div align="center">

**🌐 Languages / Idiomas:**  
[![Português Brasil](https://img.shields.io/badge/Idioma-Portugu%C3%AAs%20(Brasil)-green?style=for-the-badge)](README-PT-BR.md)
[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](README-EN.md)

<br/>

[![PlayStation 2](https://img.shields.io/badge/Platform-PlayStation%202-003791?logo=playstation&logoColor=white)](https://en.wikipedia.org/wiki/PlayStation_2)
[![PSBBN](https://img.shields.io/badge/OS-PSBBN%20v0.32-blue.svg)](https://github.com/CosmicScale/PSBBN-Definitive-Project)
[![Languages](https://img.shields.io/badge/Languages-40%20Supported-success.svg)](#-global-40-languages-matrix)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%20%2B-blue?logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Author](https://img.shields.io/badge/Author-Emerson%20Teles-blueviolet)](https://github.com/Emertels)
[![Collaborator](https://img.shields.io/badge/Collaborator-CosmicScale-ff69b4)](https://github.com/CosmicScale)

<br/>

![PSBBN Multilingual Translation Suite](assets/preview.png)

</div>

---

The **PSBBN Multilingual Translation Suite** is an enterprise-grade automated localization, translation, and deployment toolkit developed by **Emerson Teles** specifically for **CosmicScale**'s **PSBBN Definitive Project** (PlayStation Broadband Navigator for PlayStation 2, modified and assembled by CosmicScale).

The suite translates, formats, verifies, and packages the entire PSBBN operating system, installation scripts, launchers, changelogs, and technical documentation across **40 languages** with zero manual intervention.

---

## 🔗 Official Upstream Project & Tracking Links

* **Main Project Repository:** [CosmicScale/PSBBN-Definitive-Project](https://github.com/CosmicScale/PSBBN-Definitive-Project/) — The official repository for the definitive, modernized PlayStation Broadband Navigator (PSBBN) for PlayStation 2, assembled, modified, and maintained by **CosmicScale**, complete with comprehensive project explanations and installation guides.
* **Multilingual Support Issue Tracker:** [Issue #299 — Support for multiple languages](https://github.com/CosmicScale/PSBBN-Definitive-Project/issues/299) — The official issue thread opened by CosmicScale specifically dedicated to planning, tracking, and implementing multilingual support across the entire PSBBN ecosystem.

---

## 🚀 Key Features & Architectural Highlights

* **Unified Master Dashboard & 6 Standalone Submodules:**
  Execute the complete suite via the interactive central dashboard (`PSBBN-Translator.bat` / `PSBBN-Translator.ps1`) or run any of the 6 specialized submodules independently:
  1. `System PSBBN`: Core PS2 OS files (XML dialogs, user guides, NetFront/ATOK HTML, and `bnupdate.tar.gz` package generation).
  2. `Script PSBBN`: Linux/WSL installer UI strings (`eng.txt`) with strict line length enforcement.
  3. `Launcher Windows`: Windows launcher configuration, multi-language auto-detection, and dynamic real-time key translation.
  4. `Changelog Main`: Official installer release notes and master changelog.
  5. `Changelog Patch`: Channel update histories and patch release logs.
  6. `Readme`: Technical documentation translation with markdown token shielding, code block isolation, and anchor synchronization.

* **Always-Fetch Latest Upstream Release First (Zero Outdated Files):**
  * Prior to translating, every module automatically contacts the official GitHub repository (`CosmicScale/PSBBN-Definitive-Project` / `CosmicScale/PSBBN-Definitive-English-Patch`) to download the latest official version.
  * Displays informative status `[i] Baixando a versão oficial mais recente do GitHub...` (localized) and replaces the local input file.
  * Gracefully falls back to the existing local copy only if GitHub or internet connectivity is unavailable.

* **Automatic Working Cache Purge & Persistent Dictionary Preservation:**
  * Translators automatically clean up intermediate working cache files (`cache_*.json`) upon completion, keeping disk footprint minimal and eliminating stale translation cache.
  * Safely preserves `Launcher_Windows/data/launcher_text_40langs.json` as the persistent master dictionary (relocated to `data/` to distinguish permanent assets from temporary caches) so newly translated launcher keys are retained permanently.

* **Clean Single-File Output & Strict Portuguese Separation (PT-BR vs PT-PT):**
  * When translating to Portuguese (Brazil), produces exclusively `README-PT-BR.md` (no duplicate `README-POR.md` files).
  * When translating to Portuguese (Portugal), produces exclusively `README-PT-PT.md` (no duplicate `README-PTT.md` files).
  * Applies dedicated European Portuguese localization rules (`ficheiros` instead of `arquivos`, `aplicações` instead of `aplicativos`, `ecrã` instead of `tela`).
  * Header navigation bar accurately displays native language links for both dialects.
  * Every translation pass generates strictly 1 output file per language without duplicate copies.

* **Selective Input File Deletion Prompting ([X] / [V]):**
  * Input file management options (`[X] Delete file from input folder | [V] Keep file in input folder`) appear strictly when files were actually downloaded and translated.
  * When switching UI languages (`[L]`), input deletion prompts are completely suppressed, showing only clean navigation keys (`[Enter] Main Menu | [B] Previous Screen | [Esc] Exit`).

* **Centered Terminal UI & Balanced 2-Line Texture Warning:**
  * Session start timestamp (`Session started at: ...`) is centered directly below the master suite title banner.
  * The texture notice (`TextureDisclaimer`) is dynamically reflowed into two clean, balanced sentences ($\le 84$ characters per line) and centered, eliminating terminal window overflow and mid-word breaks.

* **Native Language Confirmation Across All 40 Languages:**
  * Complete 40-language dictionary for `LangAppliedSuccess`, confirming language changes natively in all 40 languages (e.g. Polish, Czech, Russian, French, German, Japanese, etc.).

* **Resilient RFC-Compliant Markdown Token Shielding (README Translation):**
  * Replaced fragile punctuation tokens (`XYZMDURL_0_XYZ`) with standard RFC-compliant dummy URLs (`https://u{n}.link`) and HTML `<code>...</code>` wrapping.
  * Google Translate neural models treat dummy URLs and code elements as intact syntax, eliminating broken brackets, scrambled token characters, and lost URLs.
  * Multi-pass regex restoration guarantees 100% of links and anchors are restored cleanly with 0 unrestored token remnants.

* **Dynamic Real-Time Key Expansion (PSBBN Launcher for Windows):**
  * Downloads the official upstream launcher script directly from GitHub releases.
  * Dynamically parses all official keys from `eng = @{ ... }` without relying on hardcoded indices or static limits.
  * If CosmicScale adds new keys (`prompt_22`, `warn_10`, `error_13`, etc.), the suite automatically translates them live via Google Translate API with 3-tier fallback.
  * Enforces strict single-line formatting via `Format-LauncherString` (collapsing `\r\n` and redundant spaces to guarantee 0 line breaks).
  * Automatically caches new translations into `launcher_text_40langs.json` and updates individual block exports in `output/individual/<lang>.txt`.

* **Strict Code Block & Fence Isolation (README Translation):**
  * Tracks `$inCodeFence` state across markdown code fences (` ``` ` and `~~~`).
  * All terminal commands, bash scripts, and directory paths (`cd PSBBN-Definitive-Project`, `sudo apt install git`, `./PSBBN-Definitive-Patch.sh`) remain 100% untranslated in pristine raw English, completely preventing execution breakage like `cd PSBBN-Depinitibo-Proyekto`.

* **Multilingual Heading Contextualization & False-Cognate Immunity:**
  * Protects `Main Menu` from being misidentified by translation engines as the Malay word "main" ("play").
  * Ensures flawless contextual localization across all 40 languages:
    * Filipino/Tagalog: `## Pangunahing Menu` (never `## Play Menu`), `# Pagpapakita ng Video ng PSBBN`
    * Portuguese (BR & PT): `## Menu Principal`, `# Demonstração em Vídeo do PSBBN`
    * Spanish: `## Menú Principal`, `# Demostración en Video de PSBBN`
    * French: `## Menu Principal`
    * German: `## Hauptmenü`
    * Russian: `## Главное меню`

* **Strict Portuguese (PT-BR / PT-PT) Terminology Standardization:**
  * Completely eliminates bureaucratic jargon "habilitar / desabilitar" across all modules, strings, and caches.
  * Standardized strictly to "ativar / desativar" ("ative", "desative", "ativado", "desativado", "ativando", "desativando").

* **100% Full UI Localization Across 40 Languages:**
  * Zero hardcoded language leakage: When running in English (or any other language), 100% of terminal banners, interactive prompts, inline progress counters, status notifications, and error handlers render in the active language.
  * Real-time dynamic language switcher (`[L] Change Language`) available at any point during navigation.

* **PS2 Hardware Native Compatibility:**
  * **Dual-Encoding Architecture:** Guarantees all PS2 XML/HTML files are encoded in UTF-8 **without BOM** (preventing Emotion Engine XML parser boot crashes), while PowerShell scripts use UTF-8 **with BOM** (preventing ANSI codepage corruption).
  * **POSIX 0755 Binary Injection:** Injects POSIX executable permissions (`-rwxr-xr-x`) into `bnupdate.tar.gz` for `./opt0/bn/bin/bn` via pure PowerShell byte-level tar header manipulation on Windows, resolving `Permission Denied (errno 13)` without requiring WSL or Linux tools.

* **Intelligent User Guide Reconstruction (`opt0/bn/script/guide`):**
  Concatenates fragmented `<LINE>` tags into complete sentences before translation, reflowing post-translation with balanced margins ($\le 52$ characters), 2-space hanging indents, dynamic `<TEXTAREA>` header sizing (`visible` and `scrollbar`), and zero orphaned words (`video.`, `at`).

* **Targeted XML Repair & Universal Attribute Quote Normalization:**
  * Fixes upstream quotes in error.xml:13 without stripping or corrupting valid XML attributes (subgroup="info_item").
  * Automatically normalizes single-quoted attributes (alue='...') to standard double-quoted attributes (alue="..."), completely eliminating XML syntax breakages caused by natural apostrophes and elisions in languages like Italian (d'accordo, l'avvio, dell'unitÃ ), French (l'Ã©cran), Catalan, and English.

* **Deep 40-Language Gaming Glossary:**
  Protects PS2 community brands (`Open PS2 Loader`, `APA-Jail`, `Save Application System`, `In-Game Reset`, `Virtual Memory Cards`, `VMC Groups`, `Game and App Installer`) and hardware switches (`MAIN POWER`, `ON/STANDBY/RESET`) from literal translation blunders across Tagalog, Arabic, Russian, Japanese, etc.

* **Terminal Script Line-Fitting ($\le 104$ chars):**
  4-tier abbreviation and trimming algorithm ensuring all 458 installer UI strings fit cleanly within Linux/WSL dialog boxes.

* **Rock-Solid Syntax & Clean Footprint:**
  100% of scripts achieve **0 AST syntax parser errors** verified via PowerShell AST, with an optimized codebase (~350 KB for master script).

---

## 🌐 Global 40 Languages Matrix

| # | ISO | Language | Native Name | Folder | # | ISO | Language | Native Name | Folder |
|:-:|:---:|:---------|:------------|:-------|:-:|:---:|:---------|:------------|:-------|
| 01 | `ar` | Arabic | العربية | `Arabic` | 21 | `ko` | Korean | 한국어 | `Korean` |
| 02 | `bn` | Bengali | বাংলা | `Bengali` | 22 | `ms` | Malay | Bahasa Melayu | `Malay` |
| 03 | `bg` | Bulgarian | Български | `Bulgarian` | 23 | `mr` | Marathi | मराठी | `Marathi` |
| 04 | `zh-cn` | Chinese (Simp.) | 简体中文 | `Chinese (Simplified)` | 24 | `no` | Norwegian | Norsk | `Norwegian` |
| 05 | `zh-tw` | Chinese (Trad.) | 繁體中文 | `Chinese (Traditional)` | 25 | `fa` | Persian | فارسی | `Persian` |
| 06 | `hr` | Croatian | Hrvatski | `Croatian` | 26 | `pl` | Polish | Polski | `Polish` |
| 07 | `cs` | Czech | Čeština | `Czech` | 27 | `pt` | Portuguese (BR) | Português (Brasil) | `Portuguese (Brazil)` |
| 08 | `da` | Danish | Dansk | `Danish` | 28 | `pt-pt` | Portuguese (PT) | Português (Portugal) | `Portuguese (Portugal)` |
| 09 | `nl` | Dutch | Nederlands | `Dutch` | 29 | `ro` | Romanian | Română | `Romanian` |
| 10 | `tl` | Filipino | Tagalog | `Filipino` | 30 | `ru` | Russian | Русский | `Russian` |
| 11 | `fi` | Finnish | Suomi | `Finnish` | 31 | `sr` | Serbian | Српски | `Serbian` |
| 12 | `fr` | French | Français | `French` | 32 | `sk` | Slovak | Slovenčina | `Slovak` |
| 13 | `de` | German | Deutsch | `German` | 33 | `es` | Spanish | Español | `Spanish` |
| 14 | `el` | Greek | Ελληνικά | `Greek` | 34 | `sv` | Swedish | Svenska | `Swedish` |
| 15 | `iw` | Hebrew | עברית | `Hebrew` | 35 | `ta` | Tamil | தமிழ் | `Tamil` |
| 16 | `hi` | Hindi | हिन्दी | `Hindi` | 36 | `te` | Telugu | తెలుగు | `Telugu` |
| 17 | `hu` | Hungarian | Magyar | `Hungarian` | 37 | `th` | Thai | ไทย | `Thai` |
| 18 | `id` | Indonesian | Bahasa Indonesia | `Indonesian` | 38 | `tr` | Turkish | Türkçe | `Turkish` |
| 19 | `it` | Italian | Italiano | `Italian` | 39 | `uk` | Ukrainian | Українська | `Ukrainian` |
| 20 | `ja` | Japanese | 日本語 | `Japanese` | 40 | `vi` | Vietnamese | Tiếng Việt | `Vietnamese` |

---

## 🛠️ Quick Start

### Method 1: Interactive Launcher (Recommended)
Double click **`PSBBN-Translator.bat`** in the repository root.
* Automatically configures UTF-8 terminal code page (65001), enables QuickEdit mode, applies execution bypass, and presents the interactive color menu in your preferred language.

### Method 2: PowerShell Direct Execution
```powershell
powershell.exe -ExecutionPolicy Bypass -File "PSBBN-Translator.ps1"
```

To run individual modules standalone:
```powershell
# System PSBBN
powershell.exe -ExecutionPolicy Bypass -File "System PSBBN\Translate-System-PSBBN.ps1"

# Script PSBBN
powershell.exe -ExecutionPolicy Bypass -File "Script PSBBN\Translate-Script-PSBBN.ps1"

# Windows Launcher (Standalone with dynamic real-time keys)
powershell.exe -ExecutionPolicy Bypass -File "Launcher_Windows\Translate-Launcher-Windows.ps1"

# Changelog Main
powershell.exe -ExecutionPolicy Bypass -File "Changelog_Main\Translate-Changelog-Main.ps1"

# Changelog Patch
powershell.exe -ExecutionPolicy Bypass -File "Changelog_Patch\Translate-Changelog-Patch.ps1"

# Readme (with code block isolation and anchor mapping)
powershell.exe -ExecutionPolicy Bypass -File "Readme\Translate-README.ps1"
```

---

## 👨‍💻 Credits & Acknowledgments

* **Emerson Teles** — Lead developer, architect of the PSBBN Multilingual Translation Suite, POSIX binary header injector, dynamic line-fitting algorithms, AST syntax auditor, and translation pipeline automation.
* **CosmicScale** — Founder, visionary, and maintainer of the **PSBBN Definitive Project**, lead PS2 modder, and author of the official upstream scripts, guides, and patch ecosystem.

---

## 👤 About the Author

Developed and maintained by **Emerson Teles** (known in the community as **Emertels**).

Passionate about technology, PC computing, gaming, system maintenance, and open software/emulator localization into Brazilian Portuguese (PT-BR).

### 🛠️ Notable Projects & Contributions:
- **Emulation & Consoles:** Architect & creator of the **PSBBN Multilingual Translation Suite** (40 languages) for PS2 in collaboration with CosmicScale; localization and community support for **PSBBN** (PlayStation Broadband Navigator), **PCSX2**, **Dolphin**, **shadPS4**, **Azahar**, and **RetroArch**.
- **Software & Utilities:** 100% Brazilian localization for **DSX** (DualSense X - Trusted Translator), **ASUS GPU Tweak III**, **dnGrep**, **XWidget**, and web utilities (**DualSense Tester**, **DualShock Tools**).
- **Games & Apps:** Localization of **Silent Hill 5: Homecoming**, ongoing translation for **Silent Hill 4: The Room**, and various Android & PC applications.

---

### 🌐 Connect with me:

<div align="left">

[![GitHub](https://img.shields.io/badge/GitHub-Emertels-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/emertels)
[![X / Twitter](https://img.shields.io/badge/X_Twitter-@emertels-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/emertels)
[![YouTube](https://img.shields.io/badge/YouTube-Emerson_Teles-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@emersonteles2379)
[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support%20Project-FF5E5B?style=for-the-badge&logo=kofi&logoColor=white)](https://ko-fi.com/emertels)

</div>

