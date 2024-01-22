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
%% Import D3c
D3c = load('../Validation-Data/DUNE3_data/D3c.mat');
tri = ['Trial',sprintf('%02d', trial_no)];

%% 
close all
animate_D3_Trial(D3c,24,false)
%% Animate a Trial Function


function animate_D3_Trial(D3c,trial_no,save_movie)
    %%% Construct trial name in directory and pull out
        tri = ['Trial',sprintf('%02d', trial_no)];
        df = D3c.(tri);
    %%% Get number of wave gauges in the submerged profile
    len_WG = length(df.WG_cut);

    %%% Construct the figure
    f = figure(1);
        % Initialize plot and title
            p = plot(df.WG_cut,df.eta(1,1:len_WG)); 
            title(['Plot of Dune 3 Trial ', num2str(trial_no)]);
    
        % Set plot elements that don't change.
            %%% Set y limit to lowest point of beach profile and max eta
                ylim([-df.MWL(1), max(max(df.eta))]);
            %%% Grid and labels
                grid on
                xlabel('Cross shore Position'); ylabel('z');
            
            
        
        % Set up movie writer if selected
        if save_movie
            writerObj = VideoWriter('tri.mp4', 'MPEG-4');
            writerObj.FrameRate = 10; % Frame Rate
            open(writerObj);
        end

        % Pull out the eta time series
            %%% Get indices for start and end time
                [~, t_0] = min(abs(df.t0 -df.t));
                [~, t_end] = min(abs(df.t_end -df.t));
            %%% Display indices
                disp(['Start Time is: ', num2str(df.t(t_0))]);
                disp(['End Time is: ', num2str(df.t(t_end))]);

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
                set(p,'YData', df.eta(t,1:len_WG));
    
            %%% Set title of plot to include current time (whole number)
            if floor(df.t(t))==df.t(t)
                title_name = ['Plot of Dune 3 Trial ', num2str(trial_no), ' Time = ', num2str(df.t(t))];
                set(get(gca,'Title'),'String',title_name);
            end
    
            %%% Animate using drawnow()
                drawnow; 
            
            %%% Save frame to movie if selected
            if save_movie
                frame = getframe(gcf); 
                writeVideo(writerObj, frame); 
            end
            % Get frame for animation and save to video writer
            % 
        end
    
        % Close movie writer if selected
        if save_movie
            close(writerObj)
        end

end