% Dune3_to_FW_Inputs.m

%% Load in Template File, Required Helper Functions, and D3c
addpath('../Helper-Functions/FW-Input/')
D3c = load('../Validation-Data/DUNE3_data/D3c.mat');
Template = load('./Template/Template5.mat');
%% Prepare Inputs/Outputs

    %%% Trial Numner
        Trial_no = 5;
        
    %%% Name of Run and Output Directory
        Out_Dir = '../Validation-Data/D3-Funwave-Data';
        Run_Name = 'D101';

%% Run Through Trials
Summary = struct();
for trial = [5:19,21:24]
    FW = Template.FW_base;
    [s, FW, d] = D3_to_FW(trial,D3c,FW,Out_Dir,Run_Name);
   
    plot_setup(trial,Run_Name,d, s, FW)
    %%% Add useful info to Run_Sum and Save it
        % Construct Trial Name
            Tr_Name = ['Tr',sprintf('%02d',trial)]; 
        % Add FUNWAVE input.txt structure
            Summary.(Tr_Name) = FW;
        % Add Wave Number Info as well
            Summary.(Tr_Name).k = s.k;
            Summary.(Tr_Name).L = s.L;
            Summary.(Tr_Name).h0 = s.h0;
            Summary.(Tr_Name).kh = s.kh;    
end
 % Save it
            Run_Sum_path = fullfile(Out_Dir,Run_Name,[Run_Name,'summary.mat']);
            save(Run_Sum_path,"Summary")
%% Load to be summary
load('../Validation-Data/D3-Funwave-Data/D99/D99summary.mat')

%% Function to take Dune 3 Data to Funwave 
function [s, FW, d] = D3_to_FW(Trial_no,D3c,FW,Out_Dir,Run_Name)
    s = struct();
    s = get_raw_profile(D3c, Trial_no, s);
    s = get_wave_info(D3c,Trial_no,s);
    s = eval_model_stability(D3c, Trial_no, s);
    s = prepare_input_profile(D3c, Trial_no, s);
    s = set_wavemaker(D3c,Trial_no,s);
    s = set_sponge(D3c,Trial_no,s);

    d = construct_directories(Out_Dir,Run_Name);
    s = write_bathy_file(D3c,Trial_no,s,Run_Name, d);
    [s, FW] = modify_FWD3_Template(Trial_no,Run_Name,s,FW);
    write_input(Trial_no,Run_Name,d, FW)
end
%% INDIVIDUAL FUNCTIONS STEP BY STEP
function s = get_raw_profile(D3c, Trial_no, s)
    %%% Construct Trial_Name
        Trial_Name = ['Trial',sprintf('%02d',Trial_no)]; 
    %%% Get the crosshore and vertical coordinates
        X = D3c.(Trial_Name).Xb_cut; 
        Z = D3c.(Trial_Name).Yb_cut; 
    %%% Remove duplicate data points- a problem for some trials
        [X_sort,idx] = sort(X); 
        Z_sort = Z(idx);
        [X, idx_u] = unique(X_sort, 'stable' );
        Z = Z_sort(idx_u);
    %%% Convert vertical coordinate to depth
        % Use maximum MWL as datum for depth h
            datum= max(D3c.(Trial_Name).MWL); 
            h = datum - Z; 
        % Use maximum h as height offshore
            h0 = max(h); 
            s.h0 = h0;
    %%% Store to output
        s.X = X;
        s.h = h;
        s.h0 = h0;
end

function s = get_wave_info(D3c,Trial_no,s)
     %%% Construct Trial_Name
        Trial_Name = ['Trial',sprintf('%02d',Trial_no)]; 
    %%% Use the period provided from the dataset
        Tperiod = D3c.(Trial_Name).Tp;
    %%% Amplitude: Use 0.5*RMS at 3 western-most wave gauges (mean)
        Hrms = D3c.(Trial_Name).Hrms;
        AMP_WK = mean(Hrms(1:3))/2;
    %%% Store to output
        s.Tperiod = Tperiod;
        s.AMP_WK = AMP_WK;
end

function s = eval_model_stability(D3c, Trial_no, s)
    %%% Use most offshore height and provided period T for analysis
        h = s.h0; 
        T = s.Tperiod; 
    %%% Solve dispersion equation for k, L, and kh
        k = -fzero(@(k) (2*pi/T)^2-9.81*k*tanh(k*h),0); 
        L = 2*pi/k; 
        kh = k*h;

    %%% Stability Requirement 1: height/DX > 15
        DX_min = h/15;
    %%% Stability Requirement 2: At least 60 points per wavelength
        DX_max = L/60; 

    %%% Choice of DX based on Stability (choose mean of min and max)
        DX = mean([DX_min, DX_max]);
        DX = round(DX,2); % round for nicer number.
    
    %%% Store to output
        s.k = k;
        s.L = L;
        s.kh = kh;
        s.DX = DX;
