#!/bin/bash -l
#
#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --mem-per-cpu=55G
#SBATCH --job-name=Next_Frame_Run
#SBATCH --partition=standard
#SBATCH --time=7-00:00:00
#SBATCH --output=mylog.out
#SBATCH --error=myfail.out
#SBATCH --mail-user='rschanta@udel.edu'
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --export=ALL
vpkg_require openmpi
#UD_QUIET_JOB_SETUP=YES
#UD_USE_SRUN_LAUNCHER=YES
#UD_DISABLE_CPU_AFFINITY=YES
#UD_MPI_RANK_DISTRIB_BY=CORE
#UD_DISABLE_IB_INTERFACES=YES
#UD_SHOW_MPI_DEBUGGING=YES

. /opt/shared/slurm/templates/libexec/openmpi.sh

########################### INPUTS ##############################
# DIRECTORY WHERE INPUT FILES ARE (include slash at end)
indir="/lustre/scratch/rschanta/trials/next_frame_bin-in/"

# FILE PATH OF FUNWAVE EXECUTABLE
fun_ex="/work/thsu/rschanta/ML-FUNWAVE/ML-FUNWAVE"

##################################################################

# Ensure that only input.txt files are passed
input_files=($(find "$indir" -name 'input_*.txt'))

# Loop through each input file
for input_file in "${input_files[@]}"; do

    echo "Working on"
    echo "$input_file"

    ${UD_MPIRUN} "$fun_ex" "$input_file"
    mpi_rc=$?
    
    # Check the return code and take action based on success or failure
    if [ "$mpi_rc" -eq 0 ]; then
        echo "Execution of $input_file was successful"
    else
        echo "Execution of $input_file failed with exit code $mpi_rc"
    fi
done

# Exit with the last return code (from the last input file)
exit $mpi_rc
