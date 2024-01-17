# -*- coding: utf-8 -*-
"""
Created on Tue Jan 16 20:13:06 2024

@author: rschanta
"""

#%% Load modules
import sys

## Data Science Modules
import numpy as np
import pandas as pd


## Custom Modules
sys.path.append('C:/Users/rschanta/ML-Funwave-Work/ML-Work/Preprocessing')
sys.path.append('C:/Users/rschanta/ML-Funwave-Work/ML-Work/LR')
from LR_Spatial import LR_spatial
from FW_Spatial import FW_Spatial


#%% VALIDATION DATA SET
dir_val = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"

FW_val = FW_Spatial(dir_val)
FW_val.test_train_split(0.2,42)

LR_skew_val = LR_spatial(FW_val)
LR_skew_val.fit('skew')

LR_asy_va= LR_spatial(FW_val)
LR_asy_va.fit('asy')

#%%
