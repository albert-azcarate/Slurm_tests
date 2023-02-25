The repository includes various shell scripts, such as start.sh, end.sh, slurm.sh, run_machine.sh, xlock.sh, ulimit.sh, and sbatch_test.job, among others. These scripts are designed to automate the process of testing the different components of the cluster, including the memory, GPU availability, and X11 functionality, among others.

The start.sh script is used to delete the logs of tests that have been performed on specific machines, while the end.sh script moves all the logs from the execution to a folder. The slurm.sh script prepares everything for performing the different SSH connections to the machines and executes run_machine.sh on each of the machines.

The run_machine.sh script performs different tests on each machine, such as bsc_queues, salloc, scancel, srun, sacct, sbatch, ssh to node, among others. The xlock.sh and x11.job scripts test the X11 functionality, while the ulimit.sh and ulimit_high.sh scripts test different memory sizes.

Finally, the sbatch_test.job and sbatch_test.py scripts test the sbatch functionality, while the outside_test.job, outside_test.py, and outside_test_mt.py scripts perform a sleep of 60 seconds to give enough time to connect to the node via SSH. Overall, this repository contains a collection of scripts that facilitate the testing and configuration of a cluster of machines.
