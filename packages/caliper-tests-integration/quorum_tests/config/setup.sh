#!/bin/bash
#
# Create all the necessary scripts, keys, configurations etc. to run
# a cluster of N Quorum nodes with Raft consensus.
#
# The nodes will be in Docker containers. List the IP addresses that
# they will run at below (arbitrary addresses are fine).
#
# Run the cluster with "docker-compose up -d"
#
# Geth and Tessera logfiles for Node N will be in qdata_N/logs/
#

# TODO: check file access permissions, especially for keys.


#### Color Control Codes ###############################################

COLOR_RESET='\e[0m'
COLOR_GREEN='\e[1;32m';
COLOR_RED='\e[1;31m';
COLOR_YELLOW='\e[1;33m';
COLOR_BLUE='\e[1;36m';
COLOR_WHITE='\e[1;37m';


#### Configuration options #############################################

# One Docker container will be configured for each IP address in $ips
subnet="172.13.0.0/16"
export ips=("172.13.0.2" "172.13.0.3" "172.13.0.4" "172.13.0.5" "172.13.0.6")

# Docker image name
image=quorum-tessera-2

# Host ports
rpc_start_port=23000
node_start_port=24000
raft_start_port=25000
ws_start_port=26000
tessera_start_port=27000

# Container ports
raft_port=50400
constellation_port=9000
rlp_port=30303
rpc_port=8545
ws_port=8546

########################################################################

