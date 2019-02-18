#!/bin/sh

if [ -z "$PROTONDB_UPDATED" -a -z "$LOM_UPDATED" ]; then
        exit 42
fi

pkill -HUP -f sbin/nginx || true
