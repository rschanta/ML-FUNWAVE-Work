# -*- coding: utf-8 -*-
"""
Created on Sun Jan  7 13:09:35 2024

@author: rschanta
"""

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
        return
        
    def index_times(self,to,tf):
        ''' Indexes out times of the model run between to and tf 
            to return new object'''
        FW_indexed = copy.deepcopy(self)
            
        return FW_indexed.data[:,to:tf,:]
    
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

        return
                
        
        
#%% Room to debug

dir_FW = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"


validate = FW_data_1D(dir_FW)
validate.test_train_split(0.2,42)