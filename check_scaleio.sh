#/bin/bash

SCALEIO_SERVERS="scaleio1.example.com scaleio2.example.com scaleio3.example.com"
SCALEIO_PW="SCALEIO_ADMIN_PASSWORD"


##################################
TMPFILE=/tmp/tmp.services.nagiosdata.scaleio
OUTFILE=/tmp/services.nagiosdata.scaleio
PRIMARY_SERVER=

#Find out which server is our current primary MDM
for SERVER in ${SCALEIO_SERVERS}; do
  OUTPUT=$(ssh ${SERVER} "scli --login --username admin --password ${SCALEIO_PW} 2>/dev/null | grep 'Logged in'") 
  #Error: Failed to connect
  #Logged in. User role is SuperUser. System ID is 78221ddb0dcff2f5
  if [ "$?" == "0" ]; then
    PRIMARY_SERVER=${SERVER}
    break
  fi
done

if [ "${PRIMARY_SERVER}" != "" ]; then

  > $TMPFILE



##################################
## QUERY ALL
##################################

  QUERY_ALL_OUTPUT=$(ssh ${PRIMARY_SERVER} "scli --query_all | sed 's/[()]//g; s/\.[0-9] KB/000 Bytes/g; s/ KB/000 Bytes/g; s/\.[0-9] MB/000000 Bytes/g; s/ MB/000000 Bytes/g; s/\.[0-9] GB/000000000 Bytes/g; s/ GB/000000000 Bytes/g; s/\.[0-9] TB/000000000000 Bytes/g; s/ TB/000000000000 Bytes/g'")

#[root@scaleio ~]# scli --query_all
#
#System Info:
#    Product:  EMC ScaleIO Version: R2_0.12000.122
#    ID:      78221ddb0dcff2f5
#    Manager ID:      0000000000000000
#
#License info:
#    Installation ID: 5d848ea4078b651d
#    SWID:
#    Maximum capacity: Unlimited
#    Usage time left: Unlimited *** Non-Production License ***
#    Enterprise features: Enabled
#    The system was activated 13 days ago
#
#System settings:
#    Capacity alert thresholds: High: 80, Critical: 90
#    Thick volume reservation percent: 0
#    MDM restricted SDC mode: enabled
#    Management Clients secure communication: enabled
#    TLS version: TLSv1.2
#    CLI preemptive login banner acceptance via shell: enabled
#    User authentication method: Native
#    SDS connection authentication: Enabled
#
#Query all returned 1 Protection Domain:
#Protection Domain default Id: 073890cb00000000 has 1 storage pools, 0 Fault Sets, 5 SDS nodes, 23 volumes and 568000000000 Bytes 581632000000 Bytes available for volume allocation
#Operational state is Active
#Rfcache enabled, Mode: Write miss, Page Size 64000 Bytes, Max IO size 128000 Bytes
#
#Storage Pool default Id: 08cd1e2100000000 has 23 volumes and 568000000000 Bytes 581632000000 Bytes available for volume allocation
#    The number of parallel rebuild/rebalance jobs: 2
#    Rebuild is enabled and using Limit-Concurrent-IO policy with the following parameters:
#    Number of concurrent IOs per device: 1
#    Rebalance is enabled and using Favor-Application-IO policy with the following parameters:
#    Number of concurrent IOs per device: 1, Bandwidth limit per device: 10240000 Bytes per second
#    Background device scanner: Disabled
#    Zero padding is disabled
#    Spare policy: 20% out of total
#    Checksum mode: disabled
#    Uses RAM Read Cache
#    RAM Read Cache write handling mode is 'cached'
#    Doesn't use Flash Read Cache
#    Capacity alert thresholds: High: 80, Critical: 90
#
#
#SDS Summary:
#    Total 5 SDS Nodes
#    5 SDS nodes have membership state 'Joined'
#    5 SDS nodes have connection state 'Connected'
#    1000000000000 Bytes 1494000000000 Bytes total capacity
#    1000000000000 Bytes 1157000000000 Bytes unused capacity
#    0 Bytes snapshots capacity
#    38000000000 Bytes 39434000000 Bytes in-use capacity
#    38000000000 Bytes 39434000000 Bytes thin capacity
#    38000000000 Bytes 39434000000 Bytes protected capacity
#    0 Bytes failed capacity
#    0 Bytes degraded-failed capacity
#    0 Bytes degraded-healthy capacity
#    0 Bytes unreachable-unused capacity
#    0 Bytes active rebalance capacity
#    0 Bytes pending rebalance capacity
#    0 Bytes active forward-rebuild capacity
#    0 Bytes pending forward-rebuild capacity
#    0 Bytes active backward-rebuild capacity
#    0 Bytes pending backward-rebuild capacity
#    0 Bytes rebalance capacity
#    0 Bytes forward-rebuild capacity
#    0 Bytes backward-rebuild capacity
#    0 Bytes active moving capacity
#    0 Bytes pending moving capacity
#    0 Bytes total moving capacity
#    299000000000 Bytes 306175000000 Bytes spare capacity
#    38000000000 Bytes 39434000000 Bytes at-rest capacity
#    0 Bytes semi-protected capacity
#    0 Bytes in-maintenance capacity
#    0 Bytes decreased capacity
#
#    Primary-reads                            0 IOPS 0 Bytes per-second
#    Primary-writes                           19 IOPS 390000 Bytes 399769 Bytes per-second
#    Secondary-reads                          0 IOPS 0 Bytes per-second
#    Secondary-writes                         21 IOPS 406000 Bytes 416153 Bytes per-second
#    Backward-rebuild-reads                   0 IOPS 0 Bytes per-second
#    Backward-rebuild-writes                  0 IOPS 0 Bytes per-second
#    Forward-rebuild-reads                    0 IOPS 0 Bytes per-second
#    Forward-rebuild-writes                   0 IOPS 0 Bytes per-second
#    Rebalance-reads                          0 IOPS 0 Bytes per-second
#    Rebalance-writes                         0 IOPS 0 Bytes per-second
#
#Volumes summary:
#    23 thin-provisioned volumes. Total used size: 19000000000 Bytes 19717000000 Bytes


