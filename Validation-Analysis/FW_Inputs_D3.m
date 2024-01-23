%%% FW_Inputs_D3.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 22 January 2024

Last Version Made: 

Edit made: 
    - Edited to output to subdirectory to
        ../Validation-Data/D3-Funwave-Data
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a SCRIPT

%% Description
This script takes a D3c structure and generates a FUNWAVE bathy file for 
an input trial that enforces stability criteria and also creates the 
FUNWAVE input file for it. It outputs the input.txt file, the bathy.txt
file, and a summary file in the form of a structure. 

%% Dependencies
'Preprocess_Dune3.mat': (.m script) - script that generates D3c.m

'D3c': (.mat structure)- assumed to be saved in 
        '../Validation-Data/DUNE3_data/D3c.mat'

%% Arguments/Inputs
'run_name': (str)- name for the run variation

'trial_no': (int)- number of trial to generate bathy file for

%% Outputs
    NOTE: All output in ../Validation-Data/D3-Funwave-Data/{run_name}

    '{run_name}_tr{trial_no}_b.txt': (.txt file): bathymetry file Funwave
        needs to run for the given trial generated with the script

    '{run_name}_tr{trial_no}_i.txt': (.txt file): input file Funwave
        needs to run for the given trial generated with the script

    '{run_name}_tr{trial_no}_x.txt': (.txt file): cross-shore coordinates
        corresponding to the heights listed in the _b file

    '{run_name}_tr{trial_no}_s': (.mat file): structure summarizing key
        parameters for the model run


%% General Use Notes
    
    
%}

%% Input
% Directory for Output
    out_dir = '../Validation-Data/D3-Funwave-Data';
% Trial number from Dune3 Dataset
    trial_no = 24; 
% Name that will form the beginning of the input.txt and bathy files
    run_name = 'D60';
spatio = struct();
for j = 5:8
    spatio = FW_Inputs_D3_f(out_dir,j,run_name,spatio);
    disp(['Working on Trial ', num2str(j)])
end

save([fullfile(out_dir,run_name),'/',run_name,'-data.mat'],"spatio");


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  spatio = FW_Inputs_D3_f(out_dir,trial_no,run_name,spatio)
%% File/Directories
    % Add Trial Folder for constants
        trial_name = ['Tr',sprintf('%02d', trial_no)];
        tri = ['Trial',sprintf('%02d', trial_no)];
        name = fullfile(out_dir,run_name);
    % Add bathymetry and input folders
        bathy_folder = fullfile(out_dir,run_name,[run_name,'-b']);
        input_folder = fullfile(out_dir,run_name,[run_name,'-i']);
        plots_folder = fullfile(out_dir,run_name,[run_name,'-plots']);
    % Create Output directory for files generated
        if ~exist(name, 'dir'), mkdir(name), end
        if ~exist(bathy_folder, 'dir'), mkdir(bathy_folder), end
        if ~exist(input_folder, 'dir'), mkdir(input_folder), end
        if ~exist(plots_folder, 'dir'), mkdir(plots_folder), end
    % Create file name base for specific files generated
        file_name = [run_name,'_',trial_name];

%% Import D3c
D3c = load('../Validation-Data/DUNE3_data/D3c.mat');


%% Process into stable FUNWAVE input
%{
    The following stability criteria are considered:
        - DX/h > 1/15
        - Smoothed out bathymetry in region of the wavemaker
        - kh < pi (shallow wave condition)
%}

%%% Pull out data needed
    % Structure for stability info
        s = struct();
    % Pull out cross-shore and vertical coordinates
        X = D3c.(tri).Xb_cut; 
        Z = D3c.(tri).Yb_cut; 

    % Remove repeated points
        [X_sort,idx] = sort(X); 
        Z_sort = Z(idx);
        [X, idx_u] = unique(X_sort, 'stable' );
        Z = Z_sort(idx_u);

    % Convert profile to depth by using the maximum MWL as origin
        depth = max(D3c.(tri).MWL); s.depth = depth;
        h = depth - Z; 
        h_max = max(h); s.h_max = h_max;
    % Pull out wave period
        T = D3c.(tri).Tp; s.T = T;

%%% Stability criterion
    % Calculate k, wavelenth, and kh
        k = -fzero(@(k) (2*pi/T)^2-9.81*k*tanh(k*h_max),0); s.k = k;
        L = 2*pi/s.k; s.L = L;
        kh = max(s.k*h_max); s.kh = kh;
    % Find DH stability limits 
        DX_min = h_max/15; s.DX_min = DX_min;% water depth requirement
        DX_max = L/60; s.DX_max = DX_max;% at least 60 points per wavelength
    % Save stability structure to larger structure
        spatio.(tri).stability = s;

        
%%% Choose a reasonable DX value, here just the average of min and max
    % Find average of DX_min and DX_max
        DX = mean([s.DX_min,s.DX_max]);
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
%%% Specify time
    time_tot = 1450;
%%% Get Mglob and specify Nglob
    Mglob = length(X_FW);
    Nglob = 4;
    spatio.(tri).Mglob = Mglob;
    spatio.(tri).Nglob = Nglob;
    spatio.(tri).time_tot = time_tot;

