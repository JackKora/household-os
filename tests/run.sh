#!/usr/bin/env bash

set -euo pipefail

repo_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)

"$repo_root/tests/test_invariants.sh"
"$repo_root/tests/test_install.sh"

printf 'All Household OS checks passed.\n'
