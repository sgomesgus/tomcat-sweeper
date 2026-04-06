@echo off

setlocal EnableDelayedExpansion



:: ========================================================

::   PARAMETROS DE CONFIGURACAO

:: ========================================================

:: Substitua pelos caminhos do seu ambiente

set "BASE_DIR=C:\Caminho\Para\O\Diretorio"

set "LOG_DIR=C:\Caminho\Para\O\Diretorio\logs_script"

set "PORTAS=8080 8081 8082 8083"



:: Prefixo do servico no Windows Services

set "SERVICE_PREFIX=Apache Tomcat9 -"



:: Configuracao de Diretorio de Logs e Carimbo de Data

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"

set "DATA_HOJE=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%"

set "ARQUIVO_LOG=%LOG_DIR%\limpeza_%DATA_HOJE%.log"



:: Redirecionamento de saida padrao e erro para o arquivo de log

call :RotinaPrincipal >> "%ARQUIVO_LOG%" 2>&1

goto :eof



:: ========================================================

::   ROTINA PRINCIPAL DE EXECUCAO

:: ========================================================

:RotinaPrincipal

echo.

echo ========================================================

echo   REGISTRO DE MANUTENCAO AUTOMATIZADA

echo   DATA/HORA INICIO: %DATE% as %TIME%

echo ========================================================



for %%p in (%PORTAS%) do (

    call :ProcessarPorta %%p

)



echo.

echo ========================================================

echo   EXECUCAO CONCLUIDA: %DATE% as %TIME%

echo ========================================================

goto :eof



:: ========================================================

::   MODULO: PROCESSAMENTO POR PORTA

:: ========================================================

:ProcessarPorta

set "PORTA=%~1"

set "NOME_EXIBICAO=%SERVICE_PREFIX% %PORTA%"

set "PASTA_ALVO=%BASE_DIR%\Tomcat9%PORTA%"



:: Definicao de arquivos temporarios para tratamento de dados

set "FILE_RAW=%TEMP%\ns_%PORTA%_raw.txt"

set "FILE_PID=%TEMP%\ns_%PORTA%_pid.txt"



echo.

echo --------------------------------------------------------

echo  INICIANDO PROCESSO - PORTA: %PORTA%

echo --------------------------------------------------------



:: --- ETAPA 1: IDENTIFICACAO E ENCERRAMENTO DE PROCESSO ---

echo  [ETAPA 1] Verificacao de servico/processo ativo na porta %PORTA%...



:: Captura estado atual das portas

netstat -aon > "%FILE_RAW%"



:: Filtragem de dados: Porta especifica e status LISTENING

findstr /C:":%PORTA% " "%FILE_RAW%" > "%FILE_PID%" 2>nul

findstr "LISTENING" "%FILE_PID%" > "%FILE_RAW%" 2>nul



:: Leitura do arquivo processado para extracao do PID

set "PID_ENCONTRADO=0"

if exist "%FILE_RAW%" (

    for /f "tokens=5" %%a in (%FILE_RAW%) do (

        set "PID_ENCONTRADO=%%a"

    )

)



:: Validacao e execucao do encerramento forçado

if "!PID_ENCONTRADO!" neq "0" (

    echo     - PID Identificado: !PID_ENCONTRADO!

    echo     - Executando encerramento forçado do processo...

    taskkill /F /PID !PID_ENCONTRADO! >nul 2>&1

    echo       Processo encerrado com sucesso.

) else (

    echo     - Nenhum processo ativo detectado na porta %PORTA%.

)



:: Remocao de arquivos temporarios

if exist "%FILE_RAW%" del "%FILE_RAW%"

if exist "%FILE_PID%" del "%FILE_PID%"



:: --- INTERVALO DE SEGURANÇA ---

echo  [SISTEMA] Aguardando liberacao de recursos (3s)...

timeout /t 3 /nobreak >nul



:: --- ETAPA 2: LIMPEZA DE DIRETORIOS ---

echo  [ETAPA 2] Executando limpeza de diretorios em: %PASTA_ALVO%



if exist "%PASTA_ALVO%" (

    call :LimparPasta "%PASTA_ALVO%\logs"

    call :LimparPasta "%PASTA_ALVO%\work"

    call :LimparPasta "%PASTA_ALVO%\temp"

) else (

    echo     [ERRO CRITICO] Diretorio raiz nao localizado: %PASTA_ALVO%

)



:: --- ETAPA 3: INICIALIZACAO DO SERVICO ---

echo  [ETAPA 3] Inicializando servico: "%NOME_EXIBICAO%"...

net start "%NOME_EXIBICAO%"



:: Intervalo de estabilizacao antes da proxima iteracao

timeout /t 5 /nobreak >nul



goto :eof



:: ========================================================

::   FUNCAO AUXILIAR: LIMPEZA RECURSIVA

:: ========================================================

:LimparPasta

set "DIR_LIMPEZA=%~1"



:: Verificacao de existencia antes da exclusao

if exist "%DIR_LIMPEZA%" (

    echo     - Limpando diretorio: %DIR_LIMPEZA%

    pushd "%DIR_LIMPEZA%" 2>nul

    del /F /Q *.* >nul 2>&1

    for /D %%d in (*) do (

        rmdir /S /Q "%%d" >nul 2>&1

    )

    popd

)

goto :eof
