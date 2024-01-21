%%
function [skew, asy, start_i] = skasy(eta)
%{  
    Description: Calculates the skew and asymmetry for each point in the
        model domain for a given trial

    Arguments:
        'eta': An array corresponding to a wave time series

    Outputs:
        'eta': (array)- 1x3 array of the form [skew, asymmetry, time_start] 
  
%}
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
    start_i = start_i;
    
end