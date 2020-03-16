#!/bin/bash

#
# This is used at Container start up to run the Tessera and geth nodes
#

set -u
set -e

### Configuration Options
TMCONF=/qdata/config.json

#GETH_ARGS="--datadir /qdata/dd --raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --nodiscover --unlock 0 --password /qdata/passwords.txt"
GETH_ARGS="--datadir /qdata/dd --rpcport 8545 --port 30303 --raftport 50400 --identity -1 --raft --rpc --rpccorsdomain=* --rpcaddr 0.0.0.0 --rpcvhosts=* --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,clique,raft,istanbul --ws --wsaddr 0.0.0.0 --wsorigins=* --wsapi eth,web3,quorum,txpool,net --wsport 8546 --unlock 0 --password /qdata/passwords.txt --networkid 10 --bootnodes enode://6c955a37bdddc71499243280fa6fcb417f849c93a1cfc7ad033e72ce58ac8de787c26fa535db390844000cf8f87036974b4798173a4c8745417b302fdf40f4b0@172.13.0.2:30303,enode://b8b8e4304ee95c5b7498640491460f83840f3be203ce358b35e8ac96ea0a212b65e3f95e3a08d3ad1923dc8867f1595907177ccb2ed6562cb06a305be9727b53@172.13.0.3:30303,enode://32cd1125b928f5dc3f73edf0ba623bfc9365e5e82918a0bf63d0389e9de519db3a585ad2520dfd191fa995e2919ecceff62e165be54a9e7090cebd2f51dfa292@172.13.0.4:30303,enode://09a5232c2a4b4ad9e08d9031ed0534f5ffbfa400edc498ce4d355bdbd9a83a1b3d7848e7f426ab79ed05eca5b41255f7519962923944dcfc569925ee19052d69@172.13.0.5:30303,enode://249413549112aa8d51d87240b711f0d210aff0b5138600f0fb64adf4de03a8dde9ddc8af7c914fddd62334790c233c970cf81c52a58093d55c856eff17fbef57@172.13.0.6:30303"


if [ ! -d /qdata/dd/geth/chaindata ]; then
  echo "[*] Mining Genesis block"
  /usr/local/bin/geth --datadir /qdata/dd init /qdata/genesis.json
fi

# echo "[*] Starting Constellation node"
# nohup /usr/local/bin/constellation-node $TMCONF 2>> /qdata/logs/constellation.log &

echo "[*] Starting Tessera node"
java -jar /tessera/tessera-app.jar -configfile $TMCONF >> /qdata/logs/tessera.log 2>&1 &

sleep 50

echo "[*] Starting Geth node"
PRIVATE_CONFIG=/qdata/tm.ipc nohup /usr/local/bin/geth $GETH_ARGS 2>>/qdata/logs/geth.log