#!/bin/bash
#clean dirty logs of previous tests
cd /gpfs/projects/usertest/usertest/hpc-tc/SLURM/logs || exit
echo -e "Clearing dirty logs of unique machine tests"
find . -maxdepth 1 -type f ! -name ".gitignore" -exec rm {} \;