end

function s = prepare_input_profile(D3c, Trial_no, s)
    %%% Construct Trial_Name
        Trial_Name = ['Trial',sprintf('%02d',Trial_no)]; 
    %%% Get width of the submerged profile
        X = s.X; 
        X_width = max(X); 
    %%% Adjust such that the first wave gauge is 1.1*wavelength from left
        % Amount to add
            X_add = 1.1*s.L - D3c.(Trial_Name).WG_s(1);
        % Add to width and profile
            X_width = X_width + X_add;
            X = X + X_add;
    %%% Construct new cross-shore coordinate based on DX and profile width
        DX = s.DX;
        X_FW = 0:DX:X_width;
    %%% Adjust profile as needed to add zeros
        % Find index of original origin in the new construction
            [~, orig_i] = min(abs(X_FW - X_add));
        % Find how many points were before this
            no_zeros_add = orig_i - 1;
        % Add onto profiles
            add_X = linspace(0,0.9*X_add,no_zeros_add);
            
            X = [add_X X];
            h = s.h;
            add_Y = s.h(1)*ones(1,no_zeros_add);
            h = [add_Y h];

    %%% Get Mglob from length of X_FW
        Mglob = length(X_FW);
    %%% Add padding zeros to height based on differences in length
        % disp('length of h is: ')
        % disp(length(h))
        %  disp('---')
        %  disp('length of X is: ')
        %  disp(length(X))
        %  disp('---')
        %unique_elements = unique(X);
        %disp(X)
% Find non-unique elements
    non_unique_elements = X(histc(X, unique(X)) > 1);
    disp(non_unique_elements)
    %%% Interpolate the depth linearly along X_FW from the data 
        h_FW = interp1(X,h,X_FW,"linear");
        h_FW = round(h_FW,3); % round for nicer number
    %%% Store to output
        s.X_FW = X_FW;
        s.h_FW = h_FW;
        s.Mglob = Mglob;
        s.X_add = X_add;
end

function s = set_wavemaker(D3c,Trial_no,s)
    %%% Construct Trial_Name
        Trial_Name = ['Trial',sprintf('%02d',Trial_no)]; 
    %%% Specify X position of wavemaker (at left most gage point)
        X_FW = s.X_FW;
        L = s.L;

        Xc_WK = 1.1*L;
        [~, M_WK] = min(abs(Xc_WK - X_FW));
        Xc_WK =  X_FW(M_WK);
    %%% Find Depth at wavemaker (DEP_WK)
        h_FW = s.h_FW;
        DEP_WK = h_FW(M_WK);
    %%% Smooth out profile in vicnity of wavemaker
        h_FW(M_WK-2:M_WK+2) = DEP_WK;
        s.Xc_WK = Xc_WK;
    %%% Store to output
        s.Xc_WK = Xc_WK;
        s.DEP_WK = DEP_WK;
        s.h_FW = h_FW;
end

function s = set_sponge(D3c,Trial_No,s)
    %%% Construct Trial_Name
        Trial_Name = ['Trial',sprintf('%02d',Trial_No)]; 
    %%% Set sponge at 60% of wavelength (should at least 50%)
        L = s.L; 
        Sponge_west_width = 0.52*L;
    %%% Store to output
        s.Sponge_west_width = Sponge_west_width;
end

function d = construct_directories(out_dir,Run_Name)
    %%% Construct Directory where all outputs will go
        Out_Dir = fullfile(out_dir,Run_Name);
        if ~exist(Out_Dir, 'dir'), mkdir(Out_Dir), end
    %%% Construct directory for bathymetry files
        Bathy_Dir = fullfile(Out_Dir,[Run_Name,'-b']);
        if ~exist(Bathy_Dir, 'dir'), mkdir(Bathy_Dir), end
    %%% Consruct directory for input files
        Input_Dir = fullfile(Out_Dir,[Run_Name,'-i']);
        if ~exist(Input_Dir, 'dir'), mkdir(Input_Dir), end
    %%% Consruct directory for plots of model domain
        Plot_Dir = fullfile(Out_Dir,[Run_Name,'-p']);
        if ~exist(Plot_Dir, 'dir'), mkdir(Plot_Dir), end
    %%% Store names to outputs
        d.Out_Dir = Out_Dir;
        d.Bathy_Dir = Bathy_Dir;
        d.Input_Dir = Input_Dir;
        d.Plot_Dir = Plot_Dir;
