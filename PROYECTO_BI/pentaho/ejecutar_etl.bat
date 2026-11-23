
@echo off
setlocal

REM =====================================================================
REM Ejecuta el ETL completo (replica Excel -> stg + carga del modelo dwh)
REM =====================================================================

REM --- CONFIGURACION ---------------------------------------------------
if not defined PDI_HOME set "PDI_HOME=C:\pentaho\data-integration"

set "JOB_NAME=job_main_rrhh.kjb"

set "BASE_DIR=%~dp0"
set "LOG_DIR=%BASE_DIR%logs"

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"

for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd_HHmmss"') do set "TS=%%i"

set "LOG_FILE=%LOG_DIR%\etl_%TS%.log"

REM --- VERIFICAR PENTAHO -----------------------------------------------
if not exist "%PDI_HOME%\Kitchen.bat" (
    echo.
    echo No se encontro Pentaho en la ruta predeterminada:
    echo %PDI_HOME%
    echo.
    set /p "PDI_HOME=Ingrese la ruta de la carpeta data-integration: "
)

if not exist "%PDI_HOME%\Kitchen.bat" (
    echo.
    echo ERROR: no se encontro Kitchen.bat en la ruta indicada:
    echo %PDI_HOME%
    set "RC=10"
    goto :fin
)

REM --- VERIFICAR JOB ----------------------------------------------------
if not exist "%BASE_DIR%%JOB_NAME%" (
    echo ERROR: no se encontro el archivo:
    echo %BASE_DIR%%JOB_NAME%
    set "RC=11"
    goto :fin
)

REM --- EJECUTAR ETL -----------------------------------------------------
echo.
echo Iniciando proceso: %date% %time%
echo Ejecutando ETL...
echo.

call "%PDI_HOME%\Kitchen.bat" /file:"%BASE_DIR%%JOB_NAME%" /level:Basic >> "%LOG_FILE%" 2>&1

set "RC=%ERRORLEVEL%"

if "%RC%"=="0" (
    echo.
    echo Proceso finalizado con exito.
    echo Log: %LOG_FILE%
) else (
    echo.
    echo ERROR: el proceso fallo, codigo %RC%.
    echo Revise el log: %LOG_FILE%
)

:fin
if /i not "%~1"=="nopause" pause

endlocal & exit /b %RC%

