# check_mk-scaleio

### A check script for ScaleIO that outputs in check_mk / nagios format

The script will hunt through a list of servers to find the current primary MDM, on which "scli" commands will be executed and the output parsed and formatted into nagios/check_mk format. This includes overall status of the cluster, SDS health and usage, including block device errors, SDC attachment and bandwidth usage.

## Requirements:

This script must be executed from a host that can "ssh" to all ScaleIO MDM hosts as root, without password. You are encouraged to modify the script to suit your security needs within your environment.

## Installation

Older (< 1.2.6) check_mk:

mv check_scaleio /usr/lib/check_mk_agent/local

Newer check_mk:

mv check_scaleio /usr/share/check_mk_agent/local


You will need to edit the script to change the hostnames of your scaleIO MDMs


## Usage

Generally this script is useful to be run by the check_mk agent, typically listening on TCP 6556 via xinetd.


## TODO

support for more than one PD

support for fault-sets

Please contribute if you have an environment to test these in!

## EXAMPLE OUTPUT

```
0 073890cb00000000 storage_pools=1|fault_sets=0|sds_nodes=5|volumes=65|bytes_available=532480000000 PD has 1 storage pools, 0 Fault Sets, 5 SDS nodes, 65 volumes and 532480000000 Bytes available for volume allocation
0 073890cb00000000rsm - MDM restricted SDC mode enabled
0 073890cb00000000nj sds_nodes_joined=5 PD has 5 SDS nodes Joined
0 073890cb00000000nc sds_nodes_connected=5 PD has 5 SDS nodes Connected
0 073890cb00000000tc bytes_total_capacity=1494000000000 PD Total capacity 1494000000000 Bytes
0 073890cb00000000uc unused_capacity=1077000000000 PD Unused capacity 1077000000000 Bytes
0 073890cb00000000pr iops=1|bytes_per_second=5734 PD 1 IOPS; Primary-reads 5734 Bytes/s
0 073890cb00000000pw iops=56|bytes_per_second=608665 PD 56 IOPS; Primary-writes 608665 Bytes/s
0 073890cb00000000sr iops=0|bytes_per_second=0 PD 0 IOPS; Secondary-reads 0 Bytes/s
0 073890cb00000000sw iops=42|bytes_per_second=575078 PD 42 IOPS; Secondary-writes 575078 Bytes/s
0 073890cb00000000brr iops=0|bytes_per_second=0 PD 0 IOPS; Backward-rebuild-reads 0 Bytes/s
0 073890cb00000000brw iops=0|bytes_per_second=0 PD 0 IOPS; Backward-rebuild-writes 0 Bytes/s
0 073890cb00000000frr iops=0|bytes_per_second=0 PD 0 IOPS; Forward-rebuild-reads 0 Bytes/s
0 073890cb00000000frw iops=0|bytes_per_second=0 PD 0 IOPS; Forward-rebuild-writes 0 Bytes/s
0 073890cb00000000rr iops=0|bytes_per_second=0 PD 0 IOPS; Rebalance-reads 0 Bytes/s
0 073890cb00000000rw iops=0|bytes_per_second=0 PD 0 IOPS; Rebalance-writes 0 Bytes/s
0 ee7536fd00000004tc bytes_total_capacity=306175000000 SDS Total capacity 306175000000 Bytes
0 ee7536fd00000004uc unused_capacity=274431000000 SDS Unused capacity 274431000000 Bytes
0 ee7536fd00000004pr iops=0|bytes_per_second=0 SDS 0 IOPS; Primary-reads 0 Bytes/s
0 ee7536fd00000004pw iops=2|bytes_per_second=13107 SDS 2 IOPS; Primary-writes 13107 Bytes/s
0 ee7536fd00000004sr iops=0|bytes_per_second=0 SDS 0 IOPS; Secondary-reads 0 Bytes/s
0 ee7536fd00000004sw iops=1|bytes_per_second=7372 SDS 1 IOPS; Secondary-writes 7372 Bytes/s
0 ee7536fd00000004brr iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-reads 0 Bytes/s
0 ee7536fd00000004brw iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-writes 0 Bytes/s
0 ee7536fd00000004frr iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-reads 0 Bytes/s
0 ee7536fd00000004frw iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-writes 0 Bytes/s
0 ee7536fd00000004rr iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-reads 0 Bytes/s
0 ee7536fd00000004rw iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-writes 0 Bytes/s
0 beff164900040000 capacity_bytes=298000000000|errors_fixed=0|scanned_bytes=0000000|compare_errors=0 SDS /dev/sdb Normal; capacity 298000000000 Bytes on SDS ee7536fd00000004
0 ee7536fc00000003tc bytes_total_capacity=306175000000 SDS Total capacity 306175000000 Bytes
0 ee7536fc00000003uc unused_capacity=274431000000 SDS Unused capacity 274431000000 Bytes
0 ee7536fc00000003pr iops=1|bytes_per_second=4096 SDS 1 IOPS; Primary-reads 4096 Bytes/s
0 ee7536fc00000003pw iops=5|bytes_per_second=50790 SDS 5 IOPS; Primary-writes 50790 Bytes/s
0 ee7536fc00000003sr iops=0|bytes_per_second=0 SDS 0 IOPS; Secondary-reads 0 Bytes/s
0 ee7536fc00000003sw iops=8|bytes_per_second=58163 SDS 8 IOPS; Secondary-writes 58163 Bytes/s
0 ee7536fc00000003brr iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-reads 0 Bytes/s
0 ee7536fc00000003brw iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-writes 0 Bytes/s
0 ee7536fc00000003frr iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-reads 0 Bytes/s
0 ee7536fc00000003frw iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-writes 0 Bytes/s
0 ee7536fc00000003rr iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-reads 0 Bytes/s
0 ee7536fc00000003rw iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-writes 0 Bytes/s
0 beff164800030000 capacity_bytes=298000000000|errors_fixed=0|scanned_bytes=0000000|compare_errors=0 SDS /dev/sdb Normal; capacity 298000000000 Bytes on SDS ee7536fc00000003
0 ee7536fb00000002tc bytes_total_capacity=306175000000 SDS Total capacity 306175000000 Bytes
0 ee7536fb00000002uc unused_capacity=274431000000 SDS Unused capacity 274431000000 Bytes
0 ee7536fb00000002pr iops=0|bytes_per_second=0 SDS 0 IOPS; Primary-reads 0 Bytes/s
0 ee7536fb00000002pw iops=31|bytes_per_second=252313 SDS 31 IOPS; Primary-writes 252313 Bytes/s
0 ee7536fb00000002sr iops=0|bytes_per_second=0 SDS 0 IOPS; Secondary-reads 0 Bytes/s
0 ee7536fb00000002sw iops=22|bytes_per_second=283443 SDS 22 IOPS; Secondary-writes 283443 Bytes/s
0 ee7536fb00000002brr iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-reads 0 Bytes/s
0 ee7536fb00000002brw iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-writes 0 Bytes/s
0 ee7536fb00000002frr iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-reads 0 Bytes/s
0 ee7536fb00000002frw iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-writes 0 Bytes/s
0 ee7536fb00000002rr iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-reads 0 Bytes/s
0 ee7536fb00000002rw iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-writes 0 Bytes/s
0 befb164700020000 capacity_bytes=298000000000|errors_fixed=0|scanned_bytes=0000000|compare_errors=0 SDS /dev/sdb Normal; capacity 298000000000 Bytes on SDS ee7536fb00000002
0 ee7536fa00000001tc bytes_total_capacity=306175000000 SDS Total capacity 306175000000 Bytes
0 ee7536fa00000001uc unused_capacity=274431000000 SDS Unused capacity 274431000000 Bytes
0 ee7536fa00000001pr iops=0|bytes_per_second=0 SDS 0 IOPS; Primary-reads 0 Bytes/s
0 ee7536fa00000001pw iops=6|bytes_per_second=51609 SDS 6 IOPS; Primary-writes 51609 Bytes/s
0 ee7536fa00000001sr iops=0|bytes_per_second=0 SDS 0 IOPS; Secondary-reads 0 Bytes/s
0 ee7536fa00000001sw iops=5|bytes_per_second=195788 SDS 5 IOPS; Secondary-writes 195788 Bytes/s
0 ee7536fa00000001brr iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-reads 0 Bytes/s
0 ee7536fa00000001brw iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-writes 0 Bytes/s
0 ee7536fa00000001frr iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-reads 0 Bytes/s
0 ee7536fa00000001frw iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-writes 0 Bytes/s
0 ee7536fa00000001rr iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-reads 0 Bytes/s
0 ee7536fa00000001rw iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-writes 0 Bytes/s
0 befb164b00010000 capacity_bytes=298000000000|errors_fixed=0|scanned_bytes=0000000|compare_errors=0 SDS /dev/sdb Normal; capacity 298000000000 Bytes on SDS ee7536fa00000001
0 ee7536f900000000tc bytes_total_capacity=306175000000 SDS Total capacity 306175000000 Bytes
0 ee7536f900000000uc unused_capacity=274431000000 SDS Unused capacity 274431000000 Bytes
0 ee7536f900000000pr iops=0|bytes_per_second=0 SDS 0 IOPS; Primary-reads 0 Bytes/s
0 ee7536f900000000pw iops=35|bytes_per_second=210534 SDS 35 IOPS; Primary-writes 210534 Bytes/s
0 ee7536f900000000sr iops=0|bytes_per_second=0 SDS 0 IOPS; Secondary-reads 0 Bytes/s
0 ee7536f900000000sw iops=31|bytes_per_second=259686 SDS 31 IOPS; Secondary-writes 259686 Bytes/s
0 ee7536f900000000brr iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-reads 0 Bytes/s
0 ee7536f900000000brw iops=0|bytes_per_second=0 SDS 0 IOPS; Backward-rebuild-writes 0 Bytes/s
0 ee7536f900000000frr iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-reads 0 Bytes/s
0 ee7536f900000000frw iops=0|bytes_per_second=0 SDS 0 IOPS; Forward-rebuild-writes 0 Bytes/s
0 ee7536f900000000rr iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-reads 0 Bytes/s
0 ee7536f900000000rw iops=0|bytes_per_second=0 SDS 0 IOPS; Rebalance-writes 0 Bytes/s
0 befb164a00000000 capacity_bytes=298000000000|errors_fixed=0|scanned_bytes=0000000|compare_errors=0 SDS /dev/sdb Normal; capacity 298000000000 Bytes on SDS ee7536f900000000
0 64fae10900000000 connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: N/A, IP: 224.36.61.122)
0 64fae10a00000001 connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: N/A, IP: 224.36.61.124)
0 64fae10b00000002 connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: N/A, IP: 224.36.61.59)
0 64fae10c00000003 connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: N/A, IP: 224.36.61.210)
0 64fae10d00000004 connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: N/A, IP: 224.36.61.61)
0 64fba45900000005 connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: dev-registry, IP: 224.36.63.220)
0 64fb7d4900000006 connected=1|approved=1|read_iop_second=0|write_iop_second=1|read_bytes_second=0|write_bytes_second=1 SDC Read 0 IOPS, 0 Bytes/s; Write 1 IOPS, 1 Bytes/s (Connected, Approved: 1, Name: dev-swarm01, IP: 224.36.60.98)
0 64fb56390000000c connected=1|approved=1|read_iop_second=0|write_iop_second=36|read_bytes_second=0|write_bytes_second=36 SDC Read 0 IOPS, 0 Bytes/s; Write 36 IOPS, 36 Bytes/s (Connected, Approved: 1, Name: dev-swarm02, IP: 224.36.60.96)
0 64fb563a0000000d connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: dev-swarm03, IP: 224.36.60.93)
0 64fb563b0000000e connected=1|approved=1|read_iop_second=0|write_iop_second=55|read_bytes_second=0|write_bytes_second=55 SDC Read 0 IOPS, 0 Bytes/s; Write 55 IOPS, 55 Bytes/s (Connected, Approved: 1, Name: dev-swarm04, IP: 224.36.60.91)
0 64fb563c0000000f connected=1|approved=1|read_iop_second=0|write_iop_second=0|read_bytes_second=0|write_bytes_second=0 SDC Read 0 IOPS, 0 Bytes/s; Write 0 IOPS, 0 Bytes/s (Connected, Approved: 1, Name: dev-swarm06, IP: 224.36.60.79)
0 64fb7d4a00000010 connected=1|approved=1|read_iop_second=0|write_iop_second=58|read_bytes_second=0|write_bytes_second=58 SDC Read 0 IOPS, 0 Bytes/s; Write 58 IOPS, 58 Bytes/s (Connected, Approved: 1, Name: dev-swarm05, IP: 224.36.60.81)
```
