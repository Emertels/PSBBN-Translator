# AGENTS.md â€” Diretrizes para Agentes AutÃ´nomos de IA na SuÃ­te de TraduÃ§Ã£o MultilÃ­ngue do PSBBN

Este documento define padrÃµes arquiteturais, diretrizes tÃ©cnicas e regras operacionais de seguranÃ§a para agentes de IA autÃ´nomos (como Google Antigravity, Claude Code, Cursor e Codex) que modificam, executam ou estendem a **SuÃ­te de TraduÃ§Ã£o MultilÃ­ngue do PSBBN**.

---

## 1. VisÃ£o Geral do Projeto e Arquitetura

* **AplicaÃ§Ã£o Alvo:** PlayStation 2 â€” Broadband Navigator (PSBBN Definitive Project por CosmicScale).
* **Desenvolvedor:** **Emerson Teles**.
* **Projeto Alvo e Modder do PSBBN:** **CosmicScale** (criador e mantenedor do PSBBN Definitive Project, responsÃ¡vel por montar, moddar e aprimorar o SO PSBBN).
* **FunÃ§Ã£o do RepositÃ³rio:** SuÃ­te automatizada completa de localizaÃ§Ã£o, traduÃ§Ã£o, validaÃ§Ã£o e empacotamento multilÃ­ngue desenvolvida por **Emerson Teles** especificamente para o projeto do **CosmicScale**, com suporte a 40 idiomas em 6 mÃ³dulos de sistema.

### Os 6 MÃ³dulos do Sistema:
1. **System PSBBN (`System PSBBN/`):** Traduz todos os arquivos centrais do SO do PS2: diÃ¡logos XML, guias do usuÃ¡rio (`opt0/bn/script/guide/`), ajuda HTML do navegador ATOK/NetFront e itens de menu do `sysconf.xml`. Gera o pacote de distribuiÃ§Ã£o `bnupdate.tar.gz`.
2. **Script PSBBN (`Script PSBBN/`):** Traduz as 458 strings em `eng.txt` utilizadas pela interface do instalador Linux/WSL. Aplica limite rigoroso de caracteres no terminal ($\le 104$ caracteres).
3. **Launcher Windows (`Launcher_Windows/`):** Gera e mantÃ©m as configuraÃ§Ãµes de interface multilÃ­ngue e detecÃ§Ã£o automÃ¡tica de localidade para o instalador do Windows em todos os 40 idiomas, com expansÃ£o dinÃ¢mica de chaves em tempo real.
4. **Changelog Main (`Changelog_Main/`):** Localiza as notas de lanÃ§amento e histÃ³rico de versÃµes do instalador.
5. **Changelog Patch (`Changelog_Patch/`):** Localiza os histÃ³ricos de atualizaÃ§Ã£o de canais e patches incrementais.
6. **Readme (`Readme/`):** Localiza a documentaÃ§Ã£o tÃ©cnica (`README.md`), preservando sintaxe markdown, blocos de comandos, badges, Ã¢ncoras e URLs externas.

---

## 2. Invariantes CrÃ­ticas de SeguranÃ§a (REGRAS OBRIGATÃ“RIAS)

Agentes autÃ´nomos que operam neste repositÃ³rio DEVEM respeitar rigorosamente as 19 invariantes a seguir:

### 1. ARQUITETURA DUAL DE CODIFICAÃ‡ÃƒO: PS2 XML (SEM BOM) vs POWERSHELL PS1 (COM BOM)
* **Arquivos XML do PS2 (`.xml`, `.html`):** O parser C/C++ do PlayStation 2 exige `<?xml` exatamente no byte 0. Qualquer Byte Order Mark (BOM) faz o kernel do console travar ou entrar em loop infinito. Arquivos XML do sistema DEVEM SEMPRE ser salvos sem BOM:
  ```powershell
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($targetPath, $content, $utf8NoBom)
  ```
