#!/bin/bash

#
# This is used at Container start up to run the Tessera and geth nodes
#

set -u
set -e

### Configuration Options
TMCONF=/qdata/config.json

#GETH_ARGS="--datadir /qdata/dd --raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --nodiscover --unlock 0 --password /qdata/passwords.txt"
GETH_ARGS="--datadir /qdata/dd --rpcport 8545 --port 30303 --raftport 50400 --identity master-3 --raft --rpc --rpccorsdomain=* --rpcaddr 0.0.0.0 --rpcvhosts=* --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,clique,raft,istanbul --ws --wsaddr 0.0.0.0 --wsorigins=* --wsapi eth,web3,quorum,txpool,net --wsport 8546 --unlock 0 --password /qdata/passwords.txt --networkid 10 --bootnodes enode://c5b626976f5a874909ee2bb99ca23c4d7d8d1db637b4f927ae6a17b22d29a34e5aac6ae9adff28dc243544bd9446a9e0d080b6a6d663e2c8b706c5de68929ded@172.13.0.2:30303,enode://264c338095ef1187190272b2e7747c33e5fd6a44892e5a84921dcc243755954a091a658ee5fb74ba4d2adb5f623ad305bc6ea08dc7ddc446573ff34616939edc@172.13.0.3:30303,enode://124853d28f514fc8070a06e4f44464550eb918e1aaf83647ef15d3806e6b97d74d6be8522dcecf594beb1122a267b1799146b3c17756428373d288d3727847d9@172.13.0.4:30303,enode://9dd423d89e8a310ced2f13f73d6e053bf5854c74d8809bc07082e40a770f34958e2e363d78c36601c952aa356c9b9820774d155dcab9bd3869fa93859a71ee1d@172.13.0.5:30303,enode://ce12955849952883127ddab3af2656acecaf80fd6d4f125b7bb44e983f978e6f755a9b77683731e440237d912888af9a4f7ebc33480c4f020973e6991c674f2d@172.13.0.6:30303"


if [ ! -d /qdata/dd/geth/chaindata ]; then
  echo "[*] Mining Genesis block"
  /usr/local/bin/geth --datadir /qdata/dd init /qdata/genesis.json
fi

# echo "[*] Starting Constellation node"
# nohup /usr/local/bin/constellation-node $TMCONF 2>> /qdata/logs/constellation.log &

echo "[*] Starting Tessera node"
java -jar /tessera/tessera-app.jar -configfile $TMCONF >> /qdata/logs/tessera.log 2>&1 &

sleep 60

echo "[*] Starting Geth node"
PRIVATE_CONFIG=/qdata/tm.ipc nohup /usr/local/bin/geth $GETH_ARGS 2>>/qdata/logs/geth.log