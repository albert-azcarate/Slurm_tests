#!/bin/bash

#ulimit inside the machine
Ulimit=$(ulimit -m 2>&1)
echo $Ulimit
# check if we have unlimited memory
if [[ $Ulimit == *"unlimited"* ]]; then
   exit 6
fi

#check checks if we have a highmem node; 4 if not
if [[ $Ulimit -gt 7500000 ]]; then
   exit 0
else
   exit 4
fi