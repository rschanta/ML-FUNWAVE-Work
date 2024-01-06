#%% Header
'''
    compress_outputs.py
    VERSION 1.0.0

    LAST EDIT: 4 January 2024
    
    Operating Notes
        - Relies on outputs of stack_each_output.qs in some directory given by 
            the variable 'stacked_dir'
        - Outputs a single, large numpy array of dimensions
            (trial_no, time_sim, Nglob, Mglob)
        
        
'''

#%% Packages
import numpy as np

#%% Inputs
Mglob = 1024
Nglob = 3
time_sim = 600; # Simulation time
num_trials = 1000; # Number of trials 
stacked_dir = './'; # Directory where each stacked model run output is stored

#%% Loop through all files
compressed_output = np.zeros((3,time_sim,Nglob,Mglob))
for j in range(1,num_trials+1):
    each_trial = np.loadtxt(f'bulk_out{j:05d}.txt')
    if each_trial.shape[0] > time_sim*3:
        each_trial = each_trial[:-Nglob, :]
    each_trial = each_trial.reshape(time_sim,Nglob,Mglob)
    compressed_output[j-1] = each_trial
    
np.save('compressed_output.npy',compressed_output)

#%% Loading compressed output
import numpy as np
compressed_HPC = np.load('C:/Users/rschanta/FUNWAVE_OUTPUTS/1_3_work/compressed_output_HPC.npy')

# Slicing out the middle
compressed_HPC_slice = compressed_HPC[:,:,1,:]
np.save('compressed_output_1D.npy',compressed_HPC_slice)

