#!/bin/bash
# Last Modified Date: 20140616-02

export REPORT_NAME="callForceReport"
export BROKER_PREFIX="BEE"
export REPORT_TYPE="BEE-A1"
export REPORT_FORMAT="CSV"

# =====================================================================

export REPORT_CONFIG="../../../etc/report_config.sh"
if [[ ! -f $REPORT_CONFIG ]]; then
  echo "Configuration file $REPORT_CONFIG not found. Exit."
  exit 1
fi

set -a
#Loading global report configuration.
. $REPORT_CONFIG
. $FUNCTION_UTILS
set +a

#Check argument
$CHECK_SCRIPT --checkDepositid $@ 2>&1 | addLogPrevix | $LOGGER "$LOG_FILE"

if [ "$?" = "0" ]; then 
 $GEN_REPORT_SCRIPT $@ 2>&1 | addLogPrevix | $LOGGER "$LOG_FILE"
fi