#   1        2      3       4      5             6  7  8      9     10   11   12  13  14   15   16  17     18  19             20   21          22    23        24   25      26
#Protection Domain default Id: 073890cb00000000 has 1 storage pools, 0 Fault Sets, 5 SDS nodes, 23 volumes and 568000000000 Bytes 581632000000 Bytes available for volume allocation

  PD_ID=$(echo "${QUERY_ALL_OUTPUT}" | awk 'BEGIN {FS=" "} {if ($1=="Protection" && $2=="Domain") {printf "%s", $5} }' )

  #Stop immediately if we can't find a protection domain
  if [ "${PD_ID}" == "" ]; then
    rm -f ${TMPFILE}
    rm -f ${OUTFILE}
    exit
  fi

  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Protection" && $2=="Domain") {printf "0 %s storage_pools=%s|fault_sets=%s|sds_nodes=%s|volumes=%s|bytes_available=%s PD has %s storage pools, %s Fault Sets, %s SDS nodes, %s volumes and %s %s available for volume allocation\n",PDID,$7,$10,$13,$16,$21,$7,$10,$13,$16,$21,$22} }' >> ${TMPFILE}

#    1   2          3   4     5
#    MDM restricted SDC mode: enabled
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="MDM" && $2=="restricted") { if($5=="enabled"){printf "0 %srsm - MDM restricted SDC mode enabled\n", PDID} else {printf "3 %srsm - MDM restricted SDC mode disabled\n", PDID} } }' >> ${TMPFILE}

#    1  2    3     4     5         6      7
#    5 SDS nodes have membership state 'Joined'
#    5 SDS nodes have connection state 'Connected'
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($5=="membership" && $6=="state") {printf "0 %snj sds_nodes_joined=%s PD has %s SDS nodes Joined\n",PDID,$1,$1} }' >> ${TMPFILE}
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($5=="connection" && $6=="state") {printf "0 %snc sds_nodes_connected=%s PD has %s SDS nodes Connected\n",PDID,$1,$1} }' >> ${TMPFILE}

