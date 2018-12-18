#!/usr/bin/env bash

# Set global vairables
SIPP="$(command -v sipp)"
NAME="test-sip-calls"
NULL="/dev/null"
PID_FILE="/var/run/${NAME}.pid"
# logs
TRACE_LOG="${NAME}-trace.log"
ERROR_LOG="${NAME}-error.log"
MSG_LOG="${NAME}-msg.log"
STATS_LOG="${NAME}-stats.log"
SCREEN_LOG="${NAME}-screen.log"

_help() {
  echo "
http://github.com/willyrgf/test-sip-calls

A tool for check and monitoring SIP channels with real calls.

Use:
$0 -f <scenario_file.xml> -g <ip_port_gateway> -f <from_did/caller_id> -t <to_did/callee/number> -b <local_ip_bind> <-l> <log_dir>

Example:
$0 -f scenario.xml -g 200.200.200.200:5060 -f 553133336666 -t 5531933336666 -b 10.77.88.99 -l /var/log/test-sip-calls/

Exit codes:
    0: All calls were successful (200OK + RTP recv/send)
    1: At least one call failed
   97: Exit on internal command calls may have been processed
   99: Normal exit without calls processed
   -1: Fatal error
   -2: Fatal error binding a socket
  255: Timeout reached
"
  exit 255
}

_check_pidfile() {
  [[ -f ${PID_FILE} ]] && return 1 || return 0
}

_create_pidfile() {
  _check_pidfile || return 1
  echo $$ > "${PID_FILE}"
}

_remove_pidfile() {
  rm -f "${PID_FILE}"
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
    -stf "${LOG_DIR}"/"${STATS_LOG}" \
    -trace_screen \
    -screen_file "${LOG_DIR}"/"${SCREEN_LOG}" \
    -timeout 30s \
    -timeout_error \
    &> ${NULL}

  return $?
}

_main() {
  # if doesn't exist pidfile, create
  _create_pidfile || exit 1

  # execute test and return the _exec_test exit code
  _exec_test
  exit_code=$?

  _remove_pidfile
  return ${exit_code}
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
    l) [[ -n "$OPTARG" ]] && export LOG_DIR="$OPTARG" || LOG_DIR="/var/log/test-sip-calls/";;
    h | \?) _help;;
  esac
done

# sipp is available?
[[ -f "${SIPP}" ]] || exit 1
# if doesn't exist directory, create
[[ -d "${LOG_DIR}" ]] || mkdir -p "${LOG_DIR}"

_main || exit $? 

