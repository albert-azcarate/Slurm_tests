#!/bin/bash

#if huawei, execute xterm; else xclock
if [[ $BSC_MACHINE == "hua" ]]; then
    timeout 2 xterm
else
    timeout 2 xclock
fi

#return 0 if ok
RETVAL=$?
if [[ $RETVAL -eq 124 ]]; then
    exit 0
else
    exit $RETVAL
fi