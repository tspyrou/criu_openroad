#!/bin/bash

set -e

TCL_SCRIPT="log_loop.tcl"
CHECKPOINT_DIR="checkpoint"

echo "?? Starting tclsh script in background..."
tclsh $TCL_SCRIPT &
TCL_PID=$!

sleep 2  # give it a moment to run
echo "? Running Tcl PID: $TCL_PID"

echo "??? Creating checkpoint directory..."
mkdir -p $CHECKPOINT_DIR

echo "?? Dumping process with CRIU..."
sudo criu dump -t $TCL_PID -D $CHECKPOINT_DIR --shell-job --leave-running

sleep 1

echo "? Killing original process..."
kill $TCL_PID
sleep 1

echo "?? Restoring process from checkpoint..."
sudo criu restore -D $CHECKPOINT_DIR --shell-job

RESTORED_PID=$(pgrep -n tclsh)

if [ -n "$RESTORED_PID" ]; then
    echo "? Restored process is running with PID $RESTORED_PID"
else
    echo "? Failed to restore Tcl process"
    exit 1
fi
