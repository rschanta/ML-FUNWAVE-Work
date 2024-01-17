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
sys.path.append('C:/Users/rschanta/ML-Funwave-Work/ML-Work/NN')
from NN_Spatial import NN_spatial
from FW_Spatial import FW_Spatial
from ML_utils import compress_outputs


#%% VALIDATION DATA SET
dir_val = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"

FW_data = FW_Spatial(dir_val)
FW_data.test_train_split(0.2,42)

NN_skew = NN_spatial(FW_data)
NN_skew.fit('skew',10)

NN_asy= NN_spatial(FW_data)
NN_asy.fit('asy',10)

## Combine outputs
NN_summary = compress_outputs(NN_skew, NN_asy)
#%%
table = pa.Table.from_pandas(NN_summary)
pq.write_table(table, '../Model-Run-Data/validate/NN_summary.parquet')