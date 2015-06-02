#!/bin/bash
# Last Modified Date: 20140616-02

export RCNV_HOME="/usr/local/decide/space-HKTHX-3/cfg/business_reports/CallForceReport/v01A_001"
export BROKER_PREFIX="TSC"
export REPORT_TYPE="TSC-D3"
export REPORT_TEMPLATE="$REPORT_TYPE.jrxml"
export REPORT_GENDER="$REPORT_TYPE.lua"
export CURRENT_KEY="$(date +%s%6N)"
export LOG_FILE_NAME="$REPORT_TYPE.log"
export PDF_FILE_NAME="$REPORT_TYPE-$CURRENT_KEY.pdf"
export DB_FILE_NAME="$REPORT_TYPE-$CURRENT_KEY.db"
export REPORT_CONFIG="$RCNV_HOME/etc/report_config.sh"

if [[ ! -f $REPORT_CONFIG ]]; then
  echo "Configuration file $REPORT_CONFIG not found. Exit."
  exit 1
fi
set -a
#Loading global report configuration.
. $REPORT_CONFIG
set +a

$CONVERT_SCRIPT "$@"

