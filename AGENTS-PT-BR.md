# AGENTS_PTBR.md — Diretrizes para Agentes de IA Autônomos (Suíte de Tradução Multilíngue PSBBN)

Este documento define os padrões arquiteturais, diretrizes técnicas e regras de segurança operacional para agentes de IA autônomos (como Google Antigravity, Claude Code, Cursor e Codex) que modifiquem, executem ou estendam a **Suíte de Tradução Multilíngue do PSBBN**.

---

## 1. Visão Geral do Projeto e Arquitetura

* **Aplicação Alvo:** PlayStation 2 — Broadband Navigator (PSBBN Definitive Project por CosmicScale).
* **Desenvolvedor:** **Emerson Teles**.
* **Projeto Alvo & Modificador do PSBBN:** **CosmicScale** (criador e mantenedor do PSBBN Definitive Project, responsável pela montagem, modificações e aprimoramentos do PSBBN).
* **Função do Repositório:** Suíte automatizada e completa de localização, tradução, validação e empacotamento multilíngue desenvolvida por **Emerson Teles** sob medida para o projeto do **CosmicScale**, com suporte a 40 idiomas através de 6 módulos de sistema distintos.

### Os 6 Módulos do Sistema:
1. **System PSBBN (`System PSBBN/`):** Traduz todos os arquivos fundamentais do SO do PS2: diálogos XML, manuais/guias (`opt0/bn/script/guide/`), ajuda HTML do navegador ATOK/NetFront e itens de menu do `sysconf.xml`. Gera o pacote de implantação `bnupdate.tar.gz`.
2. **Script PSBBN (`Script PSBBN/`):** Traduz as 458 strings em `eng.txt` utilizadas pela interface do instalador Linux/WSL. Aplica limite rigoroso de largura de janela de terminal ($\le 104$ caracteres).
3. **Launcher Windows (`Launcher_Windows/`):** Gera e mantém configurações de interface e detecção automática de localidade para o inicializador Windows nos 40 idiomas com suporte dinâmico a novas linhas em tempo real.
4. **Changelog Main (`Changelog_Main/`):** Traduz as notas de lançamento oficiais do instalador e o histórico de versões mestre.
5. **Changelog Patch (`Changelog_Patch/`):** Traduz os logs de patches de canais e atualizações incrementais.
6. **Readme (`Readme/`):** Traduz a documentação técnica (`README.md`) preservando rigorosamente sintaxe markdown, blocos de código, badges, âncoras e URLs externas.

---

## 2. Invariantes Críticos de Segurança (REGRAS OBRIGATÓRIAS)

Agentes autônomos que operem neste repositório DEVEM respeitar rigorosamente os seguintes 10 invariantes:

### 1. ARQUITETURA DE CODIFICAÇÃO DUPLA: XML DO PS2 (SEM BOM) vs POWERSHELL PS1 (COM BOM)
* **Arquivos XML do PS2 (`.xml`, `.html`):** O analisador XML em C/C++ do PlayStation 2 exige a sequência `<?xml` exatamente no byte 0. Qualquer Byte Order Mark (BOM) causa travamento do kernel do PS2 ou loop infinito na inicialização. Arquivos XML do sistema DEVEM SEMPRE ser gravados em UTF-8 **SEM BOM**:
  ```powershell
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($targetPath, $content, $utf8NoBom)
  ```
* **Scripts Windows PowerShell (`.ps1`) e Markdown (`.md`):** O Windows PowerShell 5.1 interpreta arquivos sem BOM na página de código legada ANSI/Windows-1252. Em scripts que contêm tabelas multilíngues (Tagalo, Árabe, Russo, Japonês, etc.), a falta de BOM corrompe strings e dispara centenas de erros de sintaxe AST. Todos os arquivos `.ps1` e `.md` DEVEM SEMPRE ser gravados em UTF-8 **COM BOM**:
  ```powershell
  $utf8Bom = New-Object System.Text.UTF8Encoding($true)
  [System.IO.File]::WriteAllText($scriptPath, $content, $utf8Bom)
  ```

