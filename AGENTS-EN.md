# AGENTS.md — Autonomous AI Agent Guidelines for PSBBN Multilingual Translation Suite

This document defines architectural standards, technical guidelines, and operational safety rules for autonomous AI agents (such as Google Antigravity, Claude Code, Cursor, and Codex) modifying, executing, or extending the **PSBBN Multilingual Translation Suite**.

---

## 1. Project Overview & Architecture

* **Target Application:** PlayStation 2 — Broadband Navigator (PSBBN Definitive Project by CosmicScale).
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

Autonomous agents operating on this repository MUST strictly respect the following 10 invariants:

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
  3. Overwrite the octal mode field (bytes 100–107) with `0000755\0`.
  4. Clear the checksum field (bytes 148–155) with ASCII spaces (`0x20`).
  5. Calculate the unsigned 8-byte sum of all 512 header bytes.
  6. Write the recalculated checksum back into bytes 148–155 as a 6-digit octal string followed by a null and space.
  7. Compress to `.tar.gz` using .NET `System.IO.Compression.GZipStream`.

### 5. MARKDOWN TOKEN SHIELDING & FINAL SAFETY SWEEP
* When processing Markdown documentation (`README.md`), agents MUST shield formatting before calling translation APIs:
  * Inline code (`` `code` ``) $\rightarrow$ `XYZCODE_{n}_XYZ`
  * Markdown links (`[text](url)`) $\rightarrow$ `[text](XYZMDURL_{n}_XYZ)`
  * Raw URLs $\rightarrow$ `XYZRAWURL_{n}_XYZ`
  * HTML tags $\rightarrow$ `XYZHTMLTAG_{n}_XYZ`
* Restoration regexes MUST tolerate translation engine space-padding (e.g., `XYZMDURL _ 0 _ XYZ`).
* A mandatory **Final Safety Sweep** must run across 100% of translated lines before writing to disk to guarantee 0 unrestored `XYZ_` tokens.