#    1 2     3     4
#    0 Bytes total capacity
#    1             2     3             4     5     6
#    1000000000000 Bytes 1494000000000 Bytes total capacity
    echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($3=="total" && $4=="capacity") {printf "0 %stc bytes_total_capacity=%s PD Total capacity %s %s\n",PDID,$1,$1,$2} else if ($5=="total" && $6=="capacity") {printf "0 %stc bytes_total_capacity=%s PD Total capacity %s %s\n",PDID,$3,$3,$4} }' >> ${TMPFILE}
    echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($3=="unused" && $4=="capacity") {printf "0 %suc unused_capacity=%s PD Unused capacity %s %s (%s %s)\n",PDID,$1,$1,$2} else if ($5=="unused" && $6=="capacity") {printf "0 %suc unused_capacity=%s PD Unused capacity %s %s\n",PDID,$3,$3,$4} }' >> ${TMPFILE}

#    1                                        2 3    4 5     6
#    Primary-reads                            0 IOPS 0 Bytes per-second
#    1                                        2 3    4      5     6      7     8
#    Primary-reads                           19 IOPS 390000 Bytes 399769 Bytes per-second
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Primary-reads" && $6=="per-second") {printf "0 %spr iops=%s|bytes_per_second=%s PD %s IOPS; Primary-reads %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Primary-reads" && $8=="per-second") {printf "0 %spr iops=%s|bytes_per_second=%s PD %s IOPS; Primary-reads %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Primary-writes" && $6=="per-second") {printf "0 %spw iops=%s|bytes_per_second=%s PD %s IOPS; Primary-writes %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Primary-writes" && $8=="per-second") {printf "0 %spw iops=%s|bytes_per_second=%s PD %s IOPS; Primary-writes %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Secondary-reads" && $6=="per-second") {printf "0 %ssr iops=%s|bytes_per_second=%s PD %s IOPS; Secondary-reads %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Secondary-reads" && $8=="per-second") {printf "0 %ssr iops=%s|bytes_per_second=%s PD %s IOPS; Secondary-reads %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Secondary-writes" && $6=="per-second") {printf "0 %ssw iops=%s|bytes_per_second=%s PD %s IOPS; Secondary-writes %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Secondary-writes" && $8=="per-second") {printf "0 %ssw iops=%s|bytes_per_second=%s PD %s IOPS; Secondary-writes %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Backward-rebuild-reads" && $6=="per-second") {printf "0 %sbrr iops=%s|bytes_per_second=%s PD %s IOPS; Backward-rebuild-reads %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Backward-rebuild-reads" && $8=="per-second") {printf "0 %sbrr iops=%s|bytes_per_second=%s PD %s IOPS; Backward-rebuild-reads %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Backward-rebuild-writes" && $6=="per-second") {printf "0 %sbrw iops=%s|bytes_per_second=%s PD %s IOPS; Backward-rebuild-writes %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Backward-rebuild-writes" && $8=="per-second") {printf "0 %sbrw iops=%s|bytes_per_second=%s PD %s IOPS; Backward-rebuild-writes %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Forward-rebuild-reads" && $6=="per-second") {printf "0 %sfrr iops=%s|bytes_per_second=%s PD %s IOPS; Forward-rebuild-reads %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Forward-rebuild-reads" && $8=="per-second") {printf "0 %sfrr iops=%s|bytes_per_second=%s PD %s IOPS; Forward-rebuild-reads %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Forward-rebuild-writes" && $6=="per-second") {printf "0 %sfrw iops=%s|bytes_per_second=%s PD %s IOPS; Forward-rebuild-writes %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Forward-rebuild-writes" && $8=="per-second") {printf "0 %sfrw iops=%s|bytes_per_second=%s PD %s IOPS; Forward-rebuild-writes %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Rebalance-reads" && $6=="per-second") {printf "0 %srr iops=%s|bytes_per_second=%s PD %s IOPS; Rebalance-reads %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Rebalance-reads" && $8=="per-second") {printf "0 %srr iops=%s|bytes_per_second=%s PD %s IOPS; Rebalance-reads %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_ALL_OUTPUT}" | awk -v PDID=${PD_ID} 'BEGIN {FS=" "} {if ($1=="Rebalance-writes" && $6=="per-second") {printf "0 %srw iops=%s|bytes_per_second=%s PD %s IOPS; Rebalance-writes %s %s/s\n",PDID,$2,$4,$2,$4,$5} else if ($1=="Rebalance-writes" && $8=="per-second") {printf "0 %srw iops=%s|bytes_per_second=%s PD %s IOPS; Rebalance-writes %s %s/s\n",PDID,$2,$6,$2,$6,$7} }' >> ${TMPFILE}




