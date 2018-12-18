#!/usr/bin/env bash

SIPP="$(command -v sipp)"

_help() {
  echo "
Use: $0 -f <scenario_file.xml> -g <ip_port_gateway> -f <from_did/caller_id> -t <to_did/callee/number> -b <local_ip_bind>

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
    -log_file /tmp/test-sip-calls.log

  return $?
}

_main() {
  _exec_test
  return $?
}

# don't have arguments sufficient
[[ ${#@} -lt 5 ]] && _help

# parse arguments
while getopts "s:g:f:t:b:h?" ARG; do
  case "$ARG" in
    s) [[ -f "$OPTARG" ]] && export SCENARIO="$OPTARG" || exit 1;;
    g) [[ -n "$OPTARG" ]] && export GATEWAY="$OPTARG" || exit 1;;
    f) [[ -n "$OPTARG" ]] && export FROM="$OPTARG" || exit 1;;
    t) [[ -n "$OPTARG" ]] && export TO="$OPTARG" || exit 1;;
    b) [[ -n "$OPTARG" ]] && export BIND_IP="$OPTARG" || exit 1;;
    h | \?) _help;;
  esac
done

# sipp is available?
[[ -f "${SIPP}" ]] || exit 1

_main || exit 1

