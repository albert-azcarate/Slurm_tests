#!/bin/bash

function trap_int(){
  tput -T xterm cnorm
  echo ""
  exit 1
}
trap 'trap_int' INT
# trap on timeout to enable cursor
trap 'tput -T xterm cnorm; exit 1' SIGALRM

# setup de un vector de maquines i variables de control
machines=(mn0 mn1 mn2 mn3 mn4 mn5 mt1 nord1 nord2 nord3 nord4 plogin1 plogin2 amd star hualogin1)
mach=0
flags=""
timeout_t=360
Output="1>/dev/null 2>/dev/null"

# read input flags [-c, -d, -t, -n, -h]
while getopts dc:t:n:h flag; do
    case "${flag}" in
    d)  flags="-d"
        Output="2>&1"
        ;;
    # -c is used to test only a few machines; pick all the machines in a list after -c until the next flag; it can be used with -d in any order;
    c)  config_machines=(${machines[@]})
        machines=()
        OPTIND=$((OPTIND-1))
        # get all possible machines        
        while [[ $OPTIND -le $# ]]; do
            # if the next argument is a flag, break
            [[ ${!OPTIND} == -* ]] && break
            # if a real machine on config add the next argument to the machines array; else print error and exit
            if [[ " ${config_machines[*]} " =~ " ${!OPTIND} " ]]; then
                machines+=("${!OPTIND}")
            else
                echo "Machine: ${!OPTIND} not a machine in ssh config file. Machines can be the following: ${config_machines[*]}" && exit 1
            fi
            OPTIND=$((OPTIND+1))
        done
        mach=1
        ;;
    t)  timeout_t="$OPTARG"
        ;;
    # -n to remove a machine from the list of machines to test
    n)  OPTIND=$((OPTIND-1))
        # get all possible machines        
        while [[ $OPTIND -le $# ]]; do
            # if the next argument is a flag, break
            [[ ${!OPTIND} == -* ]] && break
            # if a real machine on config, remove the machine from the array; else print error and exit
            if [[ " ${machines[*]} " =~ " ${!OPTIND} " ]]; then
                machines=("${machines[@]/${!OPTIND}}")
            else
                echo "Machine: ${!OPTIND} not a machine in ssh config file. Machines can be the following: ${machines[*]}" && exit 1
            fi
            OPTIND=$((OPTIND+1))
        done
        ;;
    h)
        echo -e "\nusage: $0 [-d] [-c machine/s] [-n machine/s] [-t seconds to timeout ssh conections]\nThis program will run a certain number of tests on each machine in parallel and report its results on a directory with the datetime as of now.\nIf you want to only test a few machines use '-c machine machine ...'.\nIf you want to test all machines but a few use '-n machine_to_not_test machine_to_not_test ...'. This machines will not be tested.\nUse -d to enable debug output. This will only work when testing one machine at a time.\nDefault timeout is $timeout_t seconds.\nAll the logs are stored at /gpfs/projects/usertest/usertest/hpc-tc/SLURM/logs." >&2
        exit 1
        ;;
    *)
        echo -e "\nusage: $0 [-d] [-c machine/s] [-n machine/s] [-t seconds to timeout ssh conections]\nThis program will run a certain number of tests on each machine in parallel and report its results on a directory with the datetime as of now.\nIf you want to only test a few machines use '-c machine machine ...'.\nIf you want to test all machines but a few use '-n machine_to_not_test machine_to_not_test ...'. This machines will not be tested.\nUse -d to enable debug output. This will only work when testing one machine at a time.\nDefault timeout is $timeout_t seconds.\nAll the logs are stored at /gpfs/projects/usertest/usertest/hpc-tc/SLURM/logs." >&2
        exit 1
        ;;
    esac
done
m_temp=()
for machine in "${machines[@]}"; do
    #if machine is not empyt add it to the array
    if [[ -n "$machine" ]]; then
        m_temp+=("$machine")
    fi
done
machines=("${m_temp[@]}")

# if testing multiple machines and debuf flag is set we disable debug output to avoid clutter
if [[ ${#machines[@]} -gt 1 && $flags =~ "-d" ]]; then
    flags=""
    Output="1>/dev/null 2>/dev/null"
    echo "Disabling debug flag to avoid clutter. If you want to see the logs go to /gpfs/projects/usertest/usertest/hpc-tc/SLURM/logs or run one test at a time with '-c single_machine_to_test -d'"
fi

# clean dirty logs of previous tests
ssh -n mn /gpfs/projects/usertest/usertest/hpc-tc/SLURM/start.sh

t_m=$((timeout_t/60))
echo "Timeout of ssh connections is set at $timeout_t seconds (aprox $t_m minutes)"
echo "Testing machines: ${machines[*]} (${#machines[@]} machines)"
# Per cada maquina dins machines fem ssh execute de run_machine.sh amb la flag -d o sense
for machine in "${machines[@]}"; do
    # Com starlife te un gpfs diferent te un altre path; mn4 i mn5 ssh a mn1 i despres a login4 i login5
    case "$machine" in
        star) (timeout $timeout_t ssh -f -X -n star timeout $timeout_t  /slgpfs/projects/usertest/usertest/hpc-tc/SLURM/run_machine.sh $flags $Output; exit $?) ;;
        mn4) (timeout $timeout_t ssh -f -X -n mn1 timeout $timeout_t ssh -f -X -n login4 /gpfs/projects/usertest/usertest/hpc-tc/SLURM/run_machine.sh $flags $Output; exit $?) ;;
        mn5) (timeout $timeout_t ssh -f -X -n mn1 timeout $timeout_t ssh -f -X -n login5 /gpfs/projects/usertest/usertest/hpc-tc/SLURM/run_machine.sh $flags $Output; exit $?) ;;
        *) (timeout $timeout_t ssh -f -X -n "$machine" timeout $timeout_t /gpfs/projects/usertest/usertest/hpc-tc/SLURM/run_machine.sh $flags $Output; exit $?) ;;
    esac
    sleep 0.5
done
if [[ ! $flags =~ "-d" ]]; then
    echo "All ssh sent"
fi

# get lenght of machines to use it for checking every machine has ended
machines_len=${#machines[@]}
ssh mn timeout $timeout_t /gpfs/projects/usertest/usertest/hpc-tc/SLURM/end.sh $machines_len $machine $flags
[[ $? -eq 124 ]] && echo -e "\nTimeout while waiting for some machine to end. Please check the logs to see what happend. Most likely a job did not enter execution" && tput -T xterm cnorm

exit 0