##################################
## QUERY EACH SDS
##################################

  SDSS=$(ssh ${PRIMARY_SERVER} "scli --query_all_sds | egrep 'SDS ID: [0-9a-f]{16}' | cut -f 3 -d ' '")

  for SDS in ${SDSS}
  do

    QUERY_SDS_OUTPUT=$(ssh ${PRIMARY_SERVER} "scli --query_sds --sds_id ${SDS} | sed 's/[()]//g; s/\.[0-9] KB/000 Bytes/g; s/ KB/000 Bytes/g; s/\.[0-9] MB/000000 Bytes/g; s/ MB/000000 Bytes/g; s/\.[0-9] GB/000000000 Bytes/g; s/ GB/000000000 Bytes/g; s/\.[0-9] TB/000000000000 Bytes/g; s/ TB/000000000000 Bytes/g'")


#SDS ee7536f900000000 Name: SDS_[224.36.61.59] Version: 2.0.12000
#Protection Domain: 073890cb00000000, Name: default
#DRL mode: Volatile
#Authentication error: None
#IP information total 1 IPs:
#     1: 224.36.61.59     Role: All SDS and SDC
#    Port: 7072
#RAM Read Cache information:
#    4000000000 Bytes 4096000000 Bytes total size
#    Cache is enabled
#    RAM Read Cache memory allocation state is SUCCESSFUL
#
#Rfcache enabled
#
#Device information total 1 devices:
#     1: Name: /dev/sdb  Path: /dev/sdb  Original-path: /dev/sdb  ID: befb164a00000000
#        Storage Pool: default, Capacity: 298000000000 Bytes Error-fixes: 0 scanned 0000000 Bytes, Compare errors: 0 State: Normal
#
#No devices use Rfcache
#Membership-state: Joined; Connection-state: Connected; SDS-state: Normal; 0 devices with error; 0 Rfcache devices with errors
#    299000000000 Bytes 306175000000 Bytes total capacity
#    288000000000 Bytes 294911000000 Bytes unused capacity
#    0 Bytes snapshots capacity
#    7000000000 Bytes 7998000000 Bytes in-use capacity
#    7000000000 Bytes 7998000000 Bytes thin capacity
#    0 Bytes unreachable-unused capacity
#    0 active moving-in forward-rebuild jobs
#    0 active moving-in backward-rebuild jobs
#    0 active moving-in rebalance jobs
#    0 active moving-out forward-rebuild jobs
#    0 active moving-out backward-rebuild jobs
#    0 active moving-out rebalance jobs
#    0 pending moving-in forward-rebuild jobs
#    0 pending moving-in backward-rebuild jobs
#    0 pending moving-in rebalance jobs
#    0 pending moving-out forward-rebuild jobs
#    0 pending moving-out backward-rebuild jobs
#    0 pending moving-out rebalance jobs
#    0 Bytes decreased capacity
#
#
#    Primary-reads                            0 IOPS 0 Bytes per-second
#    Primary-writes                           10 IOPS 65000 Bytes 67174 Bytes per-second
#    Secondary-reads                          0 IOPS 0 Bytes per-second
#    Secondary-writes                         22 IOPS 300000 Bytes 308019 Bytes per-second
#    Backward-rebuild-reads                   0 IOPS 0 Bytes per-second
#    Backward-rebuild-writes                  0 IOPS 0 Bytes per-second
#    Forward-rebuild-reads                    0 IOPS 0 Bytes per-second
#    Forward-rebuild-writes                   0 IOPS 0 Bytes per-second
#    Rebalance-reads                          0 IOPS 0 Bytes per-second
#    Rebalance-writes                         0 IOPS 0 Bytes per-second


