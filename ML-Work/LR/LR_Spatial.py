#%% LR_Spatial.py

#%% DEV HISTORY 
'''
    Last edit: 16 January 2024
    Edit made: 
        - Structured to streamline data tables for ML 
        - Incorporated the idea of the ratio

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
    'FW_spatial.py': (.m script)- script in ../Preprocessing defining the 
            class FW_spatial, which preprocesses data
            
## ARGUMENTS/INPUTS
    'dir_FW': (str)- The FW_data_2D class requires the directory where 
            'data_1D.npy', 'sumconst.txt', and 'sumvars.txt' are stored, in 
            addition to the 'Skasy' subdirectory that contains the results
            from 'calc_skasy.m' as described above.

## OUTPUTS (fields of the class)
    This is the class file for FW_data_1D, which contains the following methods
            and attributes:
         
    # ATTRIBUTES
        'name': (str)- name taken from folder of dir_FW
                            
    # METHODS
        'test_train_split': 

## GENERAL USE NOTES
    This is a class definition. Import the module into whatever script it 
    needs to be used in.
    
'''
#%% Load modules
import sys

## Data Science Modules
import numpy as np
import pandas as pd

## Machine Learning Modules

from sklearn.metrics import r2_score
from sklearn.linear_model import LinearRegression

## Custom Modules
sys.path.append('C:/Users/rschanta/ML-Funwave-Work/ML-Work/Preprocessing')
from FW_Spatial import FW_Spatial
from Predictions import predictions

#%%
p = predictions()

#%% Class Definition
class LR_spatial:
    '''
        Initialization:
            - Loads in data from a FW_Spatial object

    '''
    def __init__(self,FW_Spatial):
        self.data = FW_Spatial
        self.p = predictions()
        return
    
    def fit(self,skasy):
        ## Pull out testing and training inputs/outputs
        X_tr = self.data.X_tr[['SLP','Tperiod','AMP_WK','ratio']]
        y_tr = self.data.y_tr[[skasy]]
        
        X_te = self.data.X_te[['SLP','Tperiod','AMP_WK','ratio']]
        y_te = self.data.y_te[[skasy]]
        
        ## Define the linear regression model
        mod = LinearRegression()
        
        ## Fit the linear regression model on the training data
        mod.fit(X_tr, y_tr)

        ## Evaluate performance of the model on the training data
        self.p.ytr = pd.DataFrame(mod.predict(X_tr), columns=[skasy])
        self.p.tr_r2 = r2_score(y_tr, self.p.ytr)
        
        ## Evaluate performance of the model on the testing data
        self.p.yte = pd.DataFrame(mod.predict(X_te), columns=[skasy])
        self.p.te_r2 = r2_score(y_te, self.p.yte)
        
        return
    
#%% Space to Debug
dir_FW = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"

FW_data = FW_Spatial(dir_FW)
FW_data.test_train_split(0.2,42)

LR_skew = LR_spatial(FW_data)
LR_skew.fit('skew')

LR_asy= LR_spatial(FW_data)
LR_asy.fit('asy')

#%%
foo = LR_asy.p.tr_r2
fee = LR_asy.p.te_r2