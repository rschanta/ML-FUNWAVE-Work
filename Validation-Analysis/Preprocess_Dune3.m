%%% Preprocess_Dune3.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 16 January 2024
Edit made: 
    - Added preamble
    - Corrected inverted profiles
    - Moved bathy generation to separate script FW_BathyGen_Dune3

%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a SCRIPT

%% Description
This script takes all of the Dune3 Data and condenses it down to 2 MATLAB
structures, D3a and D3c, containing "all" the data (D3a) and a "condensed"
version (D3c). D3c processes data such that it is more suitable for FUNWAVE
model inputs/validation.

%% Dependencies
'../Validation-Data/DUNE3_data': (folder) - unzipped folder containing the
        Dune3 data as given by Jay.

%% Arguments/Inputs
none, provided that the '../Validation-Data/DUNE3_data' is there

%% Outputs
'D3a': (.mat structure)- all of the data from the Dune3 dataset, which
        contains a series of structures for each Trial which then each
        contain the following 3 structures
            - raw_data: Data as given from field. Contains a structure for 
                    each trial including:
                        - trial_name
                        - bed_before
                        - bed_after
                        - WG_name
                        - WG_loc_x
                        - ADV_name
                        - ADV_loc_xyz
                        - t
                        - t0
                        - t_end
                        - eta
                        - u
                        - v
                        - w
                        - MWL
                        - Hrms
                        - Hmo
                        - H3
            - filtered_data: Data as processed by Benjamin, including:
                        - trial_name
                        - bed_num_before
                        - bef_num_after
                        - wave_property_name
                        - wave_property
                        - loc_x
                        - t
                        - t0
                        - t_end
                        - eta
                        - eta_i
                        - eta_r
                        - MWL
                        - Hrms
                        - Hmo
                        - H3
                        - Hrms_i
                        - Hmo_i
                        - H3_i
            - wave_condition: Wave data as measured "offshore"
                        - trial_name
                        - Hs
                        - Tp
                        - h
                        - eta_max
                        - eta_min

'D3c': (.mat structure)- abbreviated data from the Dune3 dataset, which
        contains a series of structures for each Trial containing the
        following parameters. Note, some of this are intended for FUNWAVE
        modeling files.
                        - Hs
                        - Tp
                        - h
                        - WG

                        %%% New variables to facilitate FUNWAVE
                        - Xb: bed_before(:,1) % x-coordinate
                        - Xa: bed_after(:,1)  % x-coordinate
                        - Yb: bed_before(:,2) % z-coordinate
                        - Ya: bed_after(:,2)  % z-coordinate
                        - Xos: position of wave_condition

                            %%% Shifted Variables
                                The following variables shift the
                                corresponding variables to the left to 
                                align with a FUNWAVE input where the 
                                offshore is to the left.
                                    - Xb_s: 
                                    - Xa_s
                                    - WG_s:
                                    - Xos_s:

                            %%% Cut Variables
                                The following variables cut the profile
                                such that only the wet portion is
                                considered:
                                    - Xb_cut
                                    - Xa_cut
                                    - Yb_cut
                                    - Ya_cut
                                    - WG_cut
                        %%%
                        - eta
                        - t
                        - t0
                        - t_end
                        - MWL
                        - Hrms
                        - Hmo
                        - H3
                        - eta_max
                        - eta_min

%% General Use Notes
    D3c is probably the more useful one.
    
%}
%% Save All Data (a)
D3a = struct(); 

%%% Relevant Directories and folders
    D3_dir = '../Validation-Data/DUNE3_data';
    tr_folders = dir(D3_dir);

%%% Loop through and get data from all folders
for j = 1:length(tr_folders)
    name = tr_folders(j).name;
    try
        if (strncmp(name, 'Trial', 5)) && (length(name) == 7)
            D3a.(name).('raw_data') = load(fullfile(D3_dir,name,'raw_data.mat')).raw_data;
            D3a.(name).('filtered_data') = load(fullfile(D3_dir,name,'filtered_data.mat')).filtered_data;
            D3a.(name).('wave_condition') = load(fullfile(D3_dir,name,'wave_condition.mat')).wave_condition;
        end
    end
end
%%
D3a_name = fullfile(D3_dir,'D3a.mat');
save(D3a_name,'-struct','D3a');






%% Save Condensed/Processed Version (c)
D3c = struct();
% Loop through all trials
for tr = 5:24
%%% Initialize structure
    D3 = struct();

%%% Load in Data
   % Construct names
    name = ['Trial',sprintf('%02d', tr)];

    % Load in Raw and Wave Conditions
    rd = D3a.(name).raw_data;
    wc = D3a.(name).wave_condition;

%%% Wave Conditions
	D3.Hs = wc.Hs;
    D3.Tp = wc.Tp;
    D3.h = wc.h;

%%% Pass through other properties
    % eta profile
    D3.eta = rd.eta;

    % time info
    D3.t = rd.t;
    D3.t0 = rd.t0;
    D3.t_end = rd.t_end;

    % wave statistics
    D3.MWL = rd.MWL;
    D3.Hrms = rd.Hrms;
    D3.Hmo = rd.Hmo;
    D3.H3 = rd.H3;
    D3.eta_max = wc.eta_max;
    D3.eta_min = wc.eta_min;

