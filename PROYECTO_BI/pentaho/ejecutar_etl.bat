@echo off
setlocal
REM =====================================================================
REM Ejecuta el ETL completo (replica Excel -> stg + carga del modelo dwh) con Pentaho Kitchen
REM Requisitos:
REM   - PDI_HOME apuntando a la carpeta data-integration (editar abajo)
REM   - %USERPROFILE%\.kettle\kettle.properties con RUTA_ORIGEN,
REM     ARCHIVO_ORIGEN y DB_* configurados (RUTA_ORIGEN=C:/SOURCES/PROYECTO)
REM Uso: doble clic, o desde cmd. Para uso programado: agregar el
REM      argumento nopause (evita la pausa final).
REM =====================================================================

REM --- CONFIGURACION ---------------------------------------------------
if "%PDI_HOME%"=="" set "PDI_HOME=C:\pentaho\data-integration"
set "JOB_NAME=job_main_rrhh.kjb"
REM ---------------------------------------------------------------------

set "BASE_DIR=%~dp0"
set "LOG_DIR=%BASE_DIR%logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"
set "LOG_FILE=%LOG_DIR%\etl_%TS%.log"

if not exist "%PDI_HOME%\Kitchen.bat" (
    echo ERROR: no se encontro Kitchen.bat en %PDI_HOME%
    echo Edite PDI_HOME en este archivo con la ruta de data-integration.
    set "RC=10"
    goto :fin
)

echo Iniciando proceso: %date% %time%
call "%PDI_HOME%\Kitchen.bat" /file:"%BASE_DIR%%JOB_NAME%" /level:Basic >> "%LOG_FILE%" 2>&1
set "RC=%ERRORLEVEL%"

if "%RC%"=="0" (
    echo Proceso finalizado con exito. Log: %LOG_FILE%
) else (
    echo ERROR: el proceso fallo, codigo %RC%. Revise: %LOG_FILE%
)

:fin
if /i not "%~1"=="nopause" pause
endlocal & exit /b %RC%
