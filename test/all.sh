#!/bin/bash

set -euo pipefail

dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

"$dir/model-test.sh"
"$dir/cli-test.sh"
"$dir/lint.sh"