### 6. STRICT CODE BLOCK & FENCE ISOLATION (ZERO TRANSLATION OF CODE)
* Lines inside Markdown code fences (``` or ~~~) represent executable shell commands, bash scripts, and system paths (e.g., `cd PSBBN-Definitive-Project`, `sudo apt update`, `./PSBBN-Definitive-Patch.sh`).
* Agents MUST maintain `$inCodeFence` state tracking: all lines within code fences MUST remain 100% untouched and raw in English. Translating shell commands (such as `cd PSBBN-Depinitibo-Proyekto`) breaks installation workflows and is strictly forbidden.

### 7. MULTILINGUAL HEADING CONTEXTUALIZATION & FALSE-COGNATE IMMUNITY
* Google Translate frequently confuses the English word "Main" with the Malay/Austronesian word "main" (which translates to "play"). As a result, `## Main Menu` was previously corrupted to `## Play Menu`.
* Agents MUST shield `Main Menu` prior to translation and apply contextual dictionary mappings:
  * Filipino/Tagalog: `## Pangunahing Menu` (never `## Play Menu`)
  * Portuguese (BR & PT): `## Menu Principal`
  * Spanish: `## Menú Principal`
  * French: `## Menu Principal`
  * German: `## Hauptmenü`
  * Russian: `## Главное меню`
  * Japanese: `## メインメニュー`
* Section titles such as `# Video demonstration of PSBBN` must resolve accurately (`# Pagpapakita ng Video ng PSBBN` in Filipino, `# Demonstração em Vídeo do PSBBN` in Portuguese).

### 8. DYNAMIC REAL-TIME KEY EXPANSION FOR LAUNCHER WINDOWS
* The Windows launcher script (`PSBBN-Launcher-For-Windows.ps1`) is dynamically downloaded from the official CosmicScale repository.
* When CosmicScale adds new keys (`prompt_22`, `warn_10`, `error_13`, etc.) to `eng = @{ ... }`, the suite parses them dynamically without hardcoded loops.
* Any missing keys in `launcher_text_40langs.json` are translated live via Google Translate API with 3-tier fallback, sanitized to a single line (`Format-LauncherString` collapses `\r\n` and extra spaces to guarantee 0 line breaks), and stored permanently in the cache.
* Individual block exports (`output/individual/<lang>.txt`) and the main script are injected with clean, fully translated single-line dictionaries.

### 9. STRICT PORTUGUESE (PT-BR / PT-PT) TERMINOLOGY STANDARDIZATION
* The Portuguese translation strictly rejects bureaucratic jargon "habilitar / desabilitar".
* Across all system menus, installer scripts, launcher strings, and README documentation:
  * `Enable` $\rightarrow$ `Ative` / `Ativar` / `Ativado` / `Ativando`
  * `Disable` $\rightarrow$ `Desative` / `Desativar` / `Desativado` / `Desativando`
* 0 occurrences of `habilit*` or `desabilit*` are permitted in Portuguese output files.

### 10. AST SYNTAX PARSER INTEGRITY & MODULAR ASSEMBLY
* Prior to committing any code, agents MUST validate that all 7 PowerShell scripts achieve **0 AST syntax parser errors**:
  ```powershell
  $errs = $null
  [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$errs) | Out-Null
  if ($errs.Count -gt 0) { throw "AST Syntax Errors detected!" }
  ```
* When assembling the master script (`PSBBN-Translator.ps1`), agents must avoid regex string replacement pitfalls. Clean concatenation of validated submodules must be used.

### 11. ALWAYS-FETCH UPSTREAM PATTERN (ALWAYS DOWNLOAD LATEST OFFICIAL RELEASE)
* Before executing any translation pass, submodules MUST contact the official GitHub repository to download the latest release files (`README.md`, `PSBBN-Launcher-For-Windows.ps1`, `eng.txt`, `changelog_main_eng.txt`, `changelog_patch_eng.txt`).
* Scripts must display `[i] Baixando a versão oficial mais recente do GitHub...` (localized) and overwrite the local input file.
* Offline fallback to the local input file is permitted only if GitHub/network is unreachable. Translations must never be generated from obsolete local caches when an internet connection exists.

### 12. AUTOMATIC WORKING CACHE PURGE & MASTER DICTIONARY PRESERVATION
* Upon translation completion across any submodule (`Readme`, `Script PSBBN`, `Changelog_Main`, `Changelog_Patch`, `System PSBBN`), intermediate working cache files (`cache/cache_*.json`) MUST be automatically purged to eliminate disk bloat and stale cache entries.
* **CRITICAL EXCEPTION:** `Launcher_Windows/data/launcher_text_40langs.json` is a permanent, persistent multilingual key dictionary (located in `data/` to signify permanent storage) and MUST NEVER be deleted.

### 13. RESILIENT RFC-COMPLIANT MARKDOWN URL & CODE SHIELDING
* Neural machine translation engines scramble arbitrary pseudo-word tokens such as `XYZMDURL_0_XYZ` or `XYZCODE_0_XYZ`, dropping brackets or misplacing punctuation.
* Markdown link URLs MUST be shielded with RFC-valid dummy URLs: `[link text](https://u{n}.link)` and inline code with `<code>...</code>`.
* Restoration routines must use multi-pass regexes that tolerate whitespace adjustments introduced by translation engines and ensure 100% restoration with 0 unrestored tokens remaining.

### 14. STRICT SINGLE-FILE OUTPUT & PORTUGUESE SEPARATION (PT-BR vs PT-PT)
* When translating technical documentation (`README.md`), agents MUST strictly generate **only one output file** per language:
  * Portuguese (Brazil): produces exclusively `README-PT-BR.md`. Never generate `README-POR.md` or duplicate copies.
  * Portuguese (Portugal): produces exclusively `README-PT-PT.md`. Never generate `README-PTT.md`.
  * Other languages: produce strictly `README-{CODE3}.md`.
* Agents must apply dedicated European Portuguese terminology adjustments for `pt-pt` (`ficheiros` for files, `aplicações` for apps, `ecrã` for screen).
* Markdown navigation header links must clearly differentiate `[Português (Brasil)]` and `[Português (Portugal)]`.

### 15. SELECTIVE INPUT FILE DELETION PROMPTING & POWERSHELL TYPE COERCION TRAP
* The input file management prompts (`[X] Delete file from input folder | [V] Keep file in input folder`) MUST ONLY be presented when files were actively downloaded and translated (`$showInputOptions = $true`).
* When merely changing the UI language (`Select-ScriptUILanguage`), input deletion prompts MUST be suppressed by passing `-showInputOptions $false`, rendering only clean navigation controls: `[Enter] Main Menu | [B] Previous Screen | [Esc] Exit`.
* **CRITICAL POWERSHELL TRAP:** In PowerShell parameter blocks, typed strings `[string]$inputDir = $null` coerce `$null` to `""` (empty string). Evaluating `$null -ne $inputDir` evaluates `$null -ne ""` which yields `$true`! Agents MUST ALWAYS check `(-not [string]::IsNullOrWhiteSpace($inputDir))` to avoid unintended default evaluation to `$true`.

### 16. CENTERED TERMINAL UI & BALANCED 2-LINE DISCLAIMER FORMATTING
* The suite console interface is designed around an 88-column layout.
* `Session started at: ...` must be centered directly below the main suite banner.
* The texture notice (`TextureDisclaimer`) must NEVER be printed on a single line that overflows standard terminal boundaries, wraps mid-word, or truncates numbers (e.g. `1` on line 1 and `00%` on line 2).
* The disclaimer must be dynamically formatted into two clean, balanced sentences ($\le 84$ characters per line) and centered with DarkYellow foreground color.

### 17. 40-LANGUAGE NATIVE CONFIRMATION MATRIX (LangAppliedSuccess)
* The UI language confirmation banner displayed upon switching languages must use native translations for all 40 languages in `$Global:UI_Translations40`. Agents must never fall back to English when a language is selected.


### 18. UNIVERSAL XML ATTRIBUTE QUOTE NORMALIZATION & ELISION APOSTROPHE IMMUNITY
* In PS2 XML files, attributes can be written with single quotes (alue='...') or double quotes (alue="...").
* In Romance languages (Italian, French, Catalan) and English contractions, words naturally contain apostrophes and elisions (d'accordo, l'avvio, dell'unitÃ , c'Ã¨, l'album, d'autenticazione, l'Ã©laboration, don't).
* If an attribute enclosed in single quotes contains an unescaped apostrophe (alue='D'accordo'), the XML parser treats 'D' as the attribute value and throws XmlException: "'accordo' is an unexpected token. Expecting white space".
* **Rule:** All XML attributes MUST be normalized to standard double quotes (
ame="...") during pre-repair (Repair-PsbbnXml Rule 4) and during regex translation replacements (label=, alue=, cross=, etc.).
* Inside double-quoted attributes, any double quotes are escaped as &quot;, angle brackets < as &lt;, and ampersands as &amp;, while apostrophes (') remain 100% valid native characters without requiring premature attribute termination or entity bloat.
---

## 3. Official Terminology Standards (40-Language Matrix)

Every localized file must adhere to standard PlayStation 2 terminology and protected brand names:

| English Original | Protected / Mandatory Behavior | Forbidden Literal Mistakes |
| :--- | :--- | :--- |
| **PSBBN Definitive Project** | Preserved across all 40 languages | *Projeto Definitivo PSBBN*, *Depinitibo Proyekto* |
| **PSBBN Launcher for Windows** | Preserved across all 40 languages | *PSBBN Launcher para Windows* |
| **Open PS2 Loader (OPL)** | Keep untranslated across all languages | *Buksan ang PS2 Loader*, *Abrir PS2 Loader* |
| **APA-Jail** | Keep untranslated across all languages | *Kulungan ng APA*, *Cárcel APA*, *Prisão APA* |
| **Save Application System** | Standardized gaming phrase | *I-save ang Application System*, *Salvar Sistema de Aplicativo* |
| **In-Game Reset (IGR)** | Standardized PS2 technical term | Literal translations of "reset inside game" |
| **Virtual Memory Cards (VMC)** | PS2 Community standard | *Virtual Memory Card* / *Cartão de Memória Virtual* |
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
