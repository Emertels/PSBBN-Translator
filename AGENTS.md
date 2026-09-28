# AGENTS.md â€” Autonomous AI Agent Guidelines for PSBBN Multilingual Translation Suite

This document defines architectural standards, technical guidelines, and operational safety rules for autonomous AI agents (such as Google Antigravity, Claude Code, Cursor, and Codex) modifying, executing, or extending the **PSBBN Multilingual Translation Suite**.

---

## 1. Project Overview & Architecture

* **Target Application:** PlayStation 2 â€” Broadband Navigator (PSBBN Definitive Project by CosmicScale).
* **Developer:** **Emerson Teles**.
* **Target Project & PSBBN Modder:** **CosmicScale** (creator and maintainer behind the PSBBN Definitive Project, responsible for assembling, modding, and enhancing the PSBBN OS).
* **Repository Role:** Complete automated multilingual localization, translation, validation, and packaging suite developed by **Emerson Teles** specifically for **CosmicScale**'s project, supporting 40 languages across 6 system modules.

### The 6 System Modules:
1. **System PSBBN (`System PSBBN/`):** Translates all PS2 core OS files: XML dialogs, user guides (`opt0/bn/script/guide/`), ATOK/NetFront browser HTML help, and `sysconf.xml` menu items. Generates the deployment archive `bnupdate.tar.gz`.
2. **Script PSBBN (`Script PSBBN/`):** Translates the 458 strings in `eng.txt` used by the Linux/WSL installer UI. Enforces strict terminal window character limits ($\le 104$ chars).
3. **Launcher Windows (`Launcher_Windows/`):** Generates and maintains multilingual UI configurations and locale auto-detection for the Windows installer launcher across all 40 languages with dynamic real-time key expansion.
4. **Changelog Main (`Changelog_Main/`):** Localizes installer master release notes and version history.
5. **Changelog Patch (`Changelog_Patch/`):** Localizes channel patch logs and incremental update histories.
6. **Readme (`Readme/`):** Localizes the comprehensive technical documentation (`README.md`) while preserving markdown syntax, code blocks, badges, anchors, and external URLs.

---

## 2. Critical Safety Invariants (MANDATORY RULES)

Autonomous agents operating on this repository MUST strictly respect the following 19 invariants:

### 1. DUAL-ENCODING ARCHITECTURE: PS2 XML (NO BOM) vs POWERSHELL PS1 (WITH BOM)
* **PS2 XML Files (`.xml`, `.html`):** The PlayStation 2 C/C++ XML parser requires `<?xml` at byte offset 0. Any Byte Order Mark (BOM) causes the PS2 kernel to crash or enter an infinite boot loop. System XML files MUST ALWAYS be written without BOM:
  ```powershell
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($targetPath, $content, $utf8NoBom)
  ```
* **Windows PowerShell Scripts (`.ps1`) & Markdown (`.md`):** Windows PowerShell 5.1 interprets scripts without a BOM as ANSI/Windows-1252. In scripts containing multilingual dictionaries (Tagalog, Arabic, Russian, Japanese, etc.), a missing BOM corrupts non-ASCII strings and generates hundreds of AST syntax errors. All `.ps1` and `.md` files MUST ALWAYS be saved in UTF-8 **WITH BOM**:
  ```powershell
  $utf8Bom = New-Object System.Text.UTF8Encoding($true)
  [System.IO.File]::WriteAllText($scriptPath, $content, $utf8Bom)
  ```

### 2. TARGETED XML REPAIR & ATTRIBUTE INTEGRITY
* Upstream translation packages contain known syntax flaws in specific files (e.g., literal unescaped quotes in `error.xml:13`: `value="...from "Check/Change"..."`).
* Agents MUST NEVER run broad regexes that replace unescaped quotes globally across tag contents, as this destroys valid XML attributes (such as `subgroup="info_item"`).
* Repairs must be strictly targeted:
  ```powershell
  $line = $line -replace 'value="([^"]*?)"Check/Change"([^"]*?)"', 'value="$1&quot;Check/Change&quot;$2"'
  ```
* Ensure valid XML entities: `&amp;`, `&lt;`, `&gt;`, `&quot;`, and `&apos;`.

### 3. USER GUIDE TEXTAREA RECONSTRUCTION & BALANCED LINE WRAPPING
* In user guide XML files (`opt0/bn/script/guide/*.xml`), text inside `<TEXTAREA>` elements is frequently split across multiple `<LINE>` tags mid-sentence.
* Translating individual lines produces broken, nonsensical grammar. Agents MUST:
  1. Concatenate split `<LINE>` elements into complete paragraph blocks.
  2. Translate the continuous paragraph.
  3. Reflow the translated text with balanced line wrapping ($\le 52$ characters per line) and 2-space hanging indents.
  4. Recalculate `<TEXTAREA>` headers:
     * If total lines $\le 14$: `visible="N"` and `scrollbar="false"`.
     * If total lines $> 14$: `visible="14"` and `scrollbar="true"`.