%%% Raw Profile and Gauges
    % Get profiles as given
    Xb = rd.bed_before(:,1)'; Xa = rd.bed_after(:,1)';
    Yb = rd.bed_before(:,2)'; Ya = rd.bed_after(:,2)';

    % Position of Wave Gauges
    WG = rd.WG_loc_x;

    % Store to structure
    D3.Xb = Xb; D3.Xa = Xa;
    D3.Yb = Yb; D3.Ya = Ya;
    D3.WG = WG;


%%% Profile Shifted Left 
    % Shift X coordinates left
    D3.Xb_s = Xb - min(Xb); 
    D3.Xa_s = Xa - min(Xa); 
    D3.WG_s = WG - min(Xb); 

%%% Profile cut off at MWL
    % Cut off NaNs
        Yb_noNan = Yb;
        Yb_noNan(isnan(Yb_noNan)) = 0;
        MWL_noNan = D3.MWL;
        MWL_noNan(isnan(MWL_noNan)) = 0;
    % Find index
        [~, cut_index] = min(abs(Yb_noNan - max(MWL_noNan)));

    % Cut out
    D3.Xb_cut = Xb_s(1:cut_index); 
    D3.Xa_cut = Xb_s(1:cut_index); 
    D3.Yb_cut = Yb(1:cut_index); 
    D3.Ya_cut = Ya(1:cut_index); 
        % Cut out wave gauges
            D3.WG_cut = D3.WG_s(1:nnz(MWL_noNan));



%%% Add to structure
    D3c.(name) = D3;

end

%%% Save Structure to File
D3c_name = fullfile(D3_dir,'D3c.mat');
save(D3c_name,'-struct','D3c');

%% Plotting for Sanity
trial_no = 24;
tri = ['Trial',sprintf('%02d', trial_no)];

    %%% Pull out variables
    Xb = D3c.(tri).Xb; Xa = D3c.(tri).Xa;
    Yb = D3c.(tri).Yb; Ya = D3c.(tri).Ya;
    WG = D3c.(tri).WG;
    MWL = D3c.(tri).MWL;

    %%% Plot call
    close all
    figure(1)
    subplot(2,2,1)
    hold on
        % Plot before profile
        plot(Xb,Yb,'LineWidth', 1.5,'Color','b','LineStyle','-');
        % Plot after profile
        plot(Xa,Ya,'LineWidth',1.5,'Color','r','LineStyle','-');
        % Plot Wave gage locations
        plot([WG; WG], repmat(ylim',1,size(WG,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
        % Plot MWL
        plot(WG,MWL,'Color',"#4DBEEE",'LineWidth',2);
        % Plot Labels/Properties
        title('Data as Given')
        grid on

    %%% Pull out variables
    Xb_s = D3c.(tri).Xb_s;
    Xa_s = D3c.(tri).Xa_s;
    WG_s = D3c.(tri).WG_s;

    %%% Plot call
    subplot(2,2,2)
    hold on
        % Plot before profile
        plot(Xb_s, Yb, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-');
        % Plot after profile
        plot(Xa_s, Ya, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-');
        % Plot Wave gage locations
        plot([WG_s; WG_s], repmat(ylim', 1, size(WG_s, 2)), 'Color', [0 0 0, 0.5], 'LineStyle', '--', 'LineWidth', 0.75);
        % Plot MWL
        plot(WG_s,MWL,'Color',"#4DBEEE",'LineWidth',2);
        % Plot Labels/Properties
        title('Data Shifted')
        grid on

    %%% Pull out variables
    Xb_cut = D3c.(tri).Xb_cut; Xa_cut = D3c.(tri).Xa_cut;
    Yb_cut = D3c.(tri).Yb_cut; Ya_cut = D3c.(tri).Ya_cut;
    WG_cut = D3c.(tri).WG_cut;

    %%% Plot call
    subplot(2,2,3)
    hold on
        % Plot before profile
        plot(Xb_cut, Yb_cut, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-');
        % Plot after profile
        plot(Xa_cut, Ya_cut, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-');
        % Plot Wave gage locations
        plot([WG_cut; WG_cut], repmat(ylim', 1, size(WG_cut, 2)), 'Color', [0 0 0, 0.5], 'LineStyle', '--', 'LineWidth', 0.75);
        % Plot MWL
        plot(WG_s,MWL,'Color',"#4DBEEE",'LineWidth',2);
        % Plot Labels/Properties
        title('Data Cut Off')
        grid on

    %%% Superplot info
        sgtitle(tri)


%% Create a save bathy file
    % % 3 x 1024 array
    % bathy_FW = [Y_FW; Y_FW; Y_FW];
    % % other relevant information
    % DX = DX;
    % const_tab = table();
    % const_tab.DX = DX;
    % const_tab.AMP_WK = wc.Hs/2;
    % const_tab.TPERIOD = wc.Tp;
    % DY = 1;
    % writematrix(-bathy_FW, 'bathy_Trial05.txt')
    % writetable(const_tab,'Const_Trial05.txt')
