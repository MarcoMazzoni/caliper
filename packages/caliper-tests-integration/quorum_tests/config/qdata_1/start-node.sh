#!/bin/bash

#
# This is used at Container start up to run the Tessera and geth nodes
#

set -u
set -e

### Configuration Options
TMCONF=/qdata/config.json

#GETH_ARGS="--datadir /qdata/dd --istanbul.blockperiod 1 --syncmode full --mine --minerthreads 1  --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --nodiscover --unlock 0 --password /qdata/passwords.txt"
GETH_ARGS="--datadir /qdata/dd --rpcport 8545 --port 30303 --raftport 50400 --identity master-1 --istanbul.blockperiod 1 --syncmode full --mine --minerthreads 1  --rpc --rpccorsdomain=* --rpcaddr 0.0.0.0 --rpcvhosts=* --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,clique,raft,istanbul --ws --wsaddr 0.0.0.0 --wsorigins=* --wsapi eth,web3,quorum,txpool,net --wsport 8546 --unlock 0 --password /qdata/passwords.txt --networkid 10 --bootnodes enode://3cdf40127118966f98925e92e030765f410e90ed25f127865afe781746f310d81f3c7a784e776ffee676d4dd21dd8f0bbc0c2b97291a5c792c19b9915e089424@172.13.0.2:30303,enode://524e0a0f60e56bd9c2b9e7f0fcc0093e4f4f95fed509c87933f7a25666ac2e7e9138500d8062035bf0193332d0c10e2878d9f6d3b0cefd8ebe206fdbe9a432ad@172.13.0.3:30303,enode://11e0e32d3a840cd4e447333bea537d90661282f4ac8c9274cd76c9e281f05c81dafda6c9df754fc354a2378605d3bcd1bd7d96fcea2f6e411c8ac178b8c5c38e@172.13.0.4:30303,enode://a22679a9a9f870a44f31daf6d8074313064a55301c189d406b34ed3617320f13f5980a3b8c87b4d1336b5c047cf3d7a9b39d32503ad74163509809d88682cc66@172.13.0.5:30303,enode://e74e93eaf8a89d848b981cfe00e42c6d89fd856fbbba9a6f1a60aaac9241bd282bed2343427759dbb0386c747124bfff86a226b5074fed2defe0466cb6094cde@172.13.0.6:30303"


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