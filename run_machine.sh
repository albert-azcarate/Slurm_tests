#!/bin/bash

case "$1" in
  -d) DEBUG=1;;
esac

#set starlife different paths
if [[ $BSC_MACHINE == "starlife" ]]; then
    cd /slgpfs/projects/usertest/usertest/hpc-tc/SLURM || exit
else
    cd /gpfs/projects/usertest/usertest/hpc-tc/SLURM || exit
fi

#load module bsc for bsc_commands in machines that do not load it automatically
if [[ $BSC_MACHINE == "amd" || $BSC_MACHINE == "power" || $BSC_MACHINE == "starlife" ]]; then
    module load bsc
fi

#prepare log directories; MACHINE_NAME.CURRENT_TIME
current_time=$(date "+%Y.%m.%d-%H-%M-%S")
login=$(hostname)
logdir=logs/$BSC_MACHINE-$login.$current_time
VERSION=$(sinfo --version | cut -d ' ' -f2)

echo "Logs: /gpfs/projects/usertest/usertest/hpc-tc/SLURM/$logdir"
echo -e "Output on $BSC_MACHINE\nSLURM version $VERSION" | tee -a $logdir

#START THE TESTS

#Test bsc_queues
echo -n "Testing bsc_queues... " | tee -a $logdir
bsc_queues_path=$(which bsc_queues 2>&1)
CMD_bsc_queues=$($bsc_queues_path 2>&1)
#if the command returns 0, all ok
RETCODE=$?

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    echo "NOT OK" | tee -a $logdir
fi

echo -e "\n----------------------\nDebug output $bsc_queues_path\n$CMD_bsc_queues\n----------------------\n" | tee -a $logdir

#test salloc
echo -n "Testing salloc... " | tee -a $logdir
#tries to allocate a job with job_name "scancel_test_slurm"
CMD_salloc=$(salloc -n 1 -c 1 -J scancel_test_slurm_$BSC_MACHINE-$login-$current_time --time=0-00:00:15 --no-shell 2>&1)
#if the command returns 0, all ok; job allocated
RETCODE=$?

echo -en " \t... " | tee -a $logdir
SALLOC_EXIT=true
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    echo "NOT OK" | tee -a $logdir
    SALLOC_EXIT=false
fi

echo -e "\n----------------------\nDebug output salloc -n 1 -c 1 -J scancel_test_slurm_$BSC_MACHINE-$login-$current_time --time=0-00:00:15 --no-shell\n$CMD_salloc\n----------------------\n" | tee -a $logdir

#test scancel
echo -n "Testing scancel... " | tee -a $logdir
if [[ $SALLOC_EXIT = true ]]; then
    #look for the jobid with user=$USER and name "scancel_test_slurm"
    jobid=$(squeue -o '%i' -h -u $USER -n scancel_test_slurm_$BSC_MACHINE-$login-$current_time 2>&1)
    out=$(scancel "$jobid" 2>&1)
    #if the command returns 0, all ok; job cancelled
    RETCODE=$?

    echo -en " \t... " | tee -a $logdir
    if [[ $RETCODE -eq 0 ]]; then
        echo "OK" | tee -a $logdir
    else
         echo "NOT OK" | tee -a $logdir
    fi
         echo -e "\n----------------------\nDebug output scancel\nReturn code: $RETCODE\n----------------------\n" | tee -a $logdir
else
    echo -en " \t... " | tee -a $logdir
    echo "Couldn test, salloc failed" | tee -a $logdir
fi

#test salloc X11
echo -n "Testing salloc X11... " | tee -a $logdir
#tries to allocate a job with -x11
CMD_sallocX11=$(salloc -n 1 -c 1 --time=0-00:00:15 --no-shell --x11=all 2>&1)
#if the command returns 0, all ok; job with x11 allocated
RETCODE=$?

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    #if return code = 1 this machine does not have x11
    if [[ $RETCODE -eq 1 ]]; then
        echo "X11 NOT AVAILABLE ON THIS MACHINE" | tee -a $logdir
    else
        echo "NOT OK" | tee -a $logdir
    fi
fi
echo -e "\n----------------------\nDebug output salloc -n 1 -c 1 --time=0-00:00:15 --no-shell --x11=all\n$CMD_sallocX11\n----------------------\n" | tee -a $logdir

