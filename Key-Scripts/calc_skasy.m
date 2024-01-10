%% Read in eta_file
dir_to = 'C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/';
eta = readNPY([dir_to,'data_1D.npy']);

%% Generate matrices for skew, asymmetry, and steady time
skew_tab = zeros(1000,1024); asy_tab = zeros(1000,1024); steady_tab = zeros(1000,1024); 
for j = 1:1000
    % Squeeze out a trial 
        eta_i = squeeze(eta(j,:,:))';
        eta_i = num2cell(eta_i,2);

    % Apply skasy function to each cell
        skasy = cellfun(@calc_skasy, eta_i, 'UniformOutput',false);
    
    % Convert to matrix and output
        skasy = cell2mat(skasy)';
        skew_tab(j,:) = skasy(1,:);
        asy_tab(j,:) = skasy(2,:);
        steady_tab(j,:) = skasy(3,:);
        disp(j)
end
%% Save Out
dir_out = fullfile(dir_to,'Skasy/');
if ~isfolder(dir_out)
    mkdir(dir_out);
end

writematrix(skew_tab,fullfile(dir_out,'skew_tab.txt'))
writematrix(asy_tab,fullfile(dir_out,'asy_tab.txt'))
writematrix(steady_tab,fullfile(dir_out,'steady_tab.txt'))


%% Function to Calculate Skew and Asymmetry
function skasy = calc_skasy(eta)
%{  
    CALC_SKASY: Calculates the skew and asymmetry of a time series given by
        `eta` during the time when

    arguments:
        - eta: a 3D array (num_trials, time_sim, Mglob) from a 
            data_1D.npy file

    outputs:
        -skasy: a 1x3 array of the form [skew, asymmetry, time_start]
            

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

    skasy = [sk_num/denom, asy_num/denom,start_i];
    
end






