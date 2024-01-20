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

## Big Data
import pyarrow as pa
import pyarrow.parquet as pq


## Custom Modules
#sys.path.append('C:/Users/rschanta/ML-Funwave-Work/ML-Work/Preprocessing')
sys.path.append('C:/Users/rschanta/ML-Funwave-Work/ML-Work/LR')
from LR_Spatial import LR_spatial
from FW_Spatial import FW_Spatial
from ML_utils import compress_outputs


#%% VALIDATION DATA SET
dir_val = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"

FW_val = FW_Spatial(dir_val)
FW_val.test_train_split(0.2,42)

LR_skew_val = LR_spatial(FW_val)
LR_skew_val.fit('skew')

LR_asy_va= LR_spatial(FW_val)
LR_asy_va.fit('asy')

## Combine outputs
LR_summary = compress_outputs(LR_skew_val, LR_asy_va)
#%%
table = pa.Table.from_pandas(LR_summary)
pq.write_table(table, '../Model-Run-Data/validate/LR_summary.parquet')