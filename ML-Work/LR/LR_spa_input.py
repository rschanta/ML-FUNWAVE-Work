# -*- coding: utf-8 -*-
"""
Created on Sun Jan  7 14:42:29 2024

@author: rschanta
"""
#%% Load modules
import sys

## Data Science Modules
import numpy as np
import pandas as pd

## Custom Modules
sys.path.append('C:/Users/rschanta/ML-Funwave-Work')
from FW_data_1D import FW_data_1D


#%% Define Class
class LR_spa_input:
    '''
        Initialization:
            - Loads in data from a FW_data_1D object
            - Fits linear regression model for skew/asymmetry at a point based
                on slope, amplitude, period, and position
    '''
    def __init__(self,FW_data_1D):
        self.data = FW_data_1D
        return
    
#%% Space to debug

dir_FW = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"


validate = FW_data_1D(dir_FW)
validate.test_train_split(0.2,42)   
    