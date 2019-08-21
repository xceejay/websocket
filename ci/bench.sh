#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "${0}")"
cd "$(git rev-parse --show-toplevel)"

mkdir -p ci/out/gobench
benchArgs=(
  "-vet=off"
  "-run=^$"
  "-bench=."
  "-o=ci/out/websocket.test"
  "-cpuprofile=ci/out/cpu.prof"
  "-memprofile=ci/out/mem.prof"
  "-blockprofile=ci/out/block.prof"
  "-mutexprofile=ci/out/mutex.prof"
  .
)

if [[ ${CI-} ]]; then
  # https://circleci.com/docs/2.0/collect-test-data/
  go test "${benchArgs[@]}" | tee /dev/stderr |
    go run github.com/jstemmer/go-junit-report > ci/out/gobench/report.xml
else
  go test "${benchArgs[@]}"
fi

echo
echo "Profiles are in ./ci/out/*.prof
Keep in mind that every profiler Go provides is enabled so that may skew the benchmarks."
