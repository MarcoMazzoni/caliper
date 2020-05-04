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

node ./packages/caliper-cli/caliper.js launch master --caliper-workspace ../caliper-docker-tests/3n-raft-local/ --caliper-benchconfig benchconfig.yaml --caliper-networkconfig networkconfig.json