#    1 2     3     4
#    0 Bytes total capacity
#    1             2     3             4     5     6
#    1000000000000 Bytes 1494000000000 Bytes total capacity
    echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($3=="total" && $4=="capacity") {printf "0 %stc bytes_total_capacity=%s SDS Total capacity %s %s\n",SDS,$1,$1,$2} else if ($5=="total" && $6=="capacity") {printf "0 %stc bytes_total_capacity=%s SDS Total capacity %s %s\n",SDS,$3,$3,$4} }' >> ${TMPFILE}
    echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($3=="unused" && $4=="capacity") {printf "0 %suc unused_capacity=%s SDS Unused capacity %s %s (%s %s)\n",SDS,$1,$1,$2} else if ($5=="unused" && $6=="capacity") {printf "0 %suc unused_capacity=%s SDS Unused capacity %s %s\n",SDS,$3,$3,$4} }' >> ${TMPFILE}

#    1                                        2 3    4 5     6
#    Primary-reads                            0 IOPS 0 Bytes per-second
#    1                                        2 3    4      5     6      7     8
#    Primary-reads                           19 IOPS 390000 Bytes 399769 Bytes per-second
  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Primary-reads" && $6=="per-second") {printf "0 %spr iops=%s|bytes_per_second=%s SDS %s IOPS; Primary-reads %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Primary-reads" && $8=="per-second") {printf "0 %spr iops=%s|bytes_per_second=%s SDS %s IOPS; Primary-reads %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Primary-writes" && $6=="per-second") {printf "0 %spw iops=%s|bytes_per_second=%s SDS %s IOPS; Primary-writes %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Primary-writes" && $8=="per-second") {printf "0 %spw iops=%s|bytes_per_second=%s SDS %s IOPS; Primary-writes %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Secondary-reads" && $6=="per-second") {printf "0 %ssr iops=%s|bytes_per_second=%s SDS %s IOPS; Secondary-reads %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Secondary-reads" && $8=="per-second") {printf "0 %ssr iops=%s|bytes_per_second=%s SDS %s IOPS; Secondary-reads %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Secondary-writes" && $6=="per-second") {printf "0 %ssw iops=%s|bytes_per_second=%s SDS %s IOPS; Secondary-writes %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Secondary-writes" && $8=="per-second") {printf "0 %ssw iops=%s|bytes_per_second=%s SDS %s IOPS; Secondary-writes %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Backward-rebuild-reads" && $6=="per-second") {printf "0 %sbrr iops=%s|bytes_per_second=%s SDS %s IOPS; Backward-rebuild-reads %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Backward-rebuild-reads" && $8=="per-second") {printf "0 %sbrr iops=%s|bytes_per_second=%s SDS %s IOPS; Backward-rebuild-reads %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Backward-rebuild-writes" && $6=="per-second") {printf "0 %sbrw iops=%s|bytes_per_second=%s SDS %s IOPS; Backward-rebuild-writes %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Backward-rebuild-writes" && $8=="per-second") {printf "0 %sbrw iops=%s|bytes_per_second=%s SDS %s IOPS; Backward-rebuild-writes %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Forward-rebuild-reads" && $6=="per-second") {printf "0 %sfrr iops=%s|bytes_per_second=%s SDS %s IOPS; Forward-rebuild-reads %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Forward-rebuild-reads" && $8=="per-second") {printf "0 %sfrr iops=%s|bytes_per_second=%s SDS %s IOPS; Forward-rebuild-reads %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Forward-rebuild-writes" && $6=="per-second") {printf "0 %sfrw iops=%s|bytes_per_second=%s SDS %s IOPS; Forward-rebuild-writes %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Forward-rebuild-writes" && $8=="per-second") {printf "0 %sfrw iops=%s|bytes_per_second=%s SDS %s IOPS; Forward-rebuild-writes %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}

  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Rebalance-reads" && $6=="per-second") {printf "0 %srr iops=%s|bytes_per_second=%s SDS %s IOPS; Rebalance-reads %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Rebalance-reads" && $8=="per-second") {printf "0 %srr iops=%s|bytes_per_second=%s SDS %s IOPS; Rebalance-reads %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}
  echo "${QUERY_SDS_OUTPUT}" | awk -v SDS=${SDS} 'BEGIN {FS=" "} {if ($1=="Rebalance-writes" && $6=="per-second") {printf "0 %srw iops=%s|bytes_per_second=%s SDS %s IOPS; Rebalance-writes %s %s/s\n",SDS,$2,$4,$2,$4,$5} else if ($1=="Rebalance-writes" && $8=="per-second") {printf "0 %srw iops=%s|bytes_per_second=%s SDS %s IOPS; Rebalance-writes %s %s/s\n",SDS,$2,$6,$2,$6,$7} }' >> ${TMPFILE}