end

function s = write_bathy_file(D3c,Trial_no,s,Run_Name, d)
    %%% Construct Tr_Name
        Tr_Name = ['Tr',sprintf('%02d',Trial_no)];
    %%% Construct the bathy file
        Nglob = 4;
        h_FW = s.h_FW;
        bathy = repmat(h_FW, Nglob, 1);
    %%% Output the bathy file
        Bathy_Dir = d.Bathy_Dir;
        bathy_file_name = [Run_Name,'_',Tr_Name,'_b.txt'];
        writematrix(bathy, fullfile(Bathy_Dir,bathy_file_name))
    %%% Store name of bathy file to output
        s.bathy_file_name = bathy_file_name;
end

function [s, FW] = modify_FWD3_Template(Trial_no,Run_Name,s,FW)
    %%% Construct Tr_Name and Trial_Name
        Tr_Name = ['Tr',sprintf('%02d',Trial_no)];
        Trial_Name = ['Trial',sprintf('%02d',Trial_no)];
    %%% Construct title name
        title_name = [Run_Name, '_',Trial_Name];
        FW.TITLE = title_name;
    %%% Set Depth Info
        bathy_file_name = s.bathy_file_name;
        bathy_path = ['./bathy/',Run_Name,'-b/',bathy_file_name];
        FW.DEPTH_FILE = bathy_path;
    %%% Set Dimension (note- needs to be an int!)
        FW.Mglob = int64(s.Mglob);
        FW.Nglob = int8(4); % Set to 4
    %%% Set total time
        FW.TOTAL_TIME = 1450; % Set to 1450 to match Dune3 Dataset
        FW.T_INTV_mean = 10.0;
        FW.STEADY_TIME = 10.0;
    %%% Grid
        FW.DX = s.DX;
        FW.DY = s.DX; % Use same DY as DX
    %%% Set Wavemaker
        FW.Xc_WK = s.Xc_WK;
        FW.DEP_WK = s.DEP_WK;
        FW.AMP_WK = s.AMP_WK;
        FW.Tperiod = s.Tperiod;
    %%% Set Sponge Layer
        FW.Sponge_west_width = s.Sponge_west_width;
    %%% Set Result Folder
        Lustre = '/lustre/scratch/rschanta/';
        result_path = [Lustre,Run_Name,'/',Tr_Name,'/'];
        FW.RESULT_FOLDER = result_path;
end

function write_input(Trial_no,Run_Name,d, FW)
    %%% Construct Tr_Name 
        Tr_Name = ['Tr',sprintf('%02d',Trial_no)];
    %%% Construct input.txt file name
        input_Name = [Run_Name,'_',Tr_Name,'.txt']; 
        input_path = fullfile(d.Input_Dir,input_Name);
    FW_input(FW,input_path);
end

function plot_setup(Trial_no,Run_Name,d, s, FW)
    hold on
    close all
    f = figure('visible','off');
    %%% Plot bathymetry
        plot(s.X_FW,s.h0-s.h_FW, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-')
    
    %%% Plot position of WaveMaker
        xline(s.Xc_WK, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '--')

    %%% Plot Sponge 
        xline(s.Sponge_west_width, 'LineWidth', 1.5, 'Color', 'g', 'LineStyle', '--')

    
    %%% Plot MWL
        yline(s.h0,'Color',"#4DBEEE",'LineWidth',2 )

    %%% Set Plot properties and labels
        Tr_Name = ['Trial',sprintf('%02d',Trial_no)]; 
        PlotName = [Run_Name, '_',Tr_Name];
        title(['Funwave Dune 3 Input for: ', PlotName], 'Interpreter', 'none');

        grid on
        legend(['Profile:', ...
                    ' DX = ',num2str(s.DX), ' DY = ',num2str(s.DX),...
                    ' Mglob = ',num2str(FW.Mglob),   ' Nglob = ',num2str(FW.Nglob)...
                    ],...
                ['WaveMaker: ',...
                    'XcWK = ', num2str(s.Xc_WK),' DEPWK = ', num2str(s.DEP_WK)...
                    ],...
                ['Sponge: ',...
                    'Width (West) = ' num2str(s.Sponge_west_width)...
                    ],...
                ['Depth @ Datum: ', num2str(s.h0), 'Wavelength: ', num2str(s.L)],...
                'Location','southoutside')
    %%% Save plot
        saveas(gcf,fullfile(d.Plot_Dir,[PlotName,'_plot.png']))
end

