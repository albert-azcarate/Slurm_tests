#!/bin/bash
# if an interrupt, reactivate the cursor
trap 'tput -T xterm cnorm; exit 1' INT 

cd /gpfs/projects/usertest/usertest/hpc-tc/SLURM/logs || exit
seen=()
debug=0
if [[ $3 == "-d" ]]; then
  debug=1
fi

#if not debug disable terminal cursor
if [[ $debug == 0  ]]; then
  tput -T xterm civis
fi

function idle(){
  if [[ $debug == 0  ]]; then
	echo -ne "\e[2K\r."
	sleep 1
	echo -ne "\e[2K\r.."
	sleep 1
	echo -ne "\e[2K\r..."
	sleep 1
  fi
}
function report_mach(){
  for machine in $ended; do
    if [[ ! " ${seen[*]} " =~ " ${machine} "  ]]; then
      seen=("${seen[@]}" "${machine}")
      remaining=$(( $1 - ${#seen[*]} ))
			echo -e "\e[3K\r$machine has ended all tests. $remaining machines remaining"
    elif [[ $3 != "end" ]]; then
      idle
    fi
  done
}


# loop until count of "Done!" inside the files is equal to $1
while [[ $(grep -E "Done!" * 2>/dev/null | wc -l) -lt $1 ]]; do
  ended=$(grep -E "Done!" * 2>/dev/null | awk -F '.' '{print $1}' | tr '\n' ' ')
  if [ -n "$ended" ]; then
    report_mach "$@" "not_end"
  else
    idle
  fi
done
# enable terminal cursor
tput -T xterm cnorm

ended=$(grep -E "Done!" * 2>/dev/null | awk -F '.' '{print $1}' | tr '\n' ' ')
report_mach "$@" "end"
current_time="."
# if $2 is 0 move the logs to a directory;  else (custom machines) grep not ok and erase empty files
if [[ $2 -eq 0 ]]; then
  # get the current time
  current_time=$(date "+%Y.%m.%d-%H")
  mkdir -p "$current_time"
  echo -e "\nMoving the logs of the test to /gpfs/projects/usertest/usertest/hpc-tc/SLURM/logs/$current_time"
  find . -maxdepth 1 -type f -exec mv {} "$current_time" \;
fi

# check if there are any "NOT OK" and print them or print "All tests passed"
if [[ $(grep -E "NOT OK" "$current_time"/* 2>/dev/null | wc -l) -eq 0 ]]; then
  echo "All tests passed"
else
  grep "NOT OK" "$current_time"/* 2>/dev/null
fi


# erase empty files
find . -size 0 -delete 
find "$current_time" -size 0 -delete
