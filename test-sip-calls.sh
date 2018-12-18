#!/usr/bin/env bash

# Set global vairables
SIPP="$(command -v sipp)"
NAME="test-sip-calls"
TRACE_LOG="${NAME}-trace.log"
ERROR_LOG="${NAME}-error.log"
MSG_LOG="${NAME}-msg.log"
STATS_LOG="${NAME}-stats.log"

_help() {
  echo "
Use: $0 -f <scenario_file.xml> -g <ip_port_gateway> -f <from_did/caller_id> -t <to_did/callee/number> -b <local_ip_bind> <-l> <log_dir>

Example: $0 -f scenario.xml -g 200.200.200.200:5060 -f 553133336666 -t 5531933336666 -b 10.77.88.99
"
  exit 255
}

_exec_test() {
  ${SIPP} \
    "${GATEWAY}" \
    -aa \
    -d 30 \
    -r 1 \
    -rp 1s \
    -sf "${SCENARIO}" \
    -l 1 \
    -m 1 \
    -trace_err \
    -i "${BIND_IP}" \
    -rtp_echo \
    -set from "${FROM}" \
    -set to "${TO}" \
    -trace_logs \
    -log_file "${LOG_DIR}"/"${TRACE_LOG}" \
    -trace_err \
    -error_file "${LOG_DIR}"/"${ERROR_LOG}" \
    -trace_msg \
    -message_file "${LOG_DIR}"/"${MSG_LOG}" \
    -trace_stat \
    -stf "${LOG_DIR}"/"${STATS_LOG}"

  return $?
}

_main() {
  _exec_test
  return $?
}

# don't have arguments sufficient
[[ ${#@} -lt 5 ]] && _help

# parse arguments
while getopts "s:g:f:t:b:l:h?" ARG; do
  case "$ARG" in
    s) [[ -f "$OPTARG" ]] && export SCENARIO="$OPTARG" || exit 1;;
    g) [[ -n "$OPTARG" ]] && export GATEWAY="$OPTARG" || exit 1;;
    f) [[ -n "$OPTARG" ]] && export FROM="$OPTARG" || exit 1;;
    t) [[ -n "$OPTARG" ]] && export TO="$OPTARG" || exit 1;;
    b) [[ -n "$OPTARG" ]] && export BIND_IP="$OPTARG" || exit 1;;
    l) [[ -n "$OPTARG" ]] && export LOG_DIR="$OPTARG";;
    h | \?) _help;;
  esac
done

# sipp is available?
[[ -f "${SIPP}" ]] || exit 1
# if doesn't exist directory, create
[[ -z "$LOG_DIR" ]] && LOG_DIR="/var/log/test-sip-calls"
[[ -d "${LOG_DIR}" ]] || mkdir -p "${LOG_DIR}"

_main || exit 1

