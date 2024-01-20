%%% Preprocess_Dune3.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 19 January 2024
Edit made: 
    - Changed Bathy Generation to not include flat portion and to guarantee
    that points are in the valid range of values.
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a SCRIPT

%% Description
This script takes a D3c structure and generates a FUNWAVE bathy file.

%% Dependencies
'Preprocess_Dune3.mat': (.m script) - script that generates D3c.m

'D3c': (.mat structure)- assumed to be saved in 
        '../Validation-Data/DUNE3_data/D3c.mat'

%% Arguments/Inputs
'trial_no': (int)- number of trial to generate bathy file for

%% Outputs
'Dune3_Trial_{tri}_bathy': (.txt file)- 


%% General Use Notes
    
    
%}

%% Input
trial_no = 5; 
%% Import D3c
D3c = load('../Validation-Data/DUNE3_data/D3c.mat');
tri = ['Trial',sprintf('%02d', trial_no)];
%% Process into FUNWAVE

%{
    The profile is set to be a length of 1024. The actual beach profile is 
    set to be between indices 700-1024, with a constant depth before this 
    to simulate the offshore. The depth is taken as the minimum MWL in the 
    dataset. The before profile is used.
%}

%%% Pull out data and convert heights to depths
    X = D3c.(tri).Xb_cut; 
    Z = D3c.(tri).Yb_cut;
    depth = max(D3c.(tri).MWL);
    h = depth - Z;

%%% Interpolate to 1024 grid points
    X_FW = linspace(0,max(X),300);
    DX = X_FW(2)-X_FW(1);
    h_int = interp1(X,h,X_FW,"linear");
    h_FW = round(h_int,3);

%%% Get position of Sponge and WaveMaker
    X_sponge = X_FW(1);
    Xc_WK = X_FW(50);

%% Create FUNWAVE bathy file
writematrix([h_FW; h_FW; h_FW; h_FW], ['bathynoflat_', tri,'.txt'])
disp(['DX is: ', num2str(DX)])
disp(['Depth is: ', num2str(depth)])
disp(['DX/h is: ', num2str(DX/depth)])
disp(['Sponge is at: ', num2str(X_sponge)])

disp(['Wavemaker is at: ', num2str(Xc_WK)])
disp(['Wavemaker is at depth: ', num2str(h_FW(50))])
if DX/depth > 1/15
    disp('DX/h > 1/15, Should be stable')
else
    disp('DX/h < 1/15,not stable')
end
%% Plot for Sanity
tri = ['Trial',sprintf('%02d', trial_no)];

%%% Data as Given
    %%% Pull out variables
        Xb_cut = D3c.(tri).Xb_cut; Xa_cut = D3c.(tri).Xa_cut;
        Yb_cut = D3c.(tri).Yb_cut; Ya_cut = D3c.(tri).Ya_cut;
        WG_cut = D3c.(tri).WG_cut; WG_s = D3c.(tri).WG_s;
        MWL = D3c.(tri).MWL;
    %%% Plot call
        close all
        figure(1)
        subplot(2,2,1)
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
            title('Data Cut Off');
            grid on

%%% Interpolated Profile
    subplot(2,2,2)
    hold on
        % Plot interpolated points
        plot(X_FW,depth - h_FW, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-')
        
        % Plot Labels/Properties
        title('Interpolated Profile: Cut Off');
        grid on
%%% FUNWAVE Depth_Flat Profile
    figure(2)
    hold on
        % Plot interpolated points
        plot(X_FW,depth - h_FW, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-')
        
        % Plot Sponge Layer and WaveMaker
        xline(X_sponge, 'LineWidth', 1.5, 'Color', 'g', 'LineStyle', '--')
        xline(Xc_WK, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '--');

        % Plot MWL
        yline(depth,'Color',"#4DBEEE",'LineWidth',2 )
        % Plot Labels/Properties
        title('Input Profile');
        %subtitle(['DEPWK = 2.16 , ', 'XcWK = 36.3170']);
        grid on
        legend(['Profile:', ' DX = 0.1459,   DY = 1,   Mglob = 1204,   Nglob = 3'] ,['Sponge: ', 'Width (West) = 26.1074'], ['WaveMaker: ', 'XcWK = 36.3170', ',   DEPWK = 2.16'], 'Depth Datum @ 2.16', 'Location','southoutside')

%%% Superplot settings



