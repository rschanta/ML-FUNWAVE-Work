%%% Name of Function/Script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 21 January 2024
Edit made: 
    - Cleaned up skasy function itself to reside in startup.m to ensure
    same skasy function is being used anywhere.
    - skasy.m contains the function now
    - skasy.m is less sensitive to 

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
        skew = zeros(no_tri,Mglob); 
        asy = zeros(no_tri,Mglob); 
        start_t = zeros(no_tri,Mglob); 

%% Loop through each trial
for j = 1:no_tri
    % Squeeze out a trial, transpose, and convert to cell array
        eta_i = squeeze(eta(j,:,:))';
        eta_i = num2cell(eta_i,2);

    % Apply skasy function to each cell using cellfun
        [skew_i, asy_i, start_ii] = cellfun(@skasy, eta_i, 'UniformOutput',false);
    
    % Convert to matrix, transpose, and output to each table
        skew(j,:) =  cell2mat(skew_i)';
        asy(j,:) = cell2mat(asy_i)';
        start_t(j,:) = cell2mat(start_ii)';
        disp(['Processing Trial ', num2str(j)]); % display progress
end


%% Save Outputs
    % Output directory for .txt files and structure
        dir_out = fullfile(dir_data, 'skasy');
        s = struct();
    % Call output_skasy
        s = output_skasy(skew,s,dir_out,'skew_tab');
        s = output_skasy(asy,s,dir_out,'asy_tab');
        s = output_skasy(start_t,s,dir_out,'start_t_tab');
    % Save Structure
        save(fullfile(dir_out,'skasy.mat'),'s');

%% Helper Functions
function stru = output_skasy(arr,stru,dir_out,name)
    %%% Convert to tabular format
        tab = array2table(arr);
        tab = addvars(tab, (1:size(tab,1))' , 'Before', 1, 'NewVariableNames', 'iter');
    %%% Create dir_out if it doesn't exist
        if ~isfolder(dir_out)
             mkdir(dir_out);
        end
    %%% Write file based on type
        writetable(tab,fullfile(dir_out,[name,'.txt']))
        stru.(name) = tab;
end