* Dangling prepositions or orphaned single words at line ends (e.g., `video.`, `at`) are strictly prohibited.

### 4. POSIX 0755 BINARY PERMISSION INJECTION IN TAR.GZ ON WINDOWS
* The PSBBN update package `bnupdate.tar.gz` must contain the binary `./opt0/bn/bin/bn` with executable POSIX permissions (`-rwxr-xr-x` / octal `0755`).
* Native Windows `tar.exe` does not preserve POSIX executable bits, resulting in permission `0644` and causing `Permission Denied (errno 13)` on the PS2 console.
* Agents MUST utilize native PowerShell binary header patching:
  1. Extract or create the uncompressed `.tar` archive.
  2. Scan 512-byte tar record headers for the `./opt0/bn/bin/bn` entry.
  3. Overwrite the octal mode field (bytes 100â€“107) with `0000755\0`.
  4. Clear the checksum field (bytes 148â€“155) with ASCII spaces (`0x20`).
  5. Calculate the unsigned 8-byte sum of all 512 header bytes.
  6. Write the recalculated checksum back into bytes 148â€“155 as a 6-digit octal string followed by a null and space.
  7. Compress to `.tar.gz` using .NET `System.IO.Compression.GZipStream`.

### 5. MARKDOWN TOKEN SHIELDING & FINAL SAFETY SWEEP
* When processing Markdown documentation (`README.md`), agents MUST shield formatting before calling translation APIs:
  * Inline code (`` `code` ``) $\rightarrow$ `XYZICODE_{n}_XYZ` (stored directly in memory to keep casing and content 100% identical)
  * Markdown links (`[text](url)`) $\rightarrow$ `[text](https://u{n}.link)`
  * Raw URLs $\rightarrow$ `https://r{n}.link`
  * HTML tags $\rightarrow$ `XYZHTMLTAG_{n}_XYZ` (restored via strictly bounded regexes)
* Restoration regexes MUST tolerate translation engine space-padding (e.g., `XYZICODE _ 0 _ XYZ`).
* A mandatory **Final Safety Sweep** must run across 100% of translated lines before writing to disk to guarantee 0 unrestored `XYZ_` tokens.

