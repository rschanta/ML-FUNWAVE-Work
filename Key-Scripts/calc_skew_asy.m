%{
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% VERSION- v 1.0.0
    Last edit: 4 January 2024
    Edit made: 
    Ryan Schanta
%}



%{ 
%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
This function calculates the skew and asymmetry of the time series of a
series of FUNWAVE outputs that has already been compressed to a numpy array
of size (num_trials,time_sim,Mglob). It can operate at all points or at
points specified by stations, and outputs to 2 txt files as tables.

%% Arguments
'comp_1D_npy': (str)- The name/path to the numpy array output by the script
    'compress_outputs.py'. It should be of the dimensions 
    (num_trials,time_sim,Mglob), assuming a 1D FUNWAVE setup. Reading this
    in requires the 'readNPY.m' function

%% Outputs
'skew_tab': (table as .txt)- plaintext table representing the skew at
    each station. The number of columns equals the number of stations
    specified (up to the entire model domain). The number of rows
    corresponds to the number of trials.
'asy_tab': (table as .txt)- plaintext table representing the asymmetry at
    each station. The number of columns equals the number of stations
    specified (up to the entire model domain). The number of rows
    corresponds to the number of trials.

%% General Use Notes
    This function relies on the 'readNPY.m' function as developed by {cite}

    Future plans to incorporate a better station file functionality
%}

function calc_skew_asy(comp_1D_npy)
    %% Read in the data
    eta = readNPY(comp_1D_npy);
    disp('File read successfully');
    
    %% Simulation Time
    time_sim = size(eta,2);
    
    %% Define Stations, Pull out Stations
    %sta = [1, 100, 200, 300, 400, 500:50:800. 825:25:1024];
    sta = 1:1024;
    eta_s = eta(:,:,sta);
    
    %% Subtract out mean
    eta_n = eta_s - mean(eta_s,2);
    
    %% Calculate the skew
        skew_n = mean(eta_n.^3,2); % numerator for skew
        skew_d = (mean(eta_n.^2,2)).^1.5; % denominator for skew/asymetry
        skew = skew_n./skew_d;
        disp('Done calculating skew');
    %% Calculate the asymmetry
        asy = zeros(1000,1,20);
        for j = 1:1000
            for k = 1:length(sta) 
                hn = imag(hilbert(eta_n(j,:,k)));
                hnn = hn'-ones(time_sim,1)*mean(hn);
                asy_n = mean(hnn.^3);
                asy_d = -(mean(eta_n(j,:,k).^2,2)).^1.5;
                asy(j,:,k) = asy_n/asy_d;
            end
        end
        disp('Done calculating asymmetry');
    
    %% Squeeze out time dimension
        skew  = squeeze(skew);
        asy = squeeze(asy);
    %% Write out as table
        col_names = arrayfun(@num2str, sta, 'UniformOutput', false);
        skew_tab = array2table(skew, 'VariableNames', col_names);
        asy_tab = array2table(asy, 'VariableNames', col_names);
        writetable(skew_tab,'skew_tab')
        writetable(asy_tab, 'asy_tab')
        disp('Done generating files');
end

