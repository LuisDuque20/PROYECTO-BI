#!/bin/bash
# =====================================================================
# Ejecuta el job de replica Excel -> stg (Pentaho Kitchen)
# Requisitos:
#   - PDI_HOME apuntando a la carpeta data-integration (editar abajo
#     o exportar la variable antes de ejecutar)
#   - ~/.kettle/kettle.properties con RUTA_ORIGEN, ARCHIVO_ORIGEN, DB_*
# Uso: ./ejecutar_replica.sh
# =====================================================================

# --- CONFIGURACION ---------------------------------------------------
PDI_HOME="${PDI_HOME:-$HOME/pentaho/data-integration}"
JOB_NAME="job_replica_stg.kjb"
# ---------------------------------------------------------------------

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_DIR="$BASE_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/replica_$(date +%Y%m%d_%H%M%S).log"

if [ ! -x "$PDI_HOME/kitchen.sh" ]; then
    echo "ERROR: no se encontro kitchen.sh en $PDI_HOME"
    echo "Defina PDI_HOME con la ruta de data-integration."
    exit 10
fi

echo "Iniciando replica: $(date)" | tee -a "$LOG_FILE"
"$PDI_HOME/kitchen.sh" -file="$BASE_DIR/$JOB_NAME" -level=Basic >> "$LOG_FILE" 2>&1
RC=$?

if [ $RC -eq 0 ]; then
    echo "Replica finalizada con exito. Log: $LOG_FILE"
else
    echo "ERROR: la replica fallo (codigo $RC). Revise: $LOG_FILE"
fi
exit $RC
