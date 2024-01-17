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

## Machine Learning Modules
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression

## Custom Modules
sys.path.append('C:/Users/rschanta/ML-Funwave-Work/ML-Work/Preprocessing')
from FW_data_1D import FW_data_1D


#%% Define Class
class LR_spatial:
    '''
        Initialization:
            - Loads in data from a FW_data_1D object

    '''
    def __init__(self,FW_data_1D):
        self.data = FW_data_1D
        return
    
    def fit_LR(self, skasy):
        x_te =   self.data[['SLP','Tperiod','AMP_WK','ratio']]
        y_te = self.data[[skasy]]
        mod = LinearRegression()
        mod.fit(x_sk, y_sk)

        ## Test model on training data
        y_sk_p = pd.DataFrame(mod.predict(x_sk), columns=['skew'])

        r2sktr = r2_score(y_sk, y_sk_p)
        
        ## Prepare outputs
    
#%% Space to debug

dir_FW = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"


validate = FW_data_1D(dir_FW)
#validate.test_train_split(0.2,42)

#%%
Xtrain = validate.sumvars
Yrain = validate.skew

#%%
ratio = np.linspace(0,1,101)
#%% Tile it up

data = pd.concat([Xtrain] * 101)
data['ratio'] = np.sort(np.tile(ratio, 1000))
data['pos'] = (1024 - data['Xslp'])*data['ratio'] + data['Xslp']
#X_train_tiled2['pos'] = X_train_tiled2['pos'].replace(np.inf, 0)
data['pos'] = data['pos'].astype(int)
#data['skew'] = Yrain.iloc(data['iter']-1,data['pos'])
#merged_data = pd.merge(X_train_tiled2, Yrain, on=['iter', 'pos'], how='left')

foo = Yrain.values
data['skew'] = foo[data['iter']-1,data['pos']]



