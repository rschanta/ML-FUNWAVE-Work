%%
%{
This file reads in the data published by Mickey et al in "A Database of 
Topo-Bathy Cross-Shore Profiles and Characteristics for U.S. Atlantic and 
Gulf of Mexico Sandy Coastlines". It (i) reads in the full profile, cuts it 
off at the zero-crossing to generate the profile underwater (ii), and then
interpolates these profiles to a grid of 1024 (iii). These 3 profiles are
then stored to a stucture with the variables 'Xshore' and 'Elevation', with
the affixes 'raw', 'cut', and 'int' correspondingly.
%}

%%
clear 
clc
close all

dir_to = 'C:/Users/rschanta/ML-Funwave-Work/Bathymetry-Data/US_GC_data/';

%%
Xshore_raw = {}; Xshore_cut = {}; Xshore_int = []; 
Elevation_raw = {}; Elevation_cut = {}; Elevation_int = []; 
latlong = [];
for j = 1:3786
    try
        % Read in data
        Xshore_raw_i = h5read([dir_to,'Profile_data.h5'],['/Profile/ID_',num2str(j),'/Xshore']);
        Elevation_raw_i = h5read([dir_to,'Profile_data.h5'],['/Profile/ID_',num2str(j),'/Elevation']);
        lat_i = h5read([dir_to,'Profile_data.h5'],['/Profile/ID_',num2str(j),'/lat']);
        long_i = h5read([dir_to,'Profile_data.h5'],['/Profile/ID_',num2str(j),'/lon']);

        % Store raw profiles
        Xshore_raw{end+1} = Xshore_raw_i;
        Elevation_raw{end+1} = Elevation_raw_i;

        % Store latitude and longitude
        latlong = [latlong; lat_i, long_i];

        % Find zero crossings and index out
        zero_cross = (Elevation_raw_i(1:end-1) .* Elevation_raw_i(2:end)) <= 0;
        zero_cross_i = find(zero_cross);

        Xshore_cut_i = Xshore_raw_i(1:zero_cross_i(1));
        Elevation_cut_i = Elevation_raw_i(1:zero_cross_i(1));

        % Append to cell arrays
        Xshore_cut{end+1} = Xshore_cut_i;
        Elevation_cut{end+1} = Elevation_cut_i;

        % Apply interpolation
        len_int = 1024; % interpolate to 1024 points
        Xshore_int_i = linspace(Xshore_cut_i(1), Xshore_cut_i(end), len_int);
        Xshore_int = [Xshore_int; Xshore_int_i];

        Elevation_int_i = interp1(Xshore_cut_i, Elevation_cut_i, Xshore_int_i, "linear");
        Elevation_int = [Elevation_int; Elevation_int_i];

        
    catch
        disp('Profile not found');
    end

end

%% Sort the cell array and matrix by length of profile
% Get lengths of each array in the cell array
Xshore_lens = cellfun(@length, Xshore_cut);
[~, sortedIndices] = sort(Xshore_lens);

% Reorder the cell arrays based on sorted indices
Xshore_raw = Xshore_raw(sortedIndices);
Elevation_raw = Elevation_raw(sortedIndices);

Xshore_cut = Xshore_cut(sortedIndices);
Elevation_cut = Elevation_cut(sortedIndices);

% Reorder the matrices based on sorted indices
latlong_s = latlong(sortedIndices,:);
Xshore_int_s = Xshore_int(sortedIndices, :);
Elevation_int_s = Elevation_int(sortedIndices, :);

%% Package into structure for output to save
    % Raw Profiles
        US_GC_Processed.Xshore_raw = Xshore_raw;
        US_GC_Processed.Elevation_raw = Elevation_raw;
    % Latitude and Longitude
        US_GC_Processed.latlong = latlong_s;
    % Cutoff Profiles
        US_GC_Processed.Xshore_cut = Xshore_cut;
        US_GC_Processed.Elevation_cut = Elevation_cut;
    % Interpolated profiles
        US_GC_Processed.Xshore_int = Xshore_int_s;
        US_GC_Processed.Elevation_int = Elevation_int_s;
    % Save out
        save([dir_to, 'US_GC_Processed.mat'],"US_GC_Processed");


