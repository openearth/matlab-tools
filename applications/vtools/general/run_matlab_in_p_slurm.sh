#!/bin/bash
#SBATCH --partition=4vcpu
#SBATCH --time=1-00:00:00  
#SBATCH --ntasks=1         
#SBATCH --ntasks-per-node=1

# NOTES:
#	-do a dos2unix
# 	-call as sbatch ./run_matlab_in_p

module load matlab/2023b

#for running one instance in a node (i.e., a 1 node core):
matlab -r main_plot_01_p01

#for running several instances (e.g., 2) in the same node:
matlab -r main_plot_01_p01 &
echo "wait..."
sleep 1
matlab -r main_plot_01_p01