nnodes=${#ips[@]}

if [[ $nnodes < 2 ]]
then
    echo "ERROR: There must be more than one node IP address."
    exit 1
fi
   
./cleanup.sh

uid=`id -u`
gid=`id -g`
pwd=`pwd`

#### Create directories for each node's configuration ##################

echo '[1] Configuring for '$nnodes' nodes.'

n=1
for ip in ${ips[*]}
do
    qd=qdata_$n
    mkdir -p $qd/{logs,keys}
    mkdir -p $qd/dd/geth
    mkdir -p $qd/dd/keystore

    let n++
done


#### Make static-nodes.json and store keys #############################

echo -e "${COLOR_WHITE}[2] Creating Enodes and static-nodes.json.${COLOR_RESET}"

bootnode=""

master_enodes="master_enodes=(\n"

echo "[" > static-nodes.json
n=1
for ip in ${ips[*]}
do
    qd=qdata_$n

    # Generate the node's Enode and key
    nkey=`docker run --net=host --rm -u $uid:$gid -v $pwd/$qd:/qdata $image sh -c "/usr/local/bin/bootnode -genkey /qdata/dd/nodekey -writeaddress; cat /qdata/dd/nodekey"`

    #enode=`docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/bootnode -genkey /qdata/dd/nodekey -writeaddress`

    enode=`docker run --net=host --rm -u $uid:$gid -v $pwd/$qd:/qdata $image sh -c "/usr/local/bin/bootnode -nodekeyhex ${nkey} -writeaddress"`
    
    # Add the enode to static-nodes.json
    sep=`[[ $n < $nnodes ]] && echo ","`
    echo '  "enode://'$enode'@'$ip':'$rlp_port'?raftport='$raft_port'"'$sep >> static-nodes.json
    
    bootnode="${bootnode}enode:\\/\\/${enode}@${ip}:${rlp_port}$sep"

    master_enodes="${master_enodes}${enode}\n"

    echo -e "  - ${COLOR_GREEN}Node #${n}${COLOR_RESET} with nodekey: ${COLOR_YELLOW}${enode:0:8}...${enode:120:8}${COLOR_RESET} configured."

    let n++
done
echo "]" >> static-nodes.json


#### Create accounts, keys and genesis.json file #######################

echo '[3] Creating Ether accounts and genesis.json.'

cat > genesis.json <<EOF
{
  "alloc": {
EOF

n=1
for ip in ${ips[*]}
do
    qd=qdata_$n

    # Generate an Ether account for the node
    cp ./keyfiles/keystore$n/key.prv $qd/dd/keystore/key.prv
    touch $qd/passwords.txt
    account=`docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/geth --datadir=/qdata/dd --password /qdata/passwords.txt account list | cut -c 14-53`

    # Add the account to the genesis block so it has some Ether at start-up
    sep=`[[ $n < $nnodes ]] && echo ","`
    cat >> genesis.json <<EOF
    "${account}": {
      "balance": "1000000000000000000000000000"
    }${sep}
EOF

    let n++
done

cat >> genesis.json <<EOF
  },
  "coinbase": "0x0000000000000000000000000000000000000000",
  "config": {
    "homesteadBlock": 0,
    "byzantiumBlock": 0,
    "chainId": 10,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "eip158Block": 0,
    "isQuorum": true
  },
  "difficulty": "0x0",
  "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "gasLimit": "0xE0000000",
  "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
  "nonce": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
EOF


#### Complete each node's configuration ################################

echo '[4] Creating Tessera keys and config.json - completing configuration.'

#### Add peers to config.json ########################################

n=1
for ip in ${ips[*]}
do
    qd=qdata_$n
    
    sep=`[[ $n > 1 ]] && echo ","`
    myline1='"url": "http://'
    myline1+="$ip:9000"
    myline1+='"'
    #myline1+=$sep

echo "    Adding peers to Tessera config file:"
echo $myline1
    sed -i "/peer/ a {\n\t\t$myline1\n\t}$sep" utils/config.json
    let n++
done


n=1
for ip in ${ips[*]}
do
    qd=qdata_$n

    cat utils/config.json | sed s/_NODEIP_/${ips[$((n-1))]}/g > $qd/config.json

    cp genesis.json $qd/genesis.json
    cp static-nodes.json $qd/dd/static-nodes.json

    # Generate Quorum-related keys (used by Constellation)
    #docker run -u $uid:$gid -v $pwd/$qd:/qdata $image /usr/local/bin/constellation-enclave-keygen /qdata/keys/tm /qdata/keys/tma < /dev/null > /dev/null
    #echo 'Node '$n' public key: '`cat $qd/keys/tm.pub`

    # Generate Quorum-related keys (used by Tessera)
    docker run -u $uid:$gid -v $pwd/$qd:/qdata $image java -jar /tessera/tessera-app.jar -keygen -filename /qdata/keys/tm < /dev/null > /dev/null
    echo 'Node '$n' public key: '`cat $qd/keys/tm.pub`


    cat utils/start-node.sh \
        | sed s/{raft_port}/${raft_port}/g \
        | sed s/{rpc_port}/${rpc_port}/g \
        | sed s/{rlp_port}/${rlp_port}/g \
	      | sed s/{ws_port}/${ws_port}/g \
        | sed "s/{node_name}/${node_name_prefix}-$n/g" \
        | sed "s/{bootnode}/--bootnodes ${bootnode}/g" \
            > $qd/start-node.sh

    #cp utils/start-node.sh $qd/start-node.sh
    chmod 755 $qd/start-node.sh

    let n++
done

rm -rf genesis.json static-nodes.json


#### Create the docker-compose file ####################################

cat > docker-compose.yml <<EOF
version: '3.6'
services:
EOF

n=1
for ip in ${ips[*]}
do
    qd=qdata_$n

    cat >> docker-compose.yml <<EOF
  node_$n:
    image: $image
    volumes:
      - './$qd:/qdata'
    networks:
      quorum_net:
        ipv4_address: '$ip'
    ports:
      - $((n+rpc_start_port)):8545
      - $((n+node_start_port)):30303
      - $((n+raft_start_port)):50400
      - $((n+ws_start_port)):8546
      - $((n+tessera_start_port)):9000
    user: '$uid:$gid'
EOF

    let n++
done

cat >> docker-compose.yml <<EOF
networks:
  quorum_net:
    driver: bridge
    ipam:
      driver: default
      config:
      - subnet: $subnet
EOF


#### Create pre-populated contracts and copy them into nodes' directory ####################################

# Private contract - insert Node 2 as the recipient
#cat utils/private_contract.js \
#    | sed s:_NODEKEY_:`cat qdata_2/keys/tm.pub`:g \
#          > private_contract.js

# Public contract - no change required
#cp utils/public_contract.js ./

#n=1
#for ip in ${ips[*]}
#do
#    qd=qdata_$n
#    cp private_contract.js $qd/private_contract.js
#    cp public_contract.js $qd/public_contract.js
#    let n++
#done