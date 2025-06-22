#!/bin/bash
# Source this script to set TMPDIR for your shell or scripts
export TMPDIR=${HOME}/.ramdisk/tmp
mkdir -p "$TMPDIR"
chmod 700 "$TMPDIR"
