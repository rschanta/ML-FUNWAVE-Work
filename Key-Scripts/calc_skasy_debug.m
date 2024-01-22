%%% calc_skasy.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 21 January 2024
Edit made: 
    - Cleaned up skasy function itself to reside in startup.m to ensure
    same skasy function is being used anywhere.
    - skasy.m now takes in an eta field of [time_steps x Mglob] dimension
    - So the loop here only really serves to loop through all the different
        trial runs.

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a SCRIPT

%% Description
This script calculates the skew and asymmetry of the wave time series at
each point in the model domain for an ensemble of 1D FUNWAVE model runs. It
outputs separate tables for skew, asymmetry, and the starting time for
analysis (it excludes the portion of the time series before the wave has
propagated to the given point.

%% Dependencies
'readNPY()': (MATLAB function)-  function to read numpy arrays into MATLAB. 
        Provided via the `npy-matlab` repository at 
        https://github.com/kwikteam/npy-matlab. Function and all required 
        dependenceis found in `Helper-Functions` directory at the root.
'compressed_outputs.py': (Python script)- function used to generate the
        inputs `data_1D.npy`. See below.


%% Arguments/Inputs
'data_1D.npy': (numpy array)- numpy array storing the compressed 1D FUNWAVE 
        Model outputs as calculated by the script `compressed_outputs.py`.
        It is an array of size [no_tri, no_time, Mglob]. It MUST be named
        `data_1D.npy`. 
'dir_data': (str)- directory to data_1D.npy is stored

%% Outputs
'{var}_tab.txt': (CSV .txt file)- comma delimted CSV .txt file where each
        row corresponds to a trial and each column corresponds to the
        position in Mglob. Contains the {var} at each of these points. The
        first column here is "iter" 
'skasy.mat': (MATLAB structure)- MATLAB structure containing the tables in
    .txt files.

%% General Use Notes
    All outputs are generated in a subdirectory named `skasy` within the
    folder specified by 'dir_data_1D'
    
%}


%% Inputs
dir_data = fullfile('..','Model-Run-Data','validate');

%% Read in eta_file
dir_to = fullfile(dir_data, 'data_1D.npy');
eta = readNPY(dir_to);

%% Generate matrices for skew, asymmetry, and steady time
    % Get number of trials and Mglob
        no_tri = size(eta,1);
        Mglob = size(eta,3);
    % Matrix outputs
        skasy_arr = zeros(3,no_tri,Mglob); 

%% Loop through each trial
for j = 1:8
    % Squeeze out a trial
        eta_field_j = squeeze(eta(j,:,:));
    % Calculate skasy
        [skew_i, asy_i, start_ii] = skasy(eta_field_j);
    % Store to array output
        skasy_arr(1,j,:) = skew_i;
        skasy_arr(2,j,:) = asy_i;
        skasy_arr(3,j,:) = start_ii;
    % Display progress
        disp(['Working on Trial ', num2str(j)])

end
%%
%%% Convert each to a table and struct and save
    dir_out = fullfile(dir_data, 'skasy');
    s = struct(); 
        s = output_skasy(skasy_arr,1,dir_out,'skew_tab',s);
        s = output_skasy(skasy_arr,2,dir_out,'asy_tab',s);
        s = output_skasy(skasy_arr,3,dir_out,'start_t_tab',s);
    save(fullfile(dir_out,'skasy.mat'),'s');
    
%%% Helper function for output
function stru = output_skasy(arr,ind,dir_out, name,stru)
    % Convert to table and add iteration number column
        tab = array2table(squeeze(arr(ind,:,:)));
        tab = addvars(tab, (1:size(tab,1))' , 'Before', 1, 'NewVariableNames', 'iter');
    %%% Create dir_out if it doesn't exist
        if ~isfolder(dir_out)
             mkdir(dir_out);
        end
    %%% Write file based on type
        writetable(tab,fullfile(dir_out,[name,'.txt']))
        stru.(name) = tab;
end




