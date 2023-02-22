#!/bin/bash

#executes the ulimit inside the machine
Ulimit=$(ulimit -m 2>&1)
echo $Ulimit
if [[ $Ulimit == "unlimited" ]]; then
   exit 6
fi
if [[ $BSC_MACHINE == "starlife" && $Ulimit -gt 300000 ]]; then exit 0
fi

#check the different sizes. 0 if MN4 small nodes, 4 if highmem, 5 if error
if [[ $Ulimit -lt 2000000 && $Ulimit -gt 1600000 ]]; then
   exit 0
elif [[ $Ulimit -gt 7500000  ]]; then
   exit 4
else 
   exit 5
fi
