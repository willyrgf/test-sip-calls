# test-sip-calls
A tool for check and monitoring SIP channels with real calls.

```sh
./test-sip-calls.sh -h

http://github.com/willyrgf/test-sip-calls

A tool for check and monitoring SIP channels with real calls.

Use:
./test-sip-calls.sh -s <scenario_file.xml> -g <ip_port_gateway> -f <from_did/caller_id> -t <to_did/callee/number> -b <local_ip_bind> <-l> <log_dir>

Example:
./test-sip-calls.sh -s scenario.xml -g 200.200.200.200:5060 -f 553133336666 -t 5531933336666 -b 10.77.88.99 -l /var/log/test-sip-calls/

Exit codes:
    0: All calls were successful (200OK + RTP recv/send)
    1: At least one call failed
   97: Exit on internal command calls may have been processed
   99: Normal exit without calls processed
   -1: Fatal error
   -2: Fatal error binding a socket
  255: Timeout reached
```
