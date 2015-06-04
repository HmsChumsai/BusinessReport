#!/bin/bash
# Last Modified Date: 20140616-02

export REPORT_NAME="retailReports"
export REPORT_VERSION="v01A_001"
export BROKER_PREFIX="SSLTD"
export REPORT_TYPE="SSLTD-MarkToMarket"
export REPORT_FORMAT="PDF"

# =====================================================================
MY_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export REPORT_CONFIG="$MY_DIR/../../../etc/report_config.sh"
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
#$CHECK_SCRIPT --checkDepositid $@ 2>&1 | addLogPrevix | $LOGGER "$LOG_FILE"

if [ "$?" = "0" ]; then 
 $GEN_REPORT_SCRIPT $@ 2>&1 | addLogPrevix | $LOGGER "$LOG_FILE"
fi