#test srun
echo -n "Testing srun... " | tee -a $logdir
#executes an srun with a dummy test -> /bin/hostname
CMD_srun=$(srun -n 1 -c 1 --time=0-00:00:20 /bin/hostname 2>&1)
#if the command returns 0, all ok; srunned
RETCODE=$?
echo -en " \t... " | tee -a $logdir

if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    echo "NOT OK" | tee -a $logdir
fi
echo -e "\n----------------------\nDebug output srun -n 1 -c 1 /bin/hostname\n$CMD_srun\n----------------------\n"  | tee -a $logdir

#test srun x11
echo -n "Testing srun X11... " | tee -a $logdir
#executes srun with xclock.sh (shellscript that calls to xclock)
CMD_srunX11=$(srun -n 1 -c 1 --x11=all --time=0-00:00:30 xclock.sh 2>&1)
#if the command returns 0, all ok, srunned x11
RETCODE=$?

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    if [[ $RETCODE -eq 1 ]]; then
        echo "X11 NOT AVAILABLE ON THIS MACHINE" | tee -a $logdir
    else
        echo "NOT OK" | tee -a $logdir
    fi
fi
echo -e "\n----------------------\nDebug output srun -n 1 -c 1 --x11=all /gpfs/projects/usertest/usertest/hpc-tc/SLURM/xclock.sh\n$CMD_srunX11\n----------------------\n" | tee -a $logdir

#test sacct
echo -n "Testing sacct... " | tee -a $logdir
CMD=$(sacct 2>&1)
#if the command returns 0, all ok; sacct available
RETCODE=$?

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    echo "NOT OK" | tee -a $logdir
fi
echo -e "\n----------------------\nDebug output sacct\nReturn code: $RETCODE\n----------------------\n" | tee -a $logdir

#test sbatch
echo -n "Testing sbatch... " | tee -a $logdir
#sbatches a sleep job
CMD_sbatch=$(sbatch --time=0-00:00:08 sbatch_test.job 2>&1)
#if the command returns 0, all ok; sbatched
RETCODE=$?

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    echo "NOT OK" | tee -a $logdir
fi
echo -e "\n----------------------\nDebug output sbatch sbatch_test.job\n$CMD_sbatch\n----------------------\n" | tee -a $logdir

#test ssh
echo -n "Testing ssh... " | tee -a $logdir
#sbatches a job with a sleep(60) to stablish a note to jump with ssh with job_name "ssh_test_slurm"
CMD_sbatch=$(sbatch -J ssh_test_slurm_$BSC_MACHINE-$login-$current_time --time=0-00:00:40 outside_test.job 2>&1)
#get the job_id with user=$USER and name "ssh_test_slurm"
jobid=$(squeue -o '%i' -h -u $USER -n ssh_test_slurm_$BSC_MACHINE-$login-$current_time)

#wait for the job to get allocated into the machine
CMD_squeue=$(squeue -o '%N' -h --jobs="$jobid" -u $USER)
while [ -z "$CMD_squeue" ]; do
    CMD_squeue=$(squeue -o '%N' -h --jobs="$jobid" -u $USER)
done
#wait for the node to initialize properly
sleep 30

#ssh inside the node that we got from the squeue -o '%N'
CMD_ssh=$(ssh $CMD_squeue echo "SSH establert" 2>&1)
#if the command returns 0, all ok; sshed to node
RETCODE=$?
#cancelem el job
scancel "$jobid"

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    echo "NOT OK" | tee -a $logdir
fi
echo -e "\n----------------------\nDebug output sbatch and outside_connection\n$CMD_sbatch\n$CMD_squeue\n$CMD_ssh\n----------------------\n" | tee -a $logdir


#test GPU
echo -n "Testing GPU avail... " | tee -a $logdir
CMD_nvidia=$(nvidia-smi 2>&1)
#if the command returns 0, all ok; we have nvidia gpus
RETCODEn=$?
CMD_amd=$(rocm-smi 2>&1)
#if the command returns 0, all ok; we have amd gpus
RETCODEa=$?

CMD_grep=$(lspci 2>&1 | grep -E "Radeon|NVIDIA")

echo -en " \t... " | tee -a $logdir
if [[ ($RETCODEn -eq 0 || $RETCODEa -eq 0) ]]; then
    echo "OK" | tee -a $logdir