%%% Deal with Wavemaker and Sponge specification
    %%% Xc_WK and DEP_WK Processing
        % Specify X position of Wavemaker (1/5 into the model domain)
            M_WK = round(0.2*Mglob);

        % Specify the X position of the Sponge Layer (0.6*L)
            Sponge_West_M = round(0.6*L);
            Sponge_West = X_FW(Sponge_West_M);
        % Find Xc_WK
            Xc_WK = X_FW(round(0.2*Mglob));
        % Find DEP_WK
            DEP_WK = h_FW(M_WK);
        % Smooth out 2 depth points adjacent to wavemaker as well
            h_FW(M_WK-2:M_WK+2) = DEP_WK;

    %%% Define AMP_WK based on half of the HRMS of the first 3 points
    AMP_WK = mean(D3c.(tri).Hrms(1:3)/2);

%% Create FUNWAVE bathy files
    %%% Write actual file that FUNWAVE needs
        writematrix([h_FW; h_FW; h_FW; h_FW], fullfile(bathy_folder,[file_name,'_b.txt']));
    %%% Save the X-Values of the interpolated profile to spatio
        spatio.(tri).X = X_FW;

%%% Generate Plot   
    plot_D3FW_domain()
%%% Create Input
    create_D3FW_input()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% INPUT Function
function create_D3FW_input()
    %%% Create file using FW_Write class
        addpath('../Key-Scripts/')
        f = FW_write(fullfile(input_folder,[file_name,'_i.txt']));
    %%% Populate File
        f.TITLE(); 
            f.set('TITLE',file_name)
        f.PARALLEL_INFO(); 
            f.set('PX',16); f.set('PY',2)
        f.DEPTH(); 
            f.set('DEPTH_TYPE','DATA'); 
            f.set('DEPTH_FILE', ['./bathy/', run_name,'-b/', file_name,'_b.txt'])
        f.DIMENSION();
            f.set('Mglob', Mglob); 
            f.set('Nglob',Nglob)
        f.TIME()
            f.setf('TOTAL_TIME',time_tot);f.setf('PLOT_INTX',1);
            f.setf('PLOT_INTV_STATION', 0.5); f.setf('SCREEN_INTV', 1);
        f.GRID()
            f.setf('DX',DX); 
            f.setf('DY',DY)
        f.WAVEMAKER()
            f.set('WAVEMAKER','WK_REG')
            f.setf('DEP_WK',DEP_WK); 
            f.setf('Xc_WK',Xc_WK); 
            f.setf('AMP_WK',AMP_WK); 
            f.setf('Tperiod',T);
            f.setf('Theta_WK',0);
            f.setf('Delta_WK',3);
        f.PERIODIC_BC()
            f.set('PERIODIC', 'F');
        f.PHYSICS()
            f.setf('Cd', 0);
        f.SPONGE_LAYER()
            f.set('DIFFUSION_SPONGE', 'F'); 
            f.set('FRICTION_SPONGE', 'T');
            f.set('DIRECT_SPONGE', 'T'); 
            f.set('Csp', '0.0');
            f.setf('CDsponge', 1.0);
            f.setf('Sponge_west_width', Sponge_West); 
            f.setf('Sponge_east_width', 0);
            f.setf('Sponge_south_width', 0); 
            f.setf('Sponge_north_width', 0);
        f.NUMERICS()
            f.setf('CFL', 0.4); 
            f.setf('FroudeCap', 3);  
        f.WET_DRY()
            f.setf('MinDepth', 0.01);
        f.BREAKING()
            f.set('VISCOSITY_BREAKING', 'T'); 
            f.setf('Cbrk1', 0.65); f.setf('Cbrk2', 0.35);
        f.WAVE_AVERAGE()
            f.setf('T_INTV_mean', 10); 
            f.setf('STEADY_TIME', 10);
        f.OUTPUT()
            f.set('DEPTH_OUT','T'); 
            f.set('WaveHeight','F'); 
            f.set('ETA','T'); 
            f.set('MASK','F');
            f.set('FIELD_IO_TYPE','BINARY');
            f.set('RESULT_FOLDER', ['/lustre/scratch/rschanta/',run_name,'/',trial_name, '/']);
    %% Save FW Input structure
        FW_vars = f.FW_vars;
        spatio.(tri).FW_in.mat = FW_vars;
end

%% Plotting Function
function plot_D3FW_domain()
    %%% Set up Figure
        close all
        f = figure('visible','off');
        hold on

    %%% Plot Interpolated Points
        plot(X_FW,depth - h_FW, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-')
    
    %%% Plot Sponge and Wavemaker
        xline(Sponge_West, 'LineWidth', 1.5, 'Color', 'g', 'LineStyle', '--')
        xline(Xc_WK, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '--');
    
    %%% Plot MWL
        yline(depth,'Color',"#4DBEEE",'LineWidth',2 )

    %%% Set Plot properties and labels
        title(['Funwave Dune 3 Input for: ', file_name], 'Interpreter', 'none');

        grid on
        legend(['Profile:', ...
                    ' DX = ',num2str(DX), ' DY = ',num2str(DY),...
                    ' Mglob = ',num2str(Mglob),   ' Nglob = ',num2str(Nglob)...
                    ],...
                ['Sponge: ',...
                    'Width (West) = ' num2str(Sponge_West)...
                    ],...
                ['WaveMaker: ',...
                    'XcWK = ', num2str(Xc_WK),' DEPWK = ', num2str(DEP_WK)...
                    ],...
                ['Depth @ Datum: ', num2str(h_max)],...
                'Location','southoutside')
    %%% Save plot
        saveas(gcf,fullfile(plots_folder,[trial_name,'_plot.png']))
end
end
