%%% skew_asym_spatial.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 21 January 2024
Edit made: 
    - Modularized further to separate script from 'skew_asym.m' which
        operates on a single time series

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a FUNCTION

%% Description
This script calculates the skew and asymmetry at each point in a 1D FUNWAVE
model domain. The input MUST be a time series `eta` across a domain such
that:
    - NUMBER OF ROWS = TIME STEPS (temporal dimension)
    - NUMBER OF COLUMNS = MGLOB (spatial dimension)

%% Arguments/Inputs
'eta_field': (array)- data for a spatial time series of eta outputs
where
    - NUMBER OF ROWS = TIME STEPS
    - NUMBER OF COLUMNS = NUMBER OF GRID POINTS (MGLOB)

%% Outputs
'skew': (array)- The skew at each point in the model domain for the time
    series

'asy': (array)- The assymetry at each point in the model domain for the time
    series

'start_i': (array)- The starting point for the calculation, since times
    before the wave have actually reached the point are excluded.
    
%}

function ska = skew_asym_spatial(eta_field)
    
    %%% Convert to cell array where each cell is a time series
        eta_i = num2cell(eta_field,1);
    
    %%% Apply skasy function to each cell in cell array
        [skew, asy, start_i] = cellfun(@skew_asym, eta_i, 'UniformOutput',false);

    %%% Output as a matrix again
        ska.skew = cell2mat(skew);
        ska.asy = cell2mat(asy);
        ska.start_i = cell2mat(start_i);
    end
    





