#!/usr/bin/env bash
# Helper to run Nextflow lint/validation using the strict syntax parser

# Ensure the script is executable: chmod +x scripts/strict-lint.sh

# Usage:
#   ./scripts/strict-lint.sh [nextflow args]
#
# This will export the NXF_SYNTAX_PARSER environment variable to `v2` and
# then run `nextflow lint` (or any other command) with your arguments.

set -euo pipefail

export NXF_SYNTAX_PARSER=v2

echo "Running with strict syntax parser (NXF_SYNTAX_PARSER=$NXF_SYNTAX_PARSER)"

echo "nextflow $*"

# Execute given nextflow command, or default to lint
if [ $# -eq 0 ]; then
    nextflow lint
else
    nextflow "$@"
fi
