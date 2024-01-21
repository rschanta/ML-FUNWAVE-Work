%%% Gen_Bathy_D3.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 20 January 2024
Edit made: 
    - Created File
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a SCRIPT

%% Description
This script takes a D3c structure and generates a FUNWAVE bathy file for 
an input trial that enforces stability criteria and also creates the 
FUNWAVE input file for it. It outputs the input.txt file, the bathy.txt
file, and a summary file

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
% Trial number from Dune3 Dataset
    trial_no = 5; 
% Name that will form the beginning of the input.txt and bathy files
    name = 'D3_';
% Name of folder to generate files in
    folder = 'Try'


%% Import D3c
D3c = load('../Validation-Data/DUNE3_data/D3c.mat');
tri = ['Trial',sprintf('%02d', trial_no)];

%% Process into stable FUNWAVE input
%{
    The following stability criteria are considered:
        - DX/h > 1/15
        - Smoothed out bathymetry in region of the wavemaker
        - kh < pi (shallow wave condition)
%}

%%% Pull out data needed
    % Pull out cross-shore and vertical coordinates
        X = D3c.(tri).Xb_cut; 
        Z = D3c.(tri).Yb_cut;
    % Convert profile to depth by using the maximum MWL as origin
        depth = max(D3c.(tri).MWL);
        h = depth - Z;
    % Pull out wave period
        T = D3c.(tri).Tp; 

%%% Stability criterion
    % Calculate k, wavelenth, and kh
        k = -fzero(@(k) (2*pi/T)^2-9.81*k*tanh(k*max(h)),0);
        L = 2*pi/k;
        kh = max(k*h);
    % Find DH stability limits 
        DX_min = max(h)/15; % water depth requirement
        DX_max = L/60; % at least 60 points per wavelength
        
%%% Choose a reasonable DX value, here just tehe average of min and max
    % Find average of DX_min and DX_max
        DX = mean([DX_min,DX_max]);
    % Round to 2 decimal places
        DX = round(DX,2);
        DY = DX;

%%% Interpolate bathymetry to the submerged profile X
    % Width of the profile
        X_w = max(X);
    % Use DX from 0 to X_w
        X_FW = 0:DX:X_w;
    % Interpolate the depth linearly along X_FW from data, round
        h_int = interp1(X,h,X_FW,"linear");
        h_FW = round(h_int,3);

%%% Get Mglob and specify Nglob
    Mglob = length(X_FW);
    Nglob = 4;

%%% Deal with Wavemaker specification
    % Specify X position of Wavemaker (1/5 into the model domain)
        M_WK = 0.2*Mglob;
    % Find Xc_WK
        Xc_WK = X_FW(round(0.2*Mglob));
    % Find DEP_WK
        DEP_WK = h_FW(M_WK);
    % Smooth out 2 depth points adjacent to wavemaker as well
        h_FW(M_WK-2:M_WK+2) = DEP_WK;
    AMP_WK = 1.2;

%% Create FUNWAVE bathy file
    % File names
        mkdir(folder)
        file_name = [name,tri];
        writematrix([X_FW; X_FW; X_FW; X_FW], fullfile('./', folder,[file_name,'_x.txt']))
        writematrix([h_FW; h_FW; h_FW; h_FW], fullfile('./', folder,[file_name,'_b.txt']))

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
        %xline(X_sponge, 'LineWidth', 1.5, 'Color', 'g', 'LineStyle', '--')
        xline(Xc_WK, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '--');

        % Plot MWL
        yline(depth,'Color',"#4DBEEE",'LineWidth',2 )
        % Plot Labels/Properties
        title('Input Profile');
        grid on
        legend(['Profile:', ' DX = 0.1459,   DY = 1,   Mglob = 1204,   Nglob = 3'] ,['Sponge: ', 'Width (West) = 26.1074'], ['WaveMaker: ', 'XcWK = 36.3170', ',   DEPWK = 2.16'], 'Depth Datum @ 2.16', 'Location','southoutside')

        % a = gca; % get the current axis;
        % % set the width of the axis (the third value in Position) 
        % % to be 60% of the Figure's width
        % a.Position(3) = 0.6;
        % put the textbox at 75% of the width and
        % label = {'\textbf{PARAMETERS}',['DX: ' num2str(DX), ' Mglob: ', num2str(Mglob)], ['DY: ' num2str(DY), ' Nglob: ', num2str(Mglob)]}
        % annotation('textbox', [0.75, 0.5, 0.1, 0.5], 'String', label, 'Interpreter','latex')


%% Create input.txt file
%%% Create file using FW_Write class
    addpath('../Key-Scripts/')
    f = FW_write(['./', folder, '/'],[file_name,'_i']);
%%% Populate File
    f.TITLE(); 
        f.set('TITLE',file_name)
    f.PARALLEL_INFO(); 
        f.set('PX',16); f.set('PY',2)
    f.DEPTH(); 
        f.set('DEPTH_TYPE','DATA'); f.set('DEPTH_FILE', ['./bathy/', file_name,'_b.txt'])
    f.DIMENSION();
        f.set('Mglob', Mglob); f.set('Nglob',Nglob)
    f.TIME()
        f.set('TOTAL_TIME','600.0');f.set('PLOT_INTX','1.0');
        f.set('PLOT_INTV_STATION', '0.5'); f.set('SCREEN_INTV', '1.0');
    f.GRID()
        f.set('DX',DX); f.set('DY',DY)
    f.WAVEMAKER()
        f.set('WAVEMAKER','WK_REG')
        f.set('DEP_WK',DEP_WK); f.set('Xc_WK',Xc_WK); 
        f.set('AMP_WK',AMP_WK); f.set('Tperiod',T);
        f.set('Theta_WK','0.0');f.set('Delta_WK','3.0');
    f.PERIODIC_BC()
        f.set('PERIODIC', 'F');
    f.PHYSICS()
        f.set('Cd', '0.0');
    f.SPONGE_LAYER()
        f.set('DIFFUSION_SPONGE', 'F'); f.set('FRICTION_SPONGE', 'T');
        f.set('DIRECT_SPONGE', 'T'); f.set('Csp', '0.0');
        f.set('CDsponge', '1.0');
        f.set('Sponge_west_width', '180.0'); f.set('Sponge_east_width', '0.0');
        f.set('Sponge_south_width', '0.0'); f.set('Sponge_north_width', '0.0');
    f.NUMERICS()
        f.set('CFL', '0.4'); f.set('FroudeCap', '3.0');  
    f.WET_DRY()
        f.set('MinDepth', '0.01');
    f.BREAKING()
        f.set('VISCOSITY_BREAKING', 'T'); f.set('Cbrk1', '0.65'); f.set('Cbrk2', '0.35');
    f.WAVE_AVERAGE()
        f.set('T_INTV_mean', '10.0'); f.set('STEADY_TIME', '10.0');
    f.OUTPUT()
        f.set('DEPTH_OUT','F'); f.set('WaveHeight','T'); 
        f.set('ETA','T'); f.set('MASK','F');
        f.set('RESULT_FOLDER', './output/')
        