### 6. STRICT CODE BLOCK & FENCE ISOLATION (ZERO TRANSLATION OF CODE)
* Lines inside Markdown code fences (``` or ~~~) represent executable shell commands, bash scripts, and system paths (e.g., `cd PSBBN-Definitive-Project`, `sudo apt update`, `./PSBBN-Definitive-Patch.sh`).
* Agents MUST maintain `$inCodeFence` state tracking: all lines within code fences MUST remain 100% untouched and raw in English. Translating shell commands (such as `cd PSBBN-Depinitibo-Proyekto`) breaks installation workflows and is strictly forbidden.

### 7. MULTILINGUAL HEADING CONTEXTUALIZATION & FALSE-COGNATE IMMUNITY
* Google Translate frequently confuses the English word "Main" with the Malay/Austronesian word "main" (which translates to "play"). As a result, `## Main Menu` was previously corrupted to `## Play Menu`.
* Agents MUST shield `Main Menu` prior to translation and apply contextual dictionary mappings:
  * Filipino/Tagalog: `## Pangunahing Menu` (never `## Play Menu`)
  * Portuguese (BR & PT): `## Menu Principal`
  * Spanish: `## MenÃº Principal`
  * French: `## Menu Principal`
  * German: `## HauptmenÃ¼`
  * Italian: `## Menu Principale`
  * Russian: `## Ð“Ð»Ð°Ð²Ð½Ð¾Ðµ Ð¼ÐµÐ½ÑŽ`
  * Japanese: `## ãƒ¡ã‚¤ãƒ³ãƒ¡ãƒ‹ãƒ¥ãƒ¼`

### 8. ANCHOR & CROSS-REFERENCE SYNCHRONIZATION
* Markdown heading anchors (`#slug`) generated on GitHub depend strictly on lowercase ASCII hyphens. When headers are localized, internal document links (`[Game Collection](#game-collection)`) must match localized header slugs or remain aligned with the target language table of contents.
* Agents must ensure all internal cross-reference anchor links resolve without broken dead links.

### 9. SCRIPT PSBBN STRICT LINE LENGTH LIMITS ($\le 104$ CHARACTERS)
* The Linux installer UI terminal renders menu dialogs with a strict physical screen buffer width of 104 characters. Any string exceeding 104 characters causes text to wrap and corrupts the terminal interface.
* Agents modifying or running `Script PSBBN` must pass all translated strings through `Fit-ScriptLineLength $str 104`, applying intelligent hyphenation and whitespace reflow.

### 10. LAUNCHER WINDOWS AUTONOMOUS REAL-TIME NEW-KEY EXPANSION
* `Launcher_Windows/` must be capable of running fully stand-alone. When the upstream PowerShell launcher script adds new strings, `Translate-Launcher-Windows.ps1` must autonomously detect missing keys, translate them on the fly across all 40 languages, and append them without corrupting existing localized dictionary blocks.

### 11. AUTOMATIC LATEST OFFICIAL GITHUB RELEASE FETCHING
* Before translation begins, each module must connect to the upstream official repositories (`CosmicScale/PSBBN-Definitive-Project` / `CosmicScale/PSBBN-Definitive-English-Patch`) and fetch the latest official file revisions (`README.md`, `PSBBN-Launcher-For-Windows.ps1`, `eng.txt`, etc.).
* If an internet failure occurs, the suite gracefully falls back to the existing local copy in `input/`.

### 12. CLEAN SINGLE-FILE GENERATION (PT-BR vs PT-PT STRICT ISOLATION)
* Localizing for Portuguese (Brazil) generates exclusively `README-PT-BR.md`.
* Localizing for Portuguese (Portugal) generates exclusively `README-PT-PT.md`.
* No duplicate legacy names (`README-POR.md`, `README-PTT.md`) are created. European Portuguese vocabulary differences (`ficheiros`, `aplicaÃ§Ãµes`, `ecrÃ£`) are applied strictly to `PT-PT`.

### 13. AUTOMATIC TEMPORARY CACHE CLEANUP & MASTER DICTIONARY PRESERVATION
* Upon completion of translation batches, temporary work caches (`cache_*.json`) are deleted automatically.
* Master databases like `Launcher_Windows/data/launcher_text_40langs.json` are permanently preserved and safeguarded against accidental deletion.

### 14. SEPARATE INDIVIDUAL SUBFOLDER IN LAUNCHER WINDOWS
* The `individual/` subfolder inside `Launcher_Windows/output/individual/` generates isolated single-language script blocks (`01_ara.txt`, `25_por.txt`, etc.). This structure is mandatory for upstream PR contribution and review by CosmicScale.

### 15. SELECTIVE DISPLAY OF INPUT PURGE PROMPTS ([X] / [V])
* The prompts `[X] Excluir arquivo da pasta input | [V] Manter arquivo da pasta input` must appear ONLY when new files have been downloaded and translated.
* When navigating the UI language selection menu (`[L]`), input deletion prompts are completely suppressed.

### 16. BALANCED TWO-LINE TEXTURE DISCLAIMER
* The texture disclaimer warning users that `.tm2` / `.png` files require manual image editing must be formatted into two clean, balanced sentences ($\le 84$ characters per line) and centered in DarkYellow.

### 17. 40-LANGUAGE NATIVE CONFIRMATION MATRIX (LangAppliedSuccess)
* The UI language confirmation banner displayed upon switching languages must use native translations for all 40 languages in `$Global:UI_Translations40`. Agents must never fall back to English when a language is selected.

### 18. UNIVERSAL XML ATTRIBUTE QUOTE NORMALIZATION & ELISION APOSTROPHE IMMUNITY
* In PS2 XML files, attributes can be written with single quotes (`value='...'`) or double quotes (`value="..."`).
* In Romance languages (Italian, French, Catalan) and English contractions, words naturally contain apostrophes and elisions (*d'accordo*, *l'avvio*, *dell'unitÃ *, *c'Ã¨*, *l'album*, *d'autenticazione*, *l'Ã©laboration*, *don't*).
* If an attribute enclosed in single quotes contains an unescaped apostrophe (`value='D'accordo'`), the XML parser treats 'D' as the attribute value and throws `XmlException: "'accordo' is an unexpected token. Expecting white space"`.
* **Rule:** All XML attributes MUST be normalized to standard double quotes (`name="..."`) during pre-repair (`Repair-PsbbnXml` Rule 4) and during regex translation replacements (`label=`, `value=`, `cross=`, etc.).
* Inside double-quoted attributes, any double quotes are escaped as `&quot;`, angle brackets `<` as `&lt;`, and ampersands as `&amp;`, while apostrophes (`'`) remain 100% valid native characters without requiring premature attribute termination or entity bloat.

### 19. PLAYSTATION CONTROLLER BUTTONS & DEVELOPER NAME (CosmicScale) PROTECTION
* **Developer Name Protection (`CosmicScale`):** `CosmicScale` (and `Cosmic Scale`) is the pseudonym of the developer who reverse-engineered, modded, and assembled the PSBBN Definitive Project. It MUST NEVER be translated into any language (preventing translation engine corruptions such as "Escala CÃ³smica", "Kosmische Skala", "Ã‰chelle Cosmique", "Scala Cosmica", etc.).
* **PlayStation Controller Buttons (`START` & `SELECT`):** Physical Sony PlayStation 2 controllers have `START` and `SELECT` stamped in English on hardware across all regions worldwide. In localized texts, buttons MUST NEVER be translated into Spanish (`INICIO`, `SELECCIONAR`), Portuguese (`INICIAR`, `SELECIONAR`), French (`DÃ‰MARRER`, `SÃ‰LECTIONNER`), German, Italian, etc.
* **Intelligent Differentiation (Buttons vs Natural Verbs/Menus):** Natural English verbs and phrases (`Select which titles appear...` -> `Selecione quais tÃ­tulos...`, `To start a graphical interface...` -> `Para iniciar uma interface grÃ¡fica...`, `Start menu` -> `menu Iniciar` / `menÃº Inicio`, `Start Mode` -> `Modo de InicializaÃ§Ã£o`) must translate naturally. All-caps matching (`-creplace '\bSTART\b'`, `-creplace '\bSELECT\b'`) protects button tokens while permitting lowercase/Title Case verbs to localize smoothly, fortified by post-translation regex sweeps for button combinations (`SELECT + START`, `L1 + ... + START`) and button qualifiers (`botÃ³n START`, `botÃ£o SELECT`).
* **Inline Code (`XYZICODE`) & Pure HTML Spacers:** Inline backticks (`` `filename.py` ``) must be tokenized into memory without HTML tags (`<code>` / `<cÃ³digo>`), ensuring code contents and casing are 100% preserved. Pure HTML spacer lines (`<p></p>`, `<div></div>`) must be skipped before translation to prevent token corruption and regex greed bugs.

---

## 3. Official Terminology Standards (40-Language Matrix)

Every localized file must adhere to standard PlayStation 2 terminology and protected brand names:

| English Original | Protected / Mandatory Behavior | Forbidden Literal Mistakes |
| :--- | :--- | :--- |
| **PSBBN Definitive Project** | Preserved across all 40 languages | *Projeto Definitivo PSBBN*, *Depinitibo Proyekto* |
| **PSBBN Launcher for Windows** | Preserved across all 40 languages | *PSBBN Launcher para Windows* |
| **CosmicScale** | Preserved untranslated across all 40 languages | *Escala CÃ³smica*, *Kosmische Skala*, *Ã‰chelle Cosmique* |
| **START (Controller Button)** | Preserved in English on button combos / controls | *INICIO*, *COMENZAR*, *INICIAR*, *DÃ‰MARRER* |
| **SELECT (Controller Button)** | Preserved in English on button combos / controls | *SELECCIONAR*, *SELECIONAR*, *SÃ‰LECTIONNER* |
| **Open PS2 Loader (OPL)** | Keep untranslated across all languages | *Buksan ang PS2 Loader*, *Abrir PS2 Loader* |
| **APA-Jail** | Keep untranslated across all languages | *Kulungan ng APA*, *CÃ¡rcel APA*, *PrisÃ£o APA* |
| **Save Application System** | Standardized gaming phrase | *I-save ang Application System*, *Salvar Sistema de Aplicativo* |
| **In-Game Reset (IGR)** | Standardized PS2 technical term | Literal translations of "reset inside game" |
| **Virtual Memory Cards (VMC)** | PS2 Community standard | *Virtual Memory Card* / *CartÃ£o de MemÃ³ria Virtual* |
| **MAIN POWER** | PS2 hardware rear switch | Literal translations of "power" as strength |
| **ON/STANDBY/RESET** | PS2 hardware front button | *NAKA-ON/STANDBY/I-RESET*, *LIGAR/ESPERA/REINICIAR* |
| **Main Menu** | Contextual mapping (`Pangunahing Menu`, `Menu Principal`) | *Play Menu*, *Menu Play* |
| **Enable / Disable (PT)** | Strictly standardized to *Ative / Desative* | *Habilite / Desabilite*, *Habilitado* |

---

## 4. Verification & Testing Workflow

Before submitting or tagging any release, run the automated verification suite:

```powershell
# 1. Verify AST syntax errors across all 7 scripts (must report 0 errors)
Get-ChildItem -Path . -Recurse -Filter "*.ps1" | ForEach-Object {
    $errs = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$errs) | Out-Null
    [PSCustomObject]@{ File = $_.Name; Errors = $errs.Count }
}

# 2. Verify UTF-8 BOM presence on all .ps1 and .md files
Get-ChildItem -Path . -Recurse -Include "*.ps1","*.md" | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    if (-not $hasBom) { Write-Warning "$($_.Name) is missing UTF-8 BOM!" }
}

# 3. Test execution of batch script and master CLI
.\PSBBN-Translator.bat
```