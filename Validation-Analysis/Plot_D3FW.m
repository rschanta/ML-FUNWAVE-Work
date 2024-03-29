%%% Analyze_D3.m

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 23 January 2024
Edit made: 
    - Edited to incorporate new Dune3 Validation Structure
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Function or script
This file is intended to be run as a SCRIPT

%% Description
This file is used to compare the outputs of FW vs. the D3 actual data

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
name = 'D3_AS';
%% Import D3c Data
D3c = load('../Validation-Data/DUNE3_data/D3c.mat');
tri = ['Trial',sprintf('%02d', trial_no)];
%% Import FUNWAVE Results
eta_out = load(['./',name, '/',name,'_',tri, '_out.txt']);
bathyx = load(['./',name, '/',name,'_',tri, '_x.txt']);
bathyh = load(['./',name,'/', name,'_',tri, '_b.txt']);

%% Specify length of trial
len_t = length(eta_out)-1;
%% Process FUNWAVE Results
FW = struct();
    FW.t = 1:len_t;
    FW.eta = eta_out;
    FW.x = bathyx(1,:);
    FW.h = bathyh(1,:);
    FW.MWL = D3c.Trial05.MWL;


close all
%%
D3D = DownsampleD3(D3c,trial_no,len_t);

%% Skew and Asymmetry Plot
    s = struct(); s.D3_X = D3D.WG; s.FW_X = bathyx;
    [s.D3_skew, s.D3_asy, s.D3_t] = skasy(D3D.eta);
    [s.FW_skew, s.FW_asy, s.FW_t] = skasy(eta_out);

    %%% Figure
        figure(2)
            hold on
            % SKEW
                plot(s.D3_X,s.D3_skew,'Color','b','LineStyle','-');
                plot(s.FW_X,s.FW_skew,'Color','b','LineStyle','--');
            % ASYMMETRY
                plot(s.D3_X,s.D3_asy,'Color','r','LineStyle','-');
                plot(s.FW_X,s.FW_asy,'Color','r','LineStyle','--');
            % PLOT SETTINGS
                grid on
                title('Skew vs. Assymetry in the Cross Shotre: FUNWAVE vs. Dune 3')
                subtitle('Trial 5');
                legend('Dune 3: Skew', 'Funwave: Skew','Dune 3: Asy', 'Funwave: Asy' )
%%
animate_D3_Trial(D3D,FW,len_t)
   
%% Animate a Trial Function
function animate_D3_Trial(D3D,FW,len_t)

    %%% Construct the figure
    f = figure(1);
        % Initialize plot and title
            % Plot properties
                hold on
                title(['Plot of Dune 3 cs. FUNWAVE Simulation Trial ', num2str(5)]);
            % Plot Dune 3 Results
                D3 = plot(D3D.WG(1,:), D3D.eta(1,:),'Color','r', 'LineStyle','--'); 
            % Plot FUNWAVE Results
                FWP = plot(FW.x(1,:), FW.eta(1,:),'Color','b');
                
    
        % Set plot elements that don't change.
            %%% Set y limit to lowest point of beach profile and max eta
                ylim([-FW.MWL(1), max(max(FW.eta))]);
            %%% Grid and labels
                grid on
                xlabel('Cross shore Position'); ylabel('z');
                
           
        % Loop through the times to animate 
        iter = 1;
        for t = 1:len_t

            %%% Plot bathymetry offset by offshore MWL
            if iter == 1
                hold on
                plot(FW.x,-FW.h)
                iter = iter + 1;
                legend('Dune 3 Data Points', 'FUNWAVE Output', 'Beach Profile')
            
            end

            %%% Update etas profile at each time step
                set(D3,'YData', D3D.eta(t,:));
                set(FWP,'YData', FW.eta(t,:));

            %%% Set Title Name
                title_name = ['Plot of Dune 3 Trial ', num2str(5), ' Time = ', num2str(t)];
                set(get(gca,'Title'),'String',title_name);

    
            %%% Animate using drawnow()
                drawnow; 
                pause(0.1)
            
        end
    
end

%% Downsample Dune3 Data to integer values

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
