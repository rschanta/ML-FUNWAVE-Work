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
from sklearn.model_selection import train_test_split
#%% Class Definition

class FW_data_1D:
    ''' Preprocessed FW 1D model runs for ML applications'''
    
    '''
        Initialization:
            - Assigns name based on folder name
            - Loads in data from data_1D.npy file as numpy array
            - Loads in sumvars.txt and sumconst.txt
            - Assigns name based on folder name
            - Constructs the data table used for ML applications, using the 
                ratio up the sloped portion as an input called "ratio"
            
    '''
    def __init__(self,dir_FW):
        '''
            - `dir_FW`: Directory where data.npy, sumvars.txt, and 
                and sumconst.txt are found. Include / at end
        '''
        ## Give Name to Object
        self.name = dir_FW.rsplit('/',2)[1];
        
        ## Load in Data
        data = np.load(f'{dir_FW}data_1D.npy')
        self.sumvars = pd.read_csv(f'{dir_FW}sumvars.txt', delimiter=' ')
        self.sumconst = pd.read_csv(f'{dir_FW}sumconst.txt', delimiter=' ')
        skew = pd.read_csv(f'{dir_FW}/Skasy/skew_tab.txt', delimiter=',')
        asy = pd.read_csv(f'{dir_FW}/Skasy/asy_tab.txt', delimiter=',')
        self.start_t = pd.read_csv(f'{dir_FW}/Skasy/start_t_tab.txt', delimiter=',')
        
        ## Process Data_1D
        
        # Define ratio up the sloped portion (0-1)
        ratio = ratio = np.linspace(0,1,101)
        # Add to sumvars table
        data = pd.concat([self.sumvars] * 101)
        data['ratio'] = np.sort(np.tile(ratio, 1000))
        # Add position in Mglob
        data['pos'] = (1024 - data['Xslp'])*data['ratio'] + data['Xslp']
        data['pos'] = data['pos'].astype(int)

        # Add skew and asymmetry at each position
        skew = skew.values
        asy = asy.values
        data['skew'] = skew[data['iter']-1,data['pos']]
        data['asy'] = asy[data['iter']-1,data['pos']]
        
        self.data = data
        
        return
    

    
    ## TEST_TRAIN_SPLIT
    def test_train_split(self,test_size,random_seed=None):
        ''' Performs a test/train split using test_size as the proportion of 
            the data to the test_set. Can set seed # via random_seed'''
        X = self.data[['iter', 'SLP','Tperiod','AMP_WK','ratio']]
        y = self.data[['iter', 'skew','asy']]
        self.X_tr, self.X_te, self.y_tr, self.y_te = train_test_split(X, y, test_size=0.2, random_state=42)
        return
                
        
        
#%% Room to debug

dir_FW = "C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/"


validate = FW_data_1D(dir_FW)

#%%
validate.test_train_split(0.2,42)
#%%
data = validate.data

data_x = validate.X_tr
data_y = validate.y_tr
#validate.test_train_split(0.2,42)

#%% Linear Regression for Skew
# Sklearn utility
from sklearn.model_selection import train_test_split
from sklearn.metrics import r2_score
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
x_sk =  data_x[['SLP','Tperiod','AMP_WK','ratio']]
y_sk = data_y[['skew']]
mod = LinearRegression()
mod.fit(x_sk, y_sk)

## Test model on training data
y_sk_p = pd.DataFrame(mod.predict(x_sk), columns=['skew'])

r2sktr = r2_score(y_sk, y_sk_p)


#%% Neural Network for Skew
from keras.models import Sequential
from keras.layers import Dense

mod = Sequential()
mod.add(Dense(128, input_dim=4, activation='relu'))
mod.add(Dense(64, activation='relu'))
mod.add(Dense(1, activation='linear'))
## Compile and fit the model
mod.compile(loss='mean_squared_error', optimizer='adam', metrics=['mae'])
hist = mod.fit(x_sk, y_sk, validation_split=0.2, epochs = 10)

#%%
y_sk_p =  pd.DataFrame(mod.predict(x_sk), columns=['skew'])
r2sktr = r2_score(y_sk, y_sk_p)


data_xt = validate.X_te
data_yt = validate.y_te
x_skt =  data_xt[['SLP','Tperiod','AMP_WK','ratio']]
y_skt = data_yt[['skew']]


y_sk_pte =  pd.DataFrame(mod.predict(x_skt), columns=['skew'])
r2skte = r2_score(y_skt, y_sk_pte)