#!/bin/bash

#
# This is used at Container start up to run the Tessera and geth nodes
#

set -u
set -e

### Configuration Options
TMCONF=/qdata/config.json

#GETH_ARGS="--datadir /qdata/dd --istanbul.blockperiod 1 --syncmode full --mine --minerthreads 1  --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --nodiscover --unlock 0 --password /qdata/passwords.txt"
GETH_ARGS="--datadir /qdata/dd --rpcport 8545 --port 30303 --raftport 50400 --identity master-3 --istanbul.blockperiod 1 --syncmode full --mine --minerthreads 1  --rpc --rpccorsdomain=* --rpcaddr 0.0.0.0 --rpcvhosts=* --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,clique,raft,istanbul --ws --wsaddr 0.0.0.0 --wsorigins=* --wsapi eth,web3,quorum,txpool,net --wsport 8546 --unlock 0 --password /qdata/passwords.txt --networkid 10 --bootnodes enode://06d3dd36c3fadc14734cbd1db09f61fc1748c27d831dbded9280b29a27185055de83537f40d65ce1056d33c736467562bc6fe03f2498745c1fe3a8a8c19de467@172.13.0.2:30303,enode://5664d3705faf97b0660056c3cfc5fb551e068a599a7048e68cb8eb3f04bb39d0e500934fa997a74f3331aeb0be54ba873965c28825312a29d31bfd0e06f9c43b@172.13.0.3:30303,enode://95aecdb206930cb38b7d2ab996e37654a050fae041a5ed452be42428d5347f79819ee68a50b727e64a2030fd8e62cf909d6def8ba99c2b8e699aa6a097a1b7df@172.13.0.4:30303,enode://5db1f452bf6d6c4af5c3a66255e5b173ff65720267a5bd29583c3fcf25dab3bdc57628c689b511db1596d7dcb0731209dd9c299807c2042f49b4c64103ffe0d3@172.13.0.5:30303,enode://2e05807028d9de5e74435652b9a2508e0d2f6c6ec37a773103c29d1b9b8f71ec1b1517547392ba72b9860d473425db96591f36e1241ae0b351c6e2a45a922f5b@172.13.0.6:30303"


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