* **Scripts Windows PowerShell (`.ps1`) e Markdown (`.md`):** O Windows PowerShell 5.1 interpreta scripts sem BOM como ANSI/Windows-1252. Em scripts que contÃªm dicionÃ¡rios multilÃ­ngues (tagalo, Ã¡rabe, russo, japonÃªs, etc.), a ausÃªncia de BOM corrompe strings e causa centenas de erros de sintaxe no AST. Todos os arquivos `.ps1` e `.md` DEVEM SEMPRE ser salvos em UTF-8 **COM BOM**:
  ```powershell
  $utf8Bom = New-Object System.Text.UTF8Encoding($true)
  [System.IO.File]::WriteAllText($scriptPath, $content, $utf8Bom)
  ```

### 2. REPARO DIRECIONADO DE XML E INTEGRIDADE DE ATRIBUTOS
* Pacotes upstream possuem falhas conhecidas de sintaxe em arquivos especÃ­ficos (ex: aspas literais nÃ£o escapadas em `error.xml:13`: `value="...from "Check/Change"..."`).
* Os agentes NUNCA devem rodar regex genÃ©ricos que substituam aspas globais dentro de tags, pois isso destrÃ³i atributos XML vÃ¡lidos (como `subgroup="info_item"`).
* Os reparos devem ser cirÃºrgicos e direcionados:
  ```powershell
  $line = $line -replace 'value="([^"]*?)"Check/Change"([^"]*?)"', 'value="$1&quot;Check/Change&quot;$2"'
  ```
* Assegurar entidades XML vÃ¡lidas: `&amp;`, `&lt;`, `&gt;`, `&quot;` e `&apos;`.

### 3. RECONSTRUÃ‡ÃƒO DE TEXTAREA EM GUIAS DO USUÃRIO E QUEBRA BALANCEADA
* Nos arquivos XML de guias do usuÃ¡rio (`opt0/bn/script/guide/*.xml`), o texto dentro de `<TEXTAREA>` frequentemente estÃ¡ dividido no meio de frases entre vÃ¡rias tags `<LINE>`.
* Traduzir linhas individuais gera frases sem sentido. Os agentes DEVEM:
  1. Concatenar tags `<LINE>` quebradas em parÃ¡grafos completos.
  2. Traduzir o parÃ¡grafo contÃ­nuo.
  3. Reformatar o texto traduzido com quebra de linha balanceada ($\le 52$ caracteres por linha) e indentaÃ§Ã£o de 2 espaÃ§os.
  4. Recalcular cabeÃ§alhos de `<TEXTAREA>`:
     * Se total de linhas $\le 14$: `visible="N"` e `scrollbar="false"`.
     * Se total de linhas $> 14$: `visible="14"` e `scrollbar="true"`.
* Ã‰ expressamente proibido deixar preposiÃ§Ãµes isoladas ou palavras Ã³rfÃ£s no final de linhas.

### 4. INJEÃ‡ÃƒO DE PERMISSÃƒO BINÃRIA POSIX 0755 EM TAR.GZ NO WINDOWS
* O pacote de atualizaÃ§Ã£o `bnupdate.tar.gz` deve conter o binÃ¡rio `./opt0/bn/bin/bn` com permissÃ£o de execuÃ§Ã£o POSIX (`-rwxr-xr-x` / octal `0755`).
* O `tar.exe` nativo do Windows nÃ£o preserva bits executÃ¡veis POSIX, gravando `0644` e gerando erro `Permission Denied (errno 13)` no console PS2.
* Os agentes DEVEM aplicar o patch binÃ¡rio no cabeÃ§alho do arquivo tar via PowerShell nativo:
  1. Extrair ou criar o `.tar` descompactado.
  2. Varrer blocos de 512 bytes procurando o cabeÃ§alho do registro `./opt0/bn/bin/bn`.
  3. Sobrescrever o campo de modo octal (bytes 100â€“107) com `0000755\0`.
  4. Limpar o campo de checksum (bytes 148â€“155) preenchendo com espaÃ§os ASCII (`0x20`).
  5. Calcular a soma nÃ£o assinada de 8 bytes de todos os 512 bytes do cabeÃ§alho.
  6. Gravar o checksum recalculado em bytes 148â€“155 como octal de 6 dÃ­gitos seguido de null e espaÃ§o.
  7. Comprimir para `.tar.gz` utilizando .NET `System.IO.Compression.GZipStream`.

### 5. BLINDAGEM DE TOKENS MARKDOWN E VARREDURA FINAL DE SEGURANÃ‡A
* Ao processar documentaÃ§Ã£o Markdown (`README.md`), os agentes DEVEM proteger a formataÃ§Ã£o antes de chamar APIs de traduÃ§Ã£o:
  * CÃ³digo inline (`` `code` ``) $\rightarrow$ `XYZICODE_{n}_XYZ` (armazenado diretamente em memÃ³ria para manter o texto 100% idÃªntico)
  * Links Markdown (`[texto](url)`) $\rightarrow$ `[texto](https://u{n}.link)`
  * URLs brutas $\rightarrow$ `https://r{n}.link`
  * Tags HTML $\rightarrow$ `XYZHTMLTAG_{n}_XYZ` (restauradas por regex estritamente delimitados)
* ExpressÃµes de restauraÃ§Ã£o DEVEM tolerar espaÃ§amento inserido pelos tradutores (ex: `XYZICODE _ 0 _ XYZ`).
* Uma **Varredura Final de SeguranÃ§a** obrigatÃ³ria deve ser executada em 100% das linhas traduzidas para garantir 0 tokens `XYZ_` restantes.

### 6. ISOLAMENTO ABSOLUTO DE BLOCOS DE CÃ“DIGO (NENHUMA TRADUÃ‡ÃƒO DE COMANDOS)
* Linhas dentro de cercas de cÃ³digo (``` ou ~~~) representam comandos de terminal, scripts bash e caminhos do sistema (ex: `cd PSBBN-Definitive-Project`, `sudo apt update`, `./PSBBN-Definitive-Patch.sh`).
* Os agentes DEVEM manter controle de estado `$inCodeFence`: todas as linhas dentro de blocos de cÃ³digo DEVEM permanecer 100% intocadas em inglÃªs. Traduzir comandos bash quebra os scripts de instalaÃ§Ã£o e Ã© estritamente proibido.

### 7. CONTEXTUALIZAÃ‡ÃƒO DE CABEÃ‡ALHOS E IMUNIDADE A FALSOS COGNATOS
* O Google Tradutor confunde frequentemente a palavra inglesa "Main" com a palavra malaia/austronÃ©sia "main" (que significa "jogar"). Em versÃµes antigas, `## Main Menu` foi corrompido para `## Play Menu`.
* Os agentes DEVEM blindar `Main Menu` e aplicar mapeamentos contextuais de dicionÃ¡rio:
  * Filipino/Tagalo: `## Pangunahing Menu` (nunca `## Play Menu`)
  * PortuguÃªs (BR e PT): `## Menu Principal`
  * Espanhol: `## MenÃº Principal`
  * FrancÃªs: `## Menu Principal`
  * AlemÃ£o: `## HauptmenÃ¼`
  * Italiano: `## Menu Principale`
  * Russo: `## Ð“Ð»Ð°Ð²Ð½Ð¾Ðµ Ð¼ÐµÐ½ÑŽ`
  * JaponÃªs: `## ãƒ¡ã‚¤ãƒ³ãƒ¡ãƒ‹ãƒ¥ãƒ¼`

### 8. SINCRONIZAÃ‡ÃƒO DE Ã‚NCORAS E REFERÃŠNCIAS CRUZADAS
* Ã‚ncoras de cabeÃ§alhos no Markdown (`#slug`) dependem de hÃ­fens ASCII minÃºsculos no GitHub. Ao localizar tÃ­tulos, referÃªncias internas (`[ColeÃ§Ã£o de Jogos](#game-collection)`) devem sincronizar perfeitamente com o sumÃ¡rio.
* Os agentes devem garantir que todos os links internos de Ã¢ncora funcionem sem links quebrados.

### 9. LIMITES RIGOROSOS DE LINHA NO SCRIPT PSBBN ($\le 104$ CARACTERES)
* O terminal do instalador Linux renderiza diÃ¡logos com largura de tela de 104 caracteres. Linhas com mais de 104 caracteres quebram e corrompem o menu do instalador.
* Agentes que modificam ou executam o `Script PSBBN` devem passar todas as strings traduzidas por `Fit-ScriptLineLength $str 104`, aplicando hifenizaÃ§Ã£o inteligente e quebra de espaÃ§os.

### 10. EXPANSÃƒO DINÃ‚MICA AUTÃ”NOMA NO LAUNCHER WINDOWS
* O `Launcher_Windows/` deve ser capaz de operar de forma autÃ´noma. Caso o script upstream adicione novas strings, o `Translate-Launcher-Windows.ps1` detecta automaticamente as chaves ausentes, traduz dinamicamente em tempo real para os 40 idiomas e integra ao arquivo final sem corromper blocos existentes.

### 11. DOWNLOAD AUTOMÃTICO DA VERSÃƒO OFICIAL MAIS RECENTE DO GITHUB
* Antes de iniciar a traduÃ§Ã£o, cada mÃ³dulo conecta-se aos repositÃ³rios oficiais (`CosmicScale/PSBBN-Definitive-Project` / `CosmicScale/PSBBN-Definitive-English-Patch`) e baixa os arquivos fonte mais recentes.
* Em caso de falha de conexÃ£o, utiliza o arquivo local existente como fallback seguro.

### 12. GERAÃ‡ÃƒO LIMPA DE ARQUIVO ÃšNICO E SEPARAÃ‡ÃƒO ESTRITA (PT-BR vs PT-PT)
* Traduzir para PortuguÃªs (Brasil) gera exclusivamente `README-PT-BR.md`.
* Traduzir para PortuguÃªs (Portugal) gera exclusivamente `README-PT-PT.md`.
* Nomes antigos legados (`README-POR.md`, `README-PTT.md`) foram completamente eliminados. VocabulÃ¡rio especÃ­fico europeu (`ficheiros`, `aplicaÃ§Ãµes`, `ecrÃ£`) Ã© aplicado estritamente ao `PT-PT`.

### 13. LIMPEZA AUTOMÃTICA DE CACHE TEMPORÃRIO E PRESERVAÃ‡ÃƒO DO BANCO MESTRE
* Ao concluir a traduÃ§Ã£o de lotes, os arquivos de cache de trabalho (`cache_*.json`) sÃ£o excluÃ­dos automaticamente.
* Bancos de dados permanentes como `Launcher_Windows/data/launcher_text_40langs.json` sÃ£o preservados de forma rigorosa e protegidos contra exclusÃ£o.

### 14. PASTA INDIVIDUAL SEPARADA NO LAUNCHER WINDOWS
* A subpasta `individual/` dentro de `Launcher_Windows/output/individual/` gera blocos de scripts isolados por idioma (`01_ara.txt`, `25_por.txt`, etc.). Essa organizaÃ§Ã£o Ã© mandatÃ³ria para integraÃ§Ã£o e revisÃ£o manual pelo CosmicScale.

### 15. EXIBIÃ‡ÃƒO SELETIVA DE OPÃ‡Ã•ES DE EXCLUSÃƒO DA PASTA INPUT ([X] / [V])
* Os avisos `[X] Excluir arquivo da pasta input | [V] Manter arquivo da pasta input` devem aparecer estritamente quando novos arquivos foram baixados e traduzidos.
* Ao navegar no seletor de idioma (`[L]`), essas opÃ§Ãµes sÃ£o totalmente omitidas.

### 16. AVISO DE TEXTURAS BALANCEADO EM DUAS LINHAS
* O aviso de texturas alertando que arquivos `.tm2` / `.png` requerem ediÃ§Ã£o manual de imagem deve ser exibido em 2 linhas balanceadas ($\le 84$ caracteres por linha) e centralizado na cor DarkYellow.

### 17. MATRIZ DE CONFIRMAÃ‡ÃƒO NATIVA EM 40 IDIOMAS (LangAppliedSuccess)
* A confirmaÃ§Ã£o exibida ao trocar o idioma da interface deve utilizar traduÃ§Ãµes nativas em todos os 40 idiomas contidos em `$Global:UI_Translations40`. Os agentes nunca devem recorrer ao inglÃªs quando um idioma for selecionado.

### 18. NORMALIZAÃ‡ÃƒO UNIVERSAL DE ASPAS EM ATRIBUTOS XML E IMUNIDADE A APÃ“STROFOS/ELISÃ•ES
* Em arquivos XML do PS2, atributos podem ser definidos com aspas simples (`value='...'`) ou aspas duplas (`value="..."`).
* Em idiomas romÃ¢nicos (italiano, francÃªs, catalÃ£o) e contraÃ§Ãµes em inglÃªs, palavras contÃªm naturalmente apÃ³strofos e elisÃµes (*d'accordo*, *l'avvio*, *dell'unitÃ *, *c'Ã¨*, *l'album*, *d'autenticazione*, *l'Ã©laboration*, *don't*).
* Se um atributo delimitado por aspas simples contiver um apÃ³strofo nÃ£o escapado (`value='D'accordo'`), o parser XML trata 'D' como o valor do atributo e dispara exceÃ§Ã£o: `"XmlException: 'accordo' is an unexpected token. Expecting white space"`.
* **Regra:** Todos os atributos XML DEVEM ser normalizados para aspas duplas padrÃ£o (`name="..."`) durante a etapa de prÃ©-reparo (`Repair-PsbbnXml` Regra 4) e durante as substituiÃ§Ãµes de traduÃ§Ã£o por regex (`label=`, `value=`, `cross=`, etc.).
* Dentro de atributos com aspas duplas, aspas duplas internas sÃ£o escapadas como `&quot;`, colchetes angulares `<` como `&lt;`, e e-comerciais como `&amp;`, enquanto apÃ³strofos (`'`) permanecem caracteres nativos 100% vÃ¡lidos sem necessidade de fechamento prematuro ou poluiÃ§Ã£o de entidades.

### 19. PROTEÃ‡ÃƒO DOS BOTÃ•ES DO CONTROLE PLAYSTATION E NOME DO DESENVOLVEDOR (CosmicScale)
* **ProteÃ§Ã£o do Nome do Desenvolvedor (`CosmicScale`):** `CosmicScale` (e `Cosmic Scale`) Ã© o pseudÃ´nimo do desenvolvedor e engenheiro reverso que modou, montou e mantÃ©m o PSBBN Definitive Project. Ele NUNCA deve ser traduzido em nenhum idioma (evitando corrupÃ§Ãµes automÃ¡ticas de motores de traduÃ§Ã£o como "Escala CÃ³smica", "Kosmische Skala", "Ã‰chelle Cosmique", "Scala Cosmica", etc.).
* **BotÃµes FÃ­sicos do Controle PlayStation (`START` e `SELECT`):** Os controles fÃ­sicos de PlayStation possuem `START` e `SELECT` gravados em inglÃªs no hardware em todas as regiÃµes do mundo. Em textos localizados e instruÃ§Ãµes de jogos, os botÃµes NUNCA devem ser traduzidos para o espanhol (`INICIO`, `SELECCIONAR`), portuguÃªs (`INICIAR`, `SELECIONAR`), francÃªs (`DÃ‰MARRER`, `SÃ‰LECTIONNER`), alemÃ£o, italiano, etc.
* **DiferenciaÃ§Ã£o Inteligente (BotÃ£o vs Verbos/Menus em Frases Normais):** Verbos e termos de texto natural (`Select which titles appear...` -> `Selecione quais tÃ­tulos...`, `To start a graphical interface...` -> `Para iniciar uma interface grÃ¡fica...`, `Start menu` -> `menu Iniciar` / `menÃº Inicio`, `Start Mode` -> `Modo de InicializaÃ§Ã£o`) devem ser traduzidos naturalmente. O isolamento de caixa alta (`-creplace '\bSTART\b'`, `-creplace '\bSELECT\b'`) protege os botÃµes enquanto permite a traduÃ§Ã£o fluida de verbos em minÃºsculas/TitleCase, complementado por varreduras pÃ³s-traduÃ§Ã£o para combinaÃ§Ãµes de botÃµes (`SELECT + START`, `L1 + ... + START`) e qualificadores explÃ­citos (`botÃ³n START`, `botÃ£o SELECT`).
* **CÃ³digo Inline (`XYZICODE`) e Linhas EspaÃ§adoras HTML Puras:** Crases inline (`` `script.py` ``) devem ser armazenadas em memÃ³ria sem marcaÃ§Ã£o HTML (`<code>` / `<cÃ³digo>`), garantindo preservaÃ§Ã£o literal do cÃ³digo e letras maiÃºsculas/minÃºsculas. Linhas espaÃ§adoras puramente HTML (`<p></p>`, `<div></div>`) sÃ£o ignoradas antes da traduÃ§Ã£o, prevenindo corrupÃ§Ã£o de tokens e erros de ganÃ¢ncia em expressÃµes regulares.

---

## 3. PadrÃµes TerminolÃ³gicos Oficiais (Matriz de 40 Idiomas)

Cada arquivo traduzido deve seguir a terminologia padrÃ£o do ecossistema PlayStation 2:

| Original em InglÃªs | Comportamento ObrigatÃ³rio / Protegido | Erros Literais Proibidos |
| :--- | :--- | :--- |
| **PSBBN Definitive Project** | Preservado em todos os 40 idiomas | *Projeto Definitivo PSBBN*, *Depinitibo Proyekto* |
| **PSBBN Launcher for Windows** | Preservado em todos os 40 idiomas | *PSBBN Launcher para Windows* |
| **CosmicScale** | Preservado sem traduÃ§Ã£o em todos os 40 idiomas | *Escala CÃ³smica*, *Kosmische Skala*, *Ã‰chelle Cosmique* |
| **START (BotÃ£o do Controle)** | Preservado em inglÃªs em combinaÃ§Ãµes e controles | *INICIO*, *COMENZAR*, *INICIAR*, *DÃ‰MARRER* |
| **SELECT (BotÃ£o do Controle)** | Preservado em inglÃªs em combinaÃ§Ãµes e controles | *SELECCIONAR*, *SELECIONAR*, *SÃ‰LECTIONNER* |
| **Open PS2 Loader (OPL)** | Manter sem traduÃ§Ã£o em todos os idiomas | *Buksan ang PS2 Loader*, *Abrir PS2 Loader* |
| **APA-Jail** | Manter sem traduÃ§Ã£o em todos os idiomas | *Kulungan ng APA*, *CÃ¡rcel APA*, *PrisÃ£o APA* |
| **Save Application System** | Termo tÃ©cnico do console | *I-save ang Application System*, *Salvar Sistema de Aplicativo* |
| **In-Game Reset (IGR)** | Termo tÃ©cnico padronizado do PS2 | TraduÃ§Ãµes literais de "resetar dentro do jogo" |
| **Virtual Memory Cards (VMC)** | PadrÃ£o da comunidade PS2 | *Virtual Memory Card* / *CartÃ£o de MemÃ³ria Virtual* |
| **MAIN POWER** | Interruptor traseiro fÃ­sico do PS2 | TraduÃ§Ãµes literais de "power" como forÃ§a |
| **ON/STANDBY/RESET** | BotÃ£o frontal do console PS2 | *NAKA-ON/STANDBY/I-RESET*, *LIGAR/ESPERA/REINICIAR* |
| **Main Menu** | Mapeamento contextual (`Pangunahing Menu`, `Menu Principal`) | *Play Menu*, *Menu Play* |
| **Enable / Disable (PT)** | Padronizado rigorosamente para *Ative / Desative* | *Habilite / Desabilite*, *Habilitado* |

---

## 4. Fluxo de ValidaÃ§Ã£o e Testes

Antes de enviar ou marcar qualquer versÃ£o, execute a rotina automatizada de verificaÃ§Ã£o:

```powershell
# 1. Verificar erros de sintaxe AST em todos os scripts ps1 (deve retornar 0 erros)
Get-ChildItem -Path . -Recurse -Filter "*.ps1" | ForEach-Object {
    $errs = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$errs) | Out-Null
    [PSCustomObject]@{ File = $_.Name; Errors = $errs.Count }
}

# 2. Verificar presenÃ§a do UTF-8 BOM em todos os arquivos .ps1 e .md
Get-ChildItem -Path . -Recurse -Include "*.ps1","*.md" | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    if (-not $hasBom) { Write-Warning "$($_.Name) nÃ£o possui UTF-8 BOM!" }
}

# 3. Teste de execuÃ§Ã£o do script batch e CLI mestre
.\PSBBN-Translator.bat
```