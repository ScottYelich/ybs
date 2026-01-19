#!/bin/bash
# Test script for /stats and /context commands

echo "Testing /stats and /context commands..."
echo ""

# Create test input
cat <<'EOF' | swift run test7
hello
/stats
/context
/context 100
/stats
quit
EOF