##################################
## PARSE EACH DEVICE ON THE SDS 
##################################
# Use "tac" to reverse the output order:
#
#  1       2     3        4         5            6     7            8 9       10          11     12      13      14  15   NF  
#  Storage Pool: default, Capacity: 298000000000 Bytes Error-fixes: 0 scanned 20610000000 Bytes, Compare errors: 0 State: Normal
#  1  2     3    4     5         6              7         8   NF
#  1: Name: N/A  Path: /dev/sdb  Original-path: /dev/sdb  ID: 5b79bfa400040000
#
#0 befb164a00000000 capacity=298000000000|errors_fixed=0|scanned=0000000|compare_errors=0 Device /dev/sdb Normal; capacity 298000000000 Bytes on SDS ee7536f900000000

    echo "${QUERY_SDS_OUTPUT}" | tac | awk -v SDSID=${SDS} 'BEGIN {FS=" "} {if ($15=="State:" && $NF=="Normal") {f[0]=$5;f[1]=$6;f[2]=$8;f[3]=$10;f[4]=$14;f[5]=$NF; getline; printf "0 %s capacity_bytes=%s|errors_fixed=%s|scanned_bytes=%s|compare_errors=%s SDS %s %s; capacity %s %s on SDS %s\n", $NF,f[0],f[2],f[3],f[4],$5,f[5],f[0],f[1],SDSID } else if ($15=="State:" && $NF=="Error") {f[0]=$5;f[1]=$6;f[2]=$8;f[3]=$10;f[4]=$14;f[5]=$NF; getline; printf "1 %s capacity_bytes=%s|errors_fixed=%s|scanned_bytes=%s|compare_errors=%s SDS %s %s; capacity %s %s on SDS %s \n", $NF, f[0],f[2],f[3],f[4],$5,f[5],f[0],f[1],SDSID } else {next} }' >> ${TMPFILE}

  done


#################################################################
## PARSE EACH SDC FOR BANDWIDTH AND APPROVED AND CONNECTED STATES
#################################################################

    QUERY_SDC_OUTPUT=$(ssh ${PRIMARY_SERVER} "scli --query_all_sdc | sed '/ID/{N;s/\n//;N;s/\n//}; s/[()]//g; s/\.[0-9] KB/000 Bytes/g; s/ KB/000 Bytes/g; s/\.[0-9] MB/000000 Bytes/g; s/ MB/000000 Bytes/g; s/\.[0-9] GB/000000000 Bytes/g; s/ GB/000000000 Bytes/g; s/\.[0-9] TB/000000000000 Bytes/g; s/ TB/000000000000 Bytes/g'")

