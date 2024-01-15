%%% Name of Function/Script

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 15 January 2024
Edit made: 
    - Added preamble and cleaned up file directory notation

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
'dir_data_1D': (str)- name of folder containing `data_1D.npy`.

%% Outputs
'skew_tab.txt': (CSV .txt file)- comma delimted CSV .txt file where each
        row corresponds to a trial and each column corresponds to the
        position in Mglob. Contains the skew at each of these points. Does
        not have a header or row labels.
'asy_tab.txt': (CSV .txt file)- comma delimted CSV .txt file where each
        row corresponds to a trial and each column corresponds to the
        position in Mglob. Contains the asymmetry at each of these points. 
        Does not have a header or row labels.
'start_t_tab.txt': (CSV .txt file)- comma delimted CSV .txt file where each
        row corresponds to a trial and each column corresponds to the
        position in Mglob. Contains the asymmetry at each of these points. 
        Does not have a header or row labels.


%% General Use Notes
    All outputs are generated in a subdirectory named `skasy` within the
    folder specified by 'dir_data_1D'
    
%}


%% Inputs
dir_data_1D = 'validate';

%% Read in eta_file
dir_to = fullfile('..','Model-Run-Data',dir_data_1D, 'data_1D.npy');
eta = readNPY(dir_to);

%% Generate matrices for skew, asymmetry, and steady time
    % Get number of trials and Mglob
        no_tri = size(eta,1);
        Mglob = size(eta,3);
    % Matrix outputs
        skew_tab = zeros(no_tri,Mglob); 
        asy_tab = zeros(no_tri,Mglob); 
        start_t_tab = zeros(no_tri,Mglob); 

%% Loop through each trial
for j = 1:no_tri
    % Squeeze out a trial, transpose, and convert to cell
        eta_i = squeeze(eta(j,:,:))';
        eta_i = num2cell(eta_i,2);

    % Apply skasy function to each cell using cellfun
        skasy = cellfun(@calc_skasyF, eta_i, 'UniformOutput',false);
    
    % Convert to matrix, transpose, and output to each table
        skasy = cell2mat(skasy)';
        skew_tab(j,:) = skasy(1,:);
        asy_tab(j,:) = skasy(2,:);
        start_t_tab(j,:) = skasy(3,:);
        disp(['Processing Trial ', num2str(j)]); % display progress
end
%% Save Outputs
    % Output directory
    dir_out = fullfile('..','Model-Run-Data',dir_data_1D, 'skasy');
    
    % Generate output directory if not already there
    if ~isfolder(dir_out)
        mkdir(dir_out);
    end

    % Write matrices to files
        writematrix(skew_tab,fullfile(dir_out,'skew_tab.txt'))
        writematrix(asy_tab,fullfile(dir_out,'asy_tab.txt'))
        writematrix(start_t_tab,fullfile(dir_out,'start_t_tab.txt'))


%% Function to Calculate Skew and Asymmetry
function skasy = calc_skasyF(eta)
%{  
    Description: Calculates the skew and asymmetry for each point in the
        model domain for a given trial

    Arguments:
        'eta': (cell array)- [1,no_time] array corresponding to the 
            a time series of a wave at a point in the model domain

    Outputs:
        'eta': (array)- 1x3 array of the form [skew, asymmetry, time_start] 
    
    Notes: This is intended to used in conjunction with the `cellfun`
        function which applies a function to every cell within a cell
        array. This, the cell array `eta_i` of dimension {Mglob,1} is used
        above.
            

%}

    % Cut out any dead time at the beginning
        start_i = find(abs(eta) > 0.001 * max(abs(eta)), 1);
        eta = eta(start_i:end);

    % Subtract out mean
        eta_n = eta - mean(eta); % Subtract out mean

    % Denominator for skew and asymmetry
        denom = (mean(eta_n.^2))^(1.5); 

    % Numerator for skew
        sk_num = mean(eta_n.^3);
    
    % Numerator for Asymmetry
        hn = imag(hilbert(eta_n));
        hnn = hn'-ones(length(eta_n),1)*mean(hn);
        asy_num = mean(hnn.^3);

    % Pacakage together for output
    skasy = [sk_num/denom, asy_num/denom,start_i];
    
end






