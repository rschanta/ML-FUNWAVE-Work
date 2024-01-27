%%% skew_asym.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 26 January 2024
Edit made: 
    - Modularized code to keep skasy_asym.m as a function that operates on
        single time series

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a FUNCTION

%% Description
This function is used to calculate the skew and asymmetry of a wave time
series. It excludes the beginning portion of the time series where the
water may be still and not subject to any wave action

%% Arguments/Inputs
'eta': (1D array)- A time series of eta values

%% Outputs
'skew': (double)- The skew of the input time series

'asym': (double)- The asymmetry of the input time series

'start_i': (array)- The starting index for the calculation, since times
    before the wave have actually reached the point are excluded.
    
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [skew, asy, start_i] = skew_asym(eta)

    % Converts into row vector if not already
    eta = reshape(eta,1, []);

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

    % Calculate and output
    skew = sk_num/denom;
    asy = asy_num/denom;
    
end



