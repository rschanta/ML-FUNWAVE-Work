#%% ML_utils.py
#%% 
import pandas as pd
import numpy as np

#%%
def compress_outputs(ML_skew,ML_asy):
    ## Get inputs
    xtr = ML_skew.data.X_tr.reset_index()[['iter','SLP','Tperiod','AMP_WK','ratio', 'pos']]
    xte = ML_skew.data.X_te.reset_index()[['iter','SLP','Tperiod','AMP_WK','ratio', 'pos']]

    ## Get Ground Truths
    ytr = ML_skew.data.y_tr.reset_index()[['skew','asy']]
    ytr.columns = ['skew_TRUE','asy_TRUE']
    yte = ML_skew.data.y_te.reset_index()[['skew','asy']]
    yte.columns = ['skew_TRUE','asy_TRUE']

    ## Get ML Predictions
    pytr_sk = ML_skew.p.ytr.reset_index()[['skew']]
    pyte_sk = ML_skew.p.yte.reset_index()[['skew']]
    pytr_asy = ML_asy.p.ytr.reset_index()[['asy']]
    pyte_asy = ML_asy.p.yte.reset_index()[['asy']]


    ## Combine Nicely
    comb_tr = pd.concat([xtr, ytr, pytr_sk, pytr_asy], axis=1)
    comb_te = pd.concat([xte, yte, pyte_sk, pyte_asy], axis=1)
    stacked_df = pd.concat([comb_tr, comb_te], axis=0, ignore_index=True)
    sorted_df = stacked_df.sort_values(by=['iter', 'pos'])
    
    return sorted_df



