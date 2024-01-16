#%% Preprocess_data_1D.py

#%% DEV HISTORY 
'''
    Last edit: 16 January 2024
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


#%% Relevant Libraries
import numpy as np
import pandas as pd
import copy

#%% Class Definition

class FW_data_1D:
    ''' Preprocessed FW 1D model runs for ML applications'''
    
    '''
        Initialization:
            - Loads in data from data_1D.npy file as numpy array
            - Loads in sumvars.txt and sumconst.txt as pandas dataframes
            - Assigns name based on folder name
            
    '''
    def __init__(self,dir_FW):
        '''
            - `dir_FW`: Directory where data.npy, sumvars.txt, and 
                and sumconst.txt are found. Include / at end
        '''
        self.name = dir_FW.rsplit('/',2)[1];
        self.data = np.load(f'{dir_FW}data_1D.npy')
        self.sumvars = pd.read_csv(f'{dir_FW}sumvars.txt', delimiter=' ')
        self.sumconst = pd.read_csv(f'{dir_FW}sumconst.txt', delimiter=' ')
        
        ## Process the skew/asy/start a bit
        # Convert from array to pandas DataFrame
        self.skew = pd.DataFrame(np.loadtxt(f'{dir_FW}/Skasy/skew_tab.txt',delimiter=','))
        self.asy = pd.DataFrame(np.loadtxt(f'{dir_FW}/Skasy/asy_tab.txt',delimiter=','))
        self.start_t = pd.DataFrame(np.loadtxt(f'{dir_FW}/Skasy/start_t_tab.txt',delimiter=','))
        # Add iter column
        iter_col = np.arange(1, 1001)  
        self.skew.insert(0,'iter', iter_col)
        self.asy.insert(0,'iter', iter_col)
        self.start_t.insert(0,'iter', iter_col)
        
        return
    
    ## INDEX_TIMES    
    def index_times(self,to,tf):
        ''' Indexes out times of the model run between to and tf 
            to return new object
        '''
        FW_indexed = copy.deepcopy(self)
            
        return FW_indexed.data[:,to:tf,:]
    
    ## TEST_TRAIN_SPLIT
    def test_train_split(self,test_size,random_seed=None):
        ''' Performs a test/train split using test_size as the proportion of 
            the data to the test_set. Can set seed # via random_seed'''

        if random_seed is not None:
            np.random.seed(random_seed)
            
        # Get iterations of test and train data points
        num_trials = self.data.shape[0]
        self.te_i = np.random.choice(np.arange(1, num_trials+1), size=int(num_trials*test_size), replace=False) 
        self.tr_i = np.setdiff1d(np.arange(1, num_trials+1), self.te_i) # train indices
        
        # Set test and train data accordingly
        self.data_te = self.data[self.te_i-1,:,:];
        self.data_tr = self.data[self.tr_i-1,:,:];
        
        # Set test and train sumvars accordingly
        self.sumvars_te = self.sumvars[self.sumvars['iter'].isin(self.te_i)]
        self.sumvars_tr = self.sumvars[self.sumvars['iter'].isin(self.tr_i)]
        
        # Set test and train skasy calculations accordingly
        
        self.skew_te = self.skew[self.skew['iter'].isin(self.te_i)]
        self.skew_tr = self.skew[self.skew['iter'].isin(self.tr_i)]
        
        self.asy_te = self.asy[self.asy['iter'].isin(self.te_i)]
        self.asy_tr = self.asy[self.asy['iter'].isin(self.tr_i)]
        
        self.start_t_te = self.start_t[self.start_t['iter'].isin(self.te_i)]
        self.start_t_tr = self.start_t[self.start_t['iter'].isin(self.tr_i)]
    

        return
                
        
        
#%% Room to debug

dir_FW = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"


validate = FW_data_1D(dir_FW)
validate.test_train_split(0.2,42)

validate.skew_te