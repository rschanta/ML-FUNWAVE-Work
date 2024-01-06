#!/bin/bash -l
#
#
#SBATCH --nodes=1
#SBATCH --tasks-per-node=4
#SBATCH --mem-per-cpu=55G
#SBATCH --job-name=Get_30_Seconds
#SBATCH --partition=standard
#SBATCH --time=7-00:00:00
#SBATCH --output=mylog.out
#SBATCH --error=myfail.out
#SBATCH --mail-user="rschanta@udel.edu"
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --export=ALL
#UD_QUIET_JOB_SETUP=YES
#UD_USE_SRUN_LAUNCHER=YES
#UD_DISABLE_CPU_AFFINITY=YES
#UD_MPI_RANK_DISTRIB_BY=CORE
#UD_DISABLE_IB_INTERFACES=YES
#UD_SHOW_MPI_DEBUGGING=YES

vpkg_require openmpi
## VARIABLES
# Parent directory containing 'outXXXXX' directories
parent_dir="/lustre/scratch/rschanta/trials/next_frame-out"
# New folder in the current directory where stacked files will be generated
output_folder="stacked_files_1_3"
# Number of test cases
no_cases=1000
# Number of eta files (related to simulation time and delta T set)
no_eta=600


# Create a folder within the local directory to store stacked files
mkdir -p "$output_folder"

# Loop through each outXXXXX file in parent_dir
for ((i=1; i<=no_cases; i++)); do
    # Create name of outXXXXX file (ie- out00001)
    folder_name=$(printf "out%05d" "$i")  
    # Create full path to outXXXXX directory
    to_dir="$parent_dir/$folder_name"     
    # Create name of the output file for this test case in output_folder
    output_file="$output_folder/stacked_$folder_name.txt"  
    
    # Create empty file for the output of each test run
    > "$output_file"

    # Loop through each 'eta_' files and append their contents to the output file
    for ((j=0; j<=no_eta; j++)); do
	# Create name of each eta_XXXXX file
        file_name="eta_$(printf "%05d" "$j")"  
	# Create full path to each eta_XXXXX file
        file_path="$to_dir/$file_name"

        # Check if the eta file exists, echo success or nonsuccess
        if [ -f "$file_path" ]; then
            echo "Appending $file_name from $folder_name..."
            # Append outputs to end of output_file
            cat "$file_path" >> "$output_file"  
        else
            echo "File $file_name not found in $folder_name."
        fi
    done

    # Final Success Echo
    echo "Stacked files created for $folder_name in $output_folder"
done