#[root@scaleio ~]# scli --query_all_sdc | sed '/ID/{N;s/\n//;N;s/\n//}; s/[()]//g; s/\.[0-9] KB/000 Bytes/g; s/ KB/000 Bytes/g; s/\.[0-9] MB/000000 Bytes/g; s/ MB/000000 Bytes/g; s/\.[0-9] GB/000000000 Bytes/g; s/ GB/000000000 Bytes/g; s/\.[0-9] TB/000000000000 Bytes/g; s/ TB/000000000000 Bytes/g'
#MDM restricted SDC mode: Enabled
#Query all SDC returned 11 SDC nodes.
#SDC ID: 64fae10900000000 Name: N/A IP: 224.36.61.122 State: Connected GUID: 53023EC4-D754-46A4-B343-0CA5D3A4F55C OS Type: LINUX Approved: yes Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 0 Bytes per-second    Write bandwidth:  0 IOPS 0 Bytes per-second
#SDC ID: 64fb7d4900000006 Name: dev-swarm01 IP: 224.36.60.98 State: Connected GUID: 846414F8-C191-4CA0-9D39-6F6076761D5B OS Type: LINUX Approved: yes Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 0 Bytes per-second    Write bandwidth:  1 IOPS 12000 Bytes 12288 Bytes per-second

#1   2   3                4     5   6   7             8      9         10    11                                   12 13    14    15        16  17     18       19        20        21       22           23   24         25 26  27 28    29            30    31         32 33  34 35    36
#SDC ID: 64fae10900000000 Name: N/A IP: 224.36.61.122 State: Connected GUID: 53023EC4-D754-46A4-B343-0CA5D3A4F55C OS Type: LINUX Approved: yes Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 0 Bytes per-second    Write bandwidth:  0 IOPS 0 Bytes per-second

#1   2   3                4     5               6   7            8      9         10    11                                   12 13    14    15        16  17     18       19        20        21       22           23   24         25 26  27 28    29            30    31         32 33   34    35    36    37    38
#SDC ID: 64fb7d4900000006 Name: dev-swarm01 IP: 224.36.60.98 State: Connected GUID: 846414F8-C191-4CA0-9D39-6F6076761D5B OS Type: LINUX Approved: yes Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 0 Bytes per-second    Write bandwidth:  1 IOPS 12000 Bytes 12288 Bytes per-second

#1   2   3                4     5               6   7            8      9         10    11                                   12 13    14    15        16  17     18       19        20        21       22           23   24         25 26   27    28    29    30    31            32    33         34 35  36 37    38
#SDC ID: 64fb7d4900000006 Name: dev-swarm01 IP: 224.36.60.98 State: Connected GUID: 846414F8-C191-4CA0-9D39-6F6076761D5B OS Type: LINUX Approved: yes Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  1 IOPS 12000 Bytes 12288 Bytes per-second    Write bandwidth:  0 IOPS 0 Bytes per-second

#1   2   3                4     5               6   7            8      9         10    11                                   12 13    14    15        16  17     18       19        20        21       22           23   24         25 26   27    28    29    30    31            32    33         34 35   36    37    38    39    40
#SDC ID: 64fb7d4900000006 Name: dev-swarm01 IP: 224.36.60.98 State: Connected GUID: 846414F8-C191-4CA0-9D39-6F6076761D5B OS Type: LINUX Approved: yes Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  1 IOPS 12000 Bytes 12288 Bytes per-second    Write bandwidth:  1 IOPS 12000 Bytes 12288 Bytes per-second

#1   2   3                4     5    6   7            8      9         10    11                                   12 13    14    15     16       17        18        19       20           21   22         23 24  25 26    27            28    29         30 31  32 33    34
#SDC ID: b4605ba100000000 Name: SDC5 IP: 192.168.33.5 State: Connected GUID: 66792061-70C2-42BC-9623-FBFFB63F298E OS Type: LINUX Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 0 Bytes per-second    Write bandwidth:  0 IOPS 0 Bytes per-second

