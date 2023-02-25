## Slurm Tests

This repository contains a collection of shell scripts that can be used to test various components of a cluster, including memory, GPU availability, X11 functionality, and more. The following is a brief description of each script included in this repository:

## Scripts

- `start.sh`: This script is used to delete the logs of tests that have been performed on specific machines.

- `end.sh`: This script moves all the logs from the execution to a folder.

- `slurm.sh`: This script prepares everything for performing the different SSH connections to the machines and executes `run_machine.sh` on each of the machines.

- `run_machine.sh`: This script performs different tests on each machine, such as `bsc_queues`, `salloc`, `scancel`, `srun`, `sacct`, `sbatch`, `ssh to node`, among others.

- `xlock.sh` and `x11.job`: These scripts test the X11 functionality.

- `ulimit.sh` and `ulimit_high.sh`: These scripts test different memory sizes.

- `sbatch_test.job` and `sbatch_test.py`: These scripts test the sbatch functionality.

- `outside_test.job`, `outside_test.py`, and `outside_test_mt.py`: These scripts perform a sleep of 60 seconds to give enough time to connect to the node via SSH.

Overall, this repository contains a collection of scripts that facilitate the testing and configuration of a cluster of machines.

