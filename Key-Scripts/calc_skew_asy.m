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
calc_skew_asy_use("C:/Users/rschanta/ML-Funwave-Work/Model-Run-Data/validate/data_1D.npy")

function calc_skew_asy_use(comp_1D_npy)
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

%% Relevant Helper Functions Needed
function data = readNPY(filename)
% Function to read NPY files into matlab.
% *** Only reads a subset of all possible NPY files, specifically N-D arrays of certain data types.
% See https://github.com/kwikteam/npy-matlab/blob/master/tests/npy.ipynb for
% more.
%

[shape, dataType, fortranOrder, littleEndian, totalHeaderLength, ~] = readNPYheader(filename);

if littleEndian
    fid = fopen(filename, 'r', 'l');
else
    fid = fopen(filename, 'r', 'b');
end

try

    [~] = fread(fid, totalHeaderLength, 'uint8');

    % read the data
    data = fread(fid, prod(shape), [dataType '=>' dataType]);

    if length(shape)>1 && ~fortranOrder
        data = reshape(data, shape(end:-1:1));
        data = permute(data, [length(shape):-1:1]);
    elseif length(shape)>1
        data = reshape(data, shape);
    end

    fclose(fid);

catch me
    fclose(fid);
    rethrow(me);
end
    end

function [arrayShape, dataType, fortranOrder, littleEndian, totalHeaderLength, npyVersion] = readNPYheader(filename)
% function [arrayShape, dataType, fortranOrder, littleEndian, ...
%       totalHeaderLength, npyVersion] = readNPYheader(filename)
%
% parse the header of a .npy file and return all the info contained
% therein.
%
% Based on spec at http://docs.scipy.org/doc/numpy-dev/neps/npy-format.html

fid = fopen(filename);

% verify that the file exists
if (fid == -1)
    if ~isempty(dir(filename))
        error('Permission denied: %s', filename);
    else
        error('File not found: %s', filename);
    end
end

try
    
    dtypesMatlab = {'uint8','uint16','uint32','uint64','int8','int16','int32','int64','single','double', 'logical'};
    dtypesNPY = {'u1', 'u2', 'u4', 'u8', 'i1', 'i2', 'i4', 'i8', 'f4', 'f8', 'b1'};
    
    
    magicString = fread(fid, [1 6], 'uint8=>uint8');
    
    if ~all(magicString == [147,78,85,77,80,89])
        error('readNPY:NotNUMPYFile', 'Error: This file does not appear to be NUMPY format based on the header.');
    end
    
    majorVersion = fread(fid, [1 1], 'uint8=>uint8');
    minorVersion = fread(fid, [1 1], 'uint8=>uint8');
    
    npyVersion = [majorVersion minorVersion];
    
    headerLength = fread(fid, [1 1], 'uint16=>uint16');
    
    totalHeaderLength = 10+headerLength;
    
    arrayFormat = fread(fid, [1 headerLength], 'char=>char');
    
    % to interpret the array format info, we make some fairly strict
    % assumptions about its format...
    
    r = regexp(arrayFormat, '''descr''\s*:\s*''(.*?)''', 'tokens');
    if isempty(r)
        error('Couldn''t parse array format: "%s"', arrayFormat);
    end
    dtNPY = r{1}{1};    
    
    littleEndian = ~strcmp(dtNPY(1), '>');
    
    dataType = dtypesMatlab{strcmp(dtNPY(2:3), dtypesNPY)};
        
    r = regexp(arrayFormat, '''fortran_order''\s*:\s*(\w+)', 'tokens');
    fortranOrder = strcmp(r{1}{1}, 'True');
    
    r = regexp(arrayFormat, '''shape''\s*:\s*\((.*?)\)', 'tokens');
    shapeStr = r{1}{1}; 
    arrayShape = str2num(shapeStr(shapeStr~='L'));

    
    fclose(fid);
    
catch me
    fclose(fid);
    rethrow(me);
end
end
end