#1   2   3                4     5    6   7            8      9         10    11                                   12 13    14    15     16       17        18        19       20           21   22         23 24  25 26    27            28    29         30 31   32    33    34    35    36
#SDC ID: b4605ba100000000 Name: SDC5 IP: 192.168.33.5 State: Connected GUID: 66792061-70C2-42BC-9623-FBFFB63F298E OS Type: LINUX Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 0 Bytes per-second    Write bandwidth:  1 IOPS 12000 Bytes 12288 Bytes per-second

#1   2   3                4     5    6   7            8      9         10    11                                   12 13    14    15     16       17        18        19       20           21   22         23 24   25    26    27    28    29            30    31         32 33  34 35    36
#SDC ID: b4605ba100000000 Name: SDC5 IP: 192.168.33.5 State: Connected GUID: 66792061-70C2-42BC-9623-FBFFB63F298E OS Type: LINUX Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 12000 Bytes 12288 Bytes per-second    Write bandwidth:  0 IOPS 0 Bytes per-second

#1   2   3                4     5    6   7            8      9         10    11                                   12 13    14    15     16       17        18        19       20           21   22         23 24   25    26    27    28    29            30    31         32 33   34    35    36    37    38
#SDC ID: b4605ba100000000 Name: SDC5 IP: 192.168.33.5 State: Connected GUID: 66792061-70C2-42BC-9623-FBFFB63F298E OS Type: LINUX Loaded Version: 2.0.12000 Installed Version: 2.0.12000    Read bandwidth:  0 IOPS 12000 Bytes 12288 Bytes per-second    Write bandwidth:  1 IOPS 12000 Bytes 12288 Bytes per-second

  echo "${QUERY_SDC_OUTPUT}" | awk 'BEGIN {FS=" "} { if($1=="SDC" && $2=="ID:") { if($8=="State:" && $9=="Connected"){f[0]=1} else {f[0]=0}; if($15=="Approved:" && $16=="yes") {f[1]=1} else {f[1]=0}; if($24="IOPS"){f[2]=$25} else if ($26="IOPS"){f[2]=$25} if($27=="per-second"){f[3]=$25} else if ($29=="per-second"){f[3]=$27} else if($31="per-second"){f[3]=$29}; if($31=="IOPS"){f[4]=$30} else if ($33=="IOPS") {f[4]=$32} else if($35=="IOPS"){f[4]=$34}; if($34="per-second"){f[5]=$32} else if ($36="per-second"){f[5]=$34} else if($38="per-second"){f[5]=$36} else if($40="per-second"){f[5]=$38}; if(f[0]==0 || f[1]==0) { printf "3 %s connected=%s|approved=%s|read_iop_second=%s|write_iop_second=%s|read_bytes_second=%s|write_bytes_second=%s SDC Read %s IOPS, %s Bytes/s; Write %s IOPS, %s Bytes/s (%s, Approved: %s, Name: %s, IP: %s)\n",$3,f[0],f[1],f[2],f[4],f[3],f[5],f[2],f[3],f[4],f[5],$9,f[1],$5,$7 } else { printf "0 %s connected=%s|approved=%s|read_iop_second=%s|write_iop_second=%s|read_bytes_second=%s|write_bytes_second=%s SDC Read %s IOPS, %s Bytes/s; Write %s IOPS, %s Bytes/s (%s, Approved: %s, Name: %s, IP: %s)\n",$3,f[0],f[1],f[2],f[4],f[3],f[5],f[2],f[3],f[4],f[5],$9,f[1],$5,$7 } } }' >> ${TMPFILE}



#################################################################
# TODO: support for more than one PD
# TOOD: support for fault-sets
#################################################################

  mv -f ${TMPFILE} ${OUTFILE}
  cat ${OUTFILE}

else
  rm -f ${TMPFILE}
  rm -f ${OUTFILE}
fi



