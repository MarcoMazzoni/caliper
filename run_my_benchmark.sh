#!/bin/bash
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../caliper-benchmarks/networks/quorum/5nodes-raft --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json

#1 Raft local PUB
#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/raft/5n-raft-local-pub/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json --caliper-flow-skip-end

#2 Raft local PRIV
#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/raft/5n-raft-local-priv/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json 

#3 Istanbul local PUB
#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/ibft/5n-ibft-local-pub/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json 

#4 Istanbul local PRIV
#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/ibft/5n-ibft-local-priv/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json 

#5 Raft MQTT PUB
#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/raft/5n-raft-mqtt-pub/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json 

#6 Raft MQTT PRIV
#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/raft/5n-raft-mqtt-priv/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json #--caliper-flow-skip-start

#7 Istanbul MQTT PUB 
#node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/ibft/5n-ibft-mqtt-pub/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json 

# 8 Istanbul MQTT PRIV 
node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../quorum-caliper-benchmarks/ibft/5n-ibft-mqtt-priv/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json --caliper-flow-skip-start


