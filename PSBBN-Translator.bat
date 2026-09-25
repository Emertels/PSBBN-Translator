@echo off
:: Ativa Modo Edicao Rapida (QuickEdit) para permitir selecao e copia de texto com o mouse
reg add "HKCU\Console" /v QuickEdit /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Console" /v ExtendedEditKey /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe" /v QuickEdit /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Console\PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]" /v QuickEdit /t REG_DWORD /d 1 /f >nul 2>&1

title PSBBN Multilingual Translation Suite - V1 [By Emerson Teles]
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0PSBBN-Translator.ps1"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Ocorreu um erro ao executar a suite.
    pause
)