else
    if [[ $RETCODEn -ne 0 && $RETCODEa -ne 0 && $CMD_grep -eq 0 ]]; then
        echo "MACHINE WITHOUT GPU" | tee -a $logdir
    else
        echo "NOT OK" | tee -a $logdir
    fi
fi
echo -e "\n----------------------\nDebug output gpu test\nNvidia:\n $CMD_nvidia\nAmd:\n $CMD_amd\n$CMD_grep\n----------------------\n" | tee -a $logdir


#test ulimit
echo -n "Testing ulimit... " | tee -a $logdir
CMD_ulimit=$(srun --time=0-00:00:30 ulimit.sh 2>&1)
#if the command returns 0, all ok; If RETCODE=4, we have a highmem node
RETCODE=$?

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    if [[ $RETCODE -eq 4 ]]; then
        echo "OK; NODE WITH HIGHMEM ASSIGNED" | tee -a $logdir
    elif [[ $RETCODE -eq 6 ]]; then
        echo "OK; UNLIMITED MEMORY" | tee -a $logdir
    else
        echo "NOT OK" | tee -a $logdir
    fi
fi
echo -e "\n----------------------\nDebug output ulimit\n$CMD_ulimit\n----------------------\n" | tee -a $logdir


#test highmem nodes
echo -n "Testing ulimit-h... " | tee -a $logdir
CMD_ulimit=$(srun --constraint=highmem --time=0-00:00:30 ulimit_high.sh 2>&1)
#if the command returns 0, all ok; if RETCODE=1 we do not have highmem on this cluster
RETCODE=$?

echo -en " \t... " | tee -a $logdir
if [[ $RETCODE -eq 0 ]]; then
    echo "OK" | tee -a $logdir
else
    if [[ $RETCODE -eq 1 ]]; then
        echo "OK; NODE WITH ONLY ONE TYPE OF NODE" | tee -a $logdir
    elif [[ $RETCODE -eq 6 ]]; then
        echo "OK; UNLIMITED MEMORY" | tee -a $logdir
    else
        echo "NOT OK" | tee -a $logdir
    fi
fi
echo -e "\n----------------------\nDebug output ulimit on a highmem node\n$CMD_ulimit\n----------------------\n" | tee -a $logdir


#test bsc_load
echo -n "Testing bsc_load... " | tee -a $logdir
#sbatches a dummy test to get the load result
CMD_sbatch=$(sbatch -J bsc_load_test_slurm-$BSC_MACHINE-$login-$current_time --time=0-00:00:30 outside_test.job 2>&1)
#get the job id of the job with name "bsc_load_test_slurm"
jobid=$(squeue -o '%i' -h -n bsc_load_test_slurm-$BSC_MACHINE-$login-$current_time)

#wait for the job to get allocated
CMD_squeue=$(squeue -o '%N' -h --jobs="$jobid")
while [ -z "$CMD_squeue" ]; do
    CMD_squeue=$(squeue -o '%N' -h --jobs="$jobid")
done

# if not hua, execute bsc_load
if [[ $BSC_MACHINE != "hua" ]]; then
    bsc_load_path=$(which bsc_load 2>&1)
    CMD_bsc_load=$($bsc_load_path "$jobid" 2>&1)
    #if the command returns 0, all ok
    RETCODE=$?
    scancel "$jobid"

    echo -en " \t... " | tee -a $logdir
    if [[ $RETCODE -eq 0 ]]; then
        echo "OK" | tee -a $logdir
    else
        echo "NOT OK" | tee -a $logdir
    fi
        echo -e "\n----------------------\nDebug output $CMD_bsc_load\n$CMD_bsc_load\n----------------------\n\n\n\n\n\n\n\n" | tee -a $logdir
fi


echo "Done!" | tee -a $logdir

cd logs || exit
find . -size 0 -print0 | xargs -0 rm

# if slgpfs we have to send the logs to gpfs
if [[ $BSC_MACHINE == "starlife" ]]; then
    #scp the logs to gpfs
    scp  $BSC_MACHINE-$login.$current_time usertest@mn1.bsc.es:/home/usertest/usertest/projects/hpc-tc/SLURM/logs
    rm $BSC_MACHINE-$login.$current_time
fi

exit 0
