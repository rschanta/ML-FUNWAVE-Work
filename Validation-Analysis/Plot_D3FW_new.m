%%% Plot_D3.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 20 January 2024
Edit made: 
    - Created
    - Renamed to Plot_D3.m
%}

%plot_monitor(2)
%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a SCRIPT

%% Description
This file is being used to analyze the Dune3 Data to figure out appropriate
inputs for FUNWAVE model validation. It plots the actual results of the
Dune 3 dataset.

%% Dependencies
'Preprocess_Dune3.mat': (.m script) - script that generates D3c.m

'D3c': (.mat structure)- assumed to be saved in 
        '../Validation-Data/DUNE3_data/D3c.mat'

%% Arguments/Inputs
'trial_no': (int)- number of trial to analyze

%% Outputs



%% General Use Notes
    
    
%}

%% Input
trial_no = 5; 
%% Import D3c and D3FW
D3c = load('../Validation-Data/DUNE3_data/D3c.mat');
D3FW = load('../Analysis-Playground/D36_out.mat');
D3FW = D3FW.out_struct;

%%
% D3_info = load('../Validation-Data/D3-Funwave-Data/D36/Tr05/D36_Tr05_s.mat')
% 0:DX:DX*(Mglob-1)
%D3spat = load('../Validation-Data/D3-Funwave-Data/D36/D36-spatio.mat')
% name = 'D36'
% %%
% str_name = fullfile('../Validation-Data/D3-Funwave-Data/',name,trif,[name,'_',trif,'_s.mat'])
% D4 = load(str_name);



%% 
close all
animate_D3FW(D3c,D3FW,5,'D36')

%% Animate Dune3 version simulated output

function animate_D3FW(D3c,D3FW, trial_no,name)

    %%% Construct Trial Names for structure fields
        tric = ['Trial',sprintf('%02d', trial_no)];
        trif = ['Tr',sprintf('%02d', trial_no)];
    %%% Pull out data from structures
        D3_D = DownsampleD3(D3c,trial_no,1450)
        D3_FW = D3FW.(trif);

    %%% Get spatial info
        str_name = fullfile('../Validation-Data/D3-Funwave-Data/',name,trif,[name,'_',trif,'_s.mat'])
        Dspat = load(str_name);
        D3_FWX = 0:Dspat.DX:Dspat.DX*(Dspat.Mglob-1);


    %%% Get number of wave gauges in the submerged profile
    len_WG = length(df.WG_cut);

    %%% Construct the figure
    f = figure(1);
        % Initialize plots and title
            %%% Actual Data
                D = plot(D3_D.WG,D3_D.eta(1,:)); 
            %%% Funwave simulation
                F =  plot(D3_FWX,D3_FW(1,:));
            title(['Plot of Dune 3 Trial ', num2str(trial_no)]);
    
        % Set plot elements that don't change.
            %%% Set y limit to lowest point of beach profile and max eta
                %ylim([-df.MWL(1), max(max(df.eta))]);
            %%% Grid and labels
                grid on
                xlabel('Cross shore Position'); ylabel('z');

        iter = 1;
        % Loop through the times to animate (skip every other for speed
        for t = t_0:2:t_end

            %%% Plot bathymetry offset by offshore MWL
            if iter == 1
                hold on
                plot(df.Xb_cut,df.Yb_cut - df.MWL(1))
                iter = iter + 1;
            end

            %%% Update eta profile at each time step
                set(D,'YData', D3_D.eta(1,:));
                set(F,'YData', D3_FW(iter,:));
    
            %%% Animate using drawnow()
                drawnow; 
            
        end
    


end

function D3D = DownsampleD3(D3c,tri_n,len_t)
    %%% Initialize output structure
        D3C = struct();
    %%% Pull out structure and variables
        tri = ['Trial',sprintf('%02d', tri_n)];
        t = D3c.(tri).t;
        eta = D3c.(tri).eta;
        len_WG = length(D3c.(tri).WG_cut);
    %%% Index out just submerged gauges
        eta = eta(:,1:len_WG);
    %%% Find the indices of integer value times
        t_int_i = find(mod(t, 1) == 0);
    %%% Get the integer valued time samples
        t_int = t(t_int_i);
        eta_int = eta(t_int_i,:);
    %%% Pull out the start time index out the beginning
        t0 = D3c.Trial05.t0;
        [~, t0_int] = min(abs(t0 - t_int));
        t_D3 = t_int(t0_int:t0_int+len_t-1);
        eta_D3 = eta_int(t0_int:t0_int+len_t-1,:);
    %%% Store to Structure
        D3D.WG = D3c.(tri).WG_cut;
        D3D.eta = eta_D3;
        D3D.t = t_D3;
end