### 2. REPARO CIRÚRGICO DE XML E INTEGRIDADE DE ATRIBUTOS
* Pacotes de tradução upstream contêm falhas conhecidas de sintaxe (ex: aspas duplas literais não escapadas em `error.xml:13`: `value="...from "Check/Change"..."`).
* Agentes NUNCA devem aplicar substituições regex genéricas em atributos de tags, pois isso corrompe delimitadores válidos (como `subgroup="info_item"`).
* Os reparos devem ser cirúrgicos e pontuais:
  ```powershell
  $line = $line -replace 'value="([^"]*?)"Check/Change"([^"]*?)"', 'value="$1&quot;Check/Change&quot;$2"'
  ```
* Garantir entidades XML válidas: `&amp;`, `&lt;`, `&gt;`, `&quot;` e `&apos;`.

### 3. RECONSTRUÇÃO DE PARÁGRAFOS DO GUIA E QUEBRA BALANCEADA
* Nos arquivos de guia (`opt0/bn/script/guide/*.xml`), o texto dentro de `<TEXTAREA>` frequentemente é fragmentado em várias tags `<LINE>` no meio de frases.
* Traduzir linha por linha gera aberrações gramaticais. Os agentes DEVEM:
  1. Concatenar as tags `<LINE>` fragmentadas em blocos contínuos de parágrafos.
  2. Traduzir o parágrafo completo contextualmente.
  3. Reformatar o texto traduzido com quebra balanceada ($\le 52$ caracteres por linha) e recuo suspenso de 2 espaços.
  4. Recalcular os atributos do cabeçalho `<TEXTAREA>`:
     * Se total de linhas $\le 14$: `visible="N"` e `scrollbar="false"`.
     * Se total de linhas $> 14$: `visible="14"` e `scrollbar="true"`.
* Preposições soltas ou palavras órfãs no final de linhas (`video.`, `at`) são estritamente proibidas.

### 4. INJEÇÃO DE PERMISSÃO BINÁRIA POSIX 0755 EM TAR.GZ NO WINDOWS
* O pacote de atualização do PSBBN `bnupdate.tar.gz` deve conter o binário `./opt0/bn/bin/bn` com permissões executáveis POSIX (`-rwxr-xr-x` / octal `0755`).
* O `tar.exe` nativo do Windows descarta atributos executáveis POSIX, gerando arquivos com permissão `0644` e resultando em `Permission Denied (errno 13)` no PlayStation 2.
* Agentes DEVEM utilizar a injeção binária nativa via PowerShell:
  1. Extrair ou criar o arquivo `.tar` descomprimido.
  2. Varrer os blocos de cabeçalho de 512 bytes procurando a entrada `./opt0/bn/bin/bn`.
  3. Sobrescrever o campo octal de modo (bytes 100–107) com `0000755\0`.
  4. Preencher o campo de checksum (bytes 148–155) com espaços ASCII (`0x20`).
  5. Calcular a soma de bytes não assinada de todos os 512 bytes do cabeçalho.
  6. Gravar o novo checksum em formato octal nos bytes 148–155 seguido por nulo e espaço.
  7. Comprimir para `.tar.gz` utilizando `System.IO.Compression.GZipStream` do .NET.

### 5. BLINDAGEM DE TOKENS MARKDOWN E VARREDURA FINAL DE SEGURANÇA
* Ao processar documentação Markdown (`README.md`), os agentes DEVEM blindar a formatação antes das chamadas de API:
  * Código embutido (`` `código` ``) $\rightarrow$ `XYZCODE_{n}_XYZ`
  * Links markdown (`[texto](url)`) $\rightarrow$ `[texto](XYZMDURL_{n}_XYZ)`
  * URLs brutas $\rightarrow$ `XYZRAWURL_{n}_XYZ`
  * Tags HTML $\rightarrow$ `XYZHTMLTAG_{n}_XYZ`
* As expressões de restauração DEVEM ser tolerantes a espaços adicionados pelo Google Tradutor (ex: `XYZMDURL _ 0 _ XYZ`).
* É obrigatória a execução de uma **Varredura Final de Segurança** sobre 100% das linhas traduzidas antes de salvar no disco, garantindo zero tokens `XYZ_` restantes.

### 6. ISOLAMENTO ABSOLUTO DE BLOCOS DE CÓDIGO (PROIBIDO TRADUZIR COMANDOS)
* Linhas dentro de cercas de código Markdown (``` ou ~~~) representam comandos de terminal, scripts bash e caminhos de sistema executáveis (ex: `cd PSBBN-Definitive-Project`, `sudo apt update`, `./PSBBN-Definitive-Patch.sh`).
* Os agentes DEVEM rastrear o estado `$inCodeFence`: todas as linhas dentro de blocos de código DEVEM permanecer 100% intactas em inglês puro. Traduzir comandos (como `cd PSBBN-Depinitibo-Proyekto`) quebra a execução e é rigorosamente proibido.

### 7. CONTEXTUALIZAÇÃO DE CABEÇALHOS E IMUNIDADE A FALSOS COGNATOS
* O Google Tradutor confunde com frequência a palavra inglesa "Main" com o termo malaio/austronésio "main" (que significa "jogar"). Por isso, `## Main Menu` era incorretamente traduzido como `## Play Menu`.
* Agentes DEVEM blindar `Main Menu` antes da tradução e aplicar o mapeamento contextual:
  * Filipino/Tagalo: `## Pangunahing Menu` (nunca `## Play Menu`)
  * Português (BR e PT): `## Menu Principal`
  * Espanhol: `## Menú Principal`
  * Francês: `## Menu Principal`
  * Alemão: `## Hauptmenü`
  * Russo: `## Главное меню`
  * Japonês: `## メインメニュー`
* Títulos de seções como `# Video demonstration of PSBBN` devem ser traduzidos com precisão (`# Pagpapakita ng Video ng PSBBN` no filipino, `# Demonstração em Vídeo do PSBBN` no português).

### 8. EXPANSÃO DINÂMICA EM TEMPO REAL PARA NOVAS LINHAS DO LAUNCHER
* O script do launcher para Windows (`PSBBN-Launcher-For-Windows.ps1`) é baixado dinamicamente das releases oficiais do CosmicScale.
* Quando o CosmicScale adiciona novas chaves (`prompt_22`, `warn_10`, `error_13`, etc.) em `eng = @{ ... }`, a suíte as detecta automaticamente sem limites rígidos.
* Chaves inexistentes no cache `launcher_text_40langs.json` são traduzidas em tempo real via Google Translate API com 3 camadas de fallback, sanitizadas em linha única (`Format-LauncherString` remove `\r\n` e espaços extras para garantir 0 quebras de linha) e armazenadas permanentemente no cache JSON.
* Blocos individuais de exportação (`output/individual/<idioma>.txt`) e o script principal são injetados com dicionários completos e perfeitamente formatados.

### 9. PADRONIZAÇÃO RIGOROSA DO PORTUGUÊS (PT-BR / PT-PT): ATIVAR / DESATIVAR
* A tradução em português rejeita terminantemente o jargão burocrático "habilitar / desabilitar".
* Em todos os menus de sistema, scripts de instalação, strings do launcher e documentação README:
  * `Enable` $\rightarrow$ `Ative` / `Ativar` / `Ativado` / `Ativando`
  * `Disable` $\rightarrow$ `Desative` / `Desativar` / `Desativado` / `Desativando`
* 0 ocorrências de `habilit*` ou `desabilit*` são permitidas nos arquivos gerados em português.

### 10. INTEGRIDADE SINTÁTICA AST E MONTAGEM MODULAR
* Antes de aprovar qualquer alteração, os agentes DEVEM validar que todos os scripts PowerShell possuem **0 erros no analisador sintático AST**:
  ```powershell
  $errs = $null
  [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$errs) | Out-Null
  if ($errs.Count -gt 0) { throw "Erros de sintaxe AST detectados!" }
  ```
* Na montagem do script mestre (`PSBBN-Translator.ps1`), os agentes devem evitar armadilhas de substituição regex global. A concatenação limpa de submódulos validados deve ser rigorosamente empregada.

### 11. DOWNLOAD AUTOMÁTICO DA VERSÃO OFICIAL (GITHUB UPSTREAM EM TEMPO REAL)
* Antes de executar qualquer tradução, os submódulos DEVEM contatar os repositórios oficiais do GitHub para baixar os arquivos de release mais recentes (`README.md`, `PSBBN-Launcher-For-Windows.ps1`, `eng.txt`, `changelog_main_eng.txt`, `changelog_patch_eng.txt`).
* O script deve exibir a mensagem `[i] Baixando a versão oficial mais recente do GitHub...` (localizada) e sobrescrever o arquivo de entrada local.
* O fallback para o arquivo local pré-existente só é permitido se a conexão com o GitHub ou internet falhar. Traduções nunca devem ser geradas a partir de caches locais obsoletos quando houver conectividade.

### 12. LIMPEZA AUTOMÁTICA DE CACHE TEMPORÁRIO E PRESERVAÇÃO DE DICIONÁRIO
* Ao finalizar a tradução em qualquer submódulo (`Readme`, `Script PSBBN`, `Changelog_Main`, `Changelog_Patch`, `System PSBBN`), todos os arquivos de cache de trabalho intermediários (`cache/cache_*.json`) DEVEM ser automaticamente excluídos para evitar acúmulo em disco e resíduos desatualizados.
* **EXCEÇÃO CRÍTICA:** O arquivo `Launcher_Windows/data/launcher_text_40langs.json` é um banco de dados de chaves multilíngue permanente (localizado na pasta `data/` para deixar clara sua natureza perene) e NUNCA DEVE ser excluído.

### 13. BLINDAGEM RESILIENTE DE LINKS E CÓDIGO MARKDOWN
* Motores neurais de tradução desconfiguram tokens pontuados como `XYZMDURL_0_XYZ` ou `XYZCODE_0_XYZ`, comendo colchetes ou alterando a pontuação adjacente.
* As URLs de links Markdown DEVEM ser blindadas com URLs dummy compatíveis com o padrão RFC: `[texto](https://u{n}.link)` e código embutido com `<code>...</code>`.
* Rotinas de restauração devem utilizar expressões regulares multi-pass tolerantes a variações de espaçamento, garantindo 100% de restauração com zero resíduos de tokens.

### 14. GERAÇÃO ESTRITA DE ARQUIVO ÚNICO E SEPARAÇÃO DE PORTUGUÊS (PT-BR vs PT-PT)
* Ao traduzir a documentação técnica (`README.md`), os agentes DEVEM gerar **apenas um único arquivo de saída** por idioma:
  * Português (Brasil): gera exclusivamente `README-PT-BR.md`. Nunca gerar `README-POR.md` nem arquivos duplicados.
  * Português (Portugal): gera exclusivamente `README-PT-PT.md`. Nunca gerar `README-PTT.md`.
  * Outros idiomas: geram estritamente `README-{CÓDIGO3}.md`.
* Os agentes devem aplicar regras específicas de localização para o Português de Portugal (`ficheiros` para arquivos, `aplicações` para aplicativos, `ecrã` para tela).
* Os links do cabeçalho de navegação Markdown devem diferenciar claramente `[Português (Brasil)]` e `[Português (Portugal)]`.

### 15. EXIBIÇÃO SELETIVA DE OPÇÕES DE EXCLUSÃO ([X] / [V]) E ARMADILHA DE TIPAGEM DO POWERSHELL
* As opções de gerenciamento de arquivos de entrada (`[X] Excluir arquivo da pasta input | [V] Manter arquivo da pasta input`) DEVEM aparecer APENAS quando arquivos foram de fato baixados e traduzidos (`$showInputOptions = $true`).
* Ao simplesmente trocar o idioma da interface (`Select-ScriptUILanguage`), as opções de exclusão DEVEM ser suprimidas passando `-showInputOptions $false`, renderizando apenas as teclas limpas de navegação: `[Enter] Menu Principal | [B] Tela Anterior | [Esc] Sair`.
* **ARMADILHA CRÍTICA DO POWERSHELL:** Em blocos de parâmetros do PowerShell, variáveis tipadas como string `[string]$inputDir = $null` convertem `$null` para string vazia `""`. Avaliar `$null -ne $inputDir` torna-se `$null -ne ""` que resulta em `$true`! Os agentes DEVEM SEMPRE verificar `(-not [string]::IsNullOrWhiteSpace($inputDir))` para evitar ativação indevida do valor padrão.

### 16. LAYOUT CENTRALIZADO DO CONSOLE E AVISO DE TEXTURAS BALANCEADO EM 2 LINHAS
* A interface do console da suíte é padronizada na largura de 88 colunas.
* `Sessão iniciada em: ...` deve ser centralizada diretamente abaixo do cabeçalho do título da suíte.
* O aviso de texturas (`TextureDisclaimer`) NUNCA deve ser impresso em uma única linha contínua que ultrapasse a largura do console, quebre no meio de palavras ou parta números (ex.: `1` na linha 1 e `00%` na linha 2).
* O aviso deve ser dividido dinamicamente em 2 frases balanceadas ($\le 84$ caracteres por linha) e centralizado com a cor DarkYellow.

### 17. MATRIZ DE CONFIRMAÇÃO NATIVA EM 40 IDIOMAS (LangAppliedSuccess)
* A confirmação exibida ao trocar o idioma da interface deve utilizar traduções nativas em todos os 40 idiomas contidos em `$Global:UI_Translations40`. Os agentes nunca devem recorrer ao inglês quando um idioma for selecionado.

---

## 3. Padrões Terminológicos Oficiais (Matriz de 40 Idiomas)

Cada arquivo traduzido deve seguir a terminologia padrão do ecossistema PlayStation 2:

| Original em Inglês | Comportamento Obrigatório / Protegido | Erros Literais Proibidos |
| :--- | :--- | :--- |
| **PSBBN Definitive Project** | Preservado em todos os 40 idiomas | *Projeto Definitivo PSBBN*, *Depinitibo Proyekto* |
| **PSBBN Launcher for Windows** | Preservado em todos os 40 idiomas | *PSBBN Launcher para Windows* |
| **Open PS2 Loader (OPL)** | Manter sem tradução em todos os idiomas | *Buksan ang PS2 Loader*, *Abrir PS2 Loader* |
| **APA-Jail** | Manter sem tradução em todos os idiomas | *Kulungan ng APA*, *Cárcel APA*, *Prisão APA* |
| **Save Application System** | Termo técnico do console | *I-save ang Application System*, *Salvar Sistema de Aplicativo* |
| **In-Game Reset (IGR)** | Termo técnico padronizado do PS2 | Traduções literais de "resetar dentro do jogo" |
| **Virtual Memory Cards (VMC)** | Padrão da comunidade PS2 | *Virtual Memory Card* / *Cartão de Memória Virtual* |
| **MAIN POWER** | Interruptor traseiro físico do PS2 | Traduções literais de "power" como força |
| **ON/STANDBY/RESET** | Botão frontal do console PS2 | *NAKA-ON/STANDBY/I-RESET*, *LIGAR/ESPERA/REINICIAR* |
| **Main Menu** | Mapeamento contextual (`Pangunahing Menu`, `Menu Principal`) | *Play Menu*, *Menu Play* |
| **Enable / Disable (PT)** | Padronizado rigorosamente para *Ative / Desative* | *Habilite / Desabilite*, *Habilitado* |

---

## 4. Fluxo de Validação e Testes

Antes de enviar ou marcar qualquer versão, execute a rotina automatizada de verificação:

```powershell
# 1. Verificar erros de sintaxe AST em todos os scripts ps1 (deve retornar 0 erros)
Get-ChildItem -Path . -Recurse -Filter "*.ps1" | ForEach-Object {
    $errs = $null
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$errs) | Out-Null
    [PSCustomObject]@{ File = $_.Name; Errors = $errs.Count }
}

# 2. Verificar presença de UTF-8 com BOM em todos os arquivos .ps1 e .md
Get-ChildItem -Path . -Recurse -Include "*.ps1","*.md" | ForEach-Object {
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $hasBom = ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF)
    if (-not $hasBom) { Write-Warning "$($_.Name) está sem UTF-8 BOM!" }
}

# 3. Teste de execução do script em lote e CLI mestre
.\PSBBN-Translator.bat
```
