#%% Name of Function/Script

#%% DEV HISTORY 
'''
    Last edit: 15 January 2024
    Edit made: 
        - Added preamble and cleaned up file directory notation

'''

#%% DOCUMENTATION
'''
## FUNCTION OR SCRIPT
    This file is intended to be run as a SCRIPT

## DESCRIPTION
    This script creates numpy arrays containing all the information from a 
    series of FUNWAVE runs. It assumes a 1D FUNWAVE run where Nglob = 3. It 
    outputs 2 numpy arrays- `data.npy` which contains everything, and 
    'data_1D.npy' which just contains the middle row of Nglob corresponding to 
    the 1D result.
 
## DEPENDENCIES 
    'stack_each_output.qs': (Bash/Slurm script)- script that loops through each
            trial run output to create a single "stacked" file representing
            the results. The outputs are stored in 'stacked_dir'


## ARGUMENTS/INPUTS
    'Mglob': (int)- FUNWAVE Mglob parameter for all FUNWAVE runs
     
    'Nglob': (int)- FUNWAVE Nglob parameter for all FUNWAVE runs
    
    'no_time': (int)- Number of time steps in each FUNWAVE simulation. Note that 
            the number of time steps may differ by 1 for each output- choose the 
            lower number.
    
    'no_tri': (int)- Number of different trials run.
    
    'stacked_dir': (str)- Directory where stacked outputs are stored
    
    'array_dir': (str)- Directory where output numpy arrays are stored.

## OUTPUTS
    'data.npy': (numpy array)- numpy array of dimensions 
            [no_tri,no_time,Nglob,Mglob] containing all the eta values for the 
            FUNWAVE trial runs
    
    'data_1D.npy': (numpy array)- numpy array of dimensions [no_tri,no_time,Mglob] 
            containing all the eta values for the FUNWAVE trial runs. Note that 
            this assumes a 1D test case where Nglob = 3.


## GENERAL USE NOTES
    This probably makes sense to run in the HPC.
    
'''

#%% PACKAGES
import numpy as np
import os
#%% INPUTS
Mglob = 1024
Nglob = 3
no_time = 600
no_tri = 1000
stacked_dir = './stacked_files'
array_dir = './numpy_arrays' 

#%% SCRIPT
# Construct array for output
comp_out = np.zeros((no_tri,no_time,Nglob,Mglob))

# Loop trough number of trials
for j in range(1,no_tri+1):
    # Pull out file for each trial
    each_trial = np.loadtxt(f'{stacked_dir}/stacked_out_{j:05d}.txt')
    
    # Trim to consistent time (some trials go a second longer)
    if each_trial.shape[0] > no_time*Nglob:
        each_trial = each_trial[:-Nglob, :]
        
    # Reshape array to correct dimension
    each_trial = each_trial.reshape(no_time,Nglob,Mglob)
    
    # Append to output
    comp_out[j-1] = each_trial
    
    # Print progress
    print(f'Processing Trial {j}')
    
# Slice out middle
comp_out_1D = comp_out[:,:,1,:]

# Save to data.npy and data_1D.npy
os.makedirs(array_dir, exist_ok=True)
np.save(os.path.join(array_dir, 'data.npy'),comp_out)
np.save(os.path.join(array_dir, 'data_1D.npy'),comp_out_1D)



