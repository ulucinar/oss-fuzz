#!/bin/bash -eu
# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

rm -r $SRC/fabric/cmd/cryptogen

cd $SRC/instrumentation && go run main.go $SRC/fabric && cd $SRC/fabric
go mod tidy && go mod vendor


cp $SRC/persistence_fuzzer.go ./core/chaincode/persistence/mock/
go get github.com/AdaLogics/go-fuzz-headers
go mod vendor
compile_go_fuzzer github.com/hyperledger/fabric/core/chaincode/persistence/mock FuzzPersistence fuzz_persistence
compile_go_fuzzer github.com/hyperledger/fabric/core/chaincode/persistence/mock FuzzChaincodePackageStreamerMetadatabytes FuzzChaincodePackageStreamerMetadatabytes
compile_go_fuzzer github.com/hyperledger/fabric/core/chaincode/persistence/mock FuzzParseChaincodePackage FuzzParseChaincodePackage

cp $SRC/ccprovider_fuzzer.go ./core/common/ccprovider/
compile_go_fuzzer github.com/hyperledger/fabric/core/common/ccprovider FuzzExtractFileEntries FuzzExtractFileEntries

cp $SRC/policydsl_fuzzer.go $SRC/fabric/common/policydsl/
compile_go_fuzzer github.com/hyperledger/fabric/common/policydsl FuzzFromString fuzz_from_string

cp $SRC/msp_fuzzer.go $SRC/fabric/msp/
compile_go_fuzzer github.com/hyperledger/fabric/msp FuzzDeserializeIdentity fuzz_deserialize_identity

cp $SRC/fabenc_fuzzer.go $SRC/fabric/common/flogging/fabenc/
compile_go_fuzzer github.com/hyperledger/fabric/common/flogging/fabenc FuzzParseFormat fuzz_parse_format

cp $SRC/*.options $OUT/