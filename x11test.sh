#!/bin/bash
CMD_sallocX11=$(salloc -n 1 -c 1 --time=0-00:00:30 --no-shell --x11=all 2>&1)
RETCODE=$?

echo -en " \t... "
if [[ $RETCODE -eq 0 ]]; then
    echo "OK"
else
    if [[ $RETCODE -eq 1  ]]; then
        echo "X11 NOT AVAILABLE ON THIS MACHINE"
    else
        echo "NOT OK"
    fi
fi
exit 0