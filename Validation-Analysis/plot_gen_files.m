%% Load in File to Work With
work_dir = 'C:/Users/rschanta/ML-Funwave-Work/';
D3_dir = 'Validation-Data/DUNE3_data/';
D3_struc = load(fullfile(work_dir,D3_dir,"D3_struct.mat"));

%% Clean
close all
clc


%% Plot Profiles Accordingly- Test on Profile 5
rd = D3_struc.('Trial05').raw_data;
wc = D3_struc.('Trial05').wave_condition;


%% Plot Data As Given
% Initial Work
    % Grab before and after profiles
        X_before = rd.bed_before(:,1)'; X_after = rd.bed_after(:,1)';
        Y_before = -rd.bed_before(:,2)'; Y_after = -rd.bed_after(:,2)';
    % Define offshore height
        h = wc.h;
    % Find position of offshore conditions
        [~, i_off] = min(abs(Y_before + wc.h));
    % Get position of wave gauges
        WG = rd.WG_loc_x;
        
% Plot
figure(1)
    hold on

    % Plot Before and After Profiles
    plot(X_before,Y_before,'LineWidth',1.5,'Color','b','LineStyle','-')
    plot(X_after,Y_after,'LineWidth',1.5,'Color','r','LineStyle','-')

    % Plot Position of Offshore Conditions
    xline(X_before(i_off), 'LineStyle','-','Color','g','LineWidth',2)
    
    % Plot Wave Gauges
    plot([WG; WG], repmat(ylim',1,size(WG,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
    
    % Plot Properties
    grid on
    legend('Bed Before','Bed After','Wave Gauges', 'Offshore', 'Location','southwest');

%% Plot Processed Data

    % Initial Work
        % Shift X coordinates to the left to the left
            X_bef_sh = X_before - min(X_before);
            X_aft_sh = X_after - min(X_after);
            WG_sh = WG - min(X_before);
            
        % Flip Y coordinate directions as needed
            % flip
            Y_bef_fl = fliplr(Y_before);
            Y_aft_fl = fliplr(Y_after);

        % Find position of offshore Conditions
        [~, i_off_fl] = min(abs(Y_bef_fl + h));

% Plot
figure(2)
        hold on
        
        % Plot Before and After Profiles
        plot(X_bef_sh,Y_bef_fl,'LineWidth',1.5,'Color','b','LineStyle','-')
        plot(X_aft_sh,Y_aft_fl,'LineWidth',1.5,'Color','r','LineStyle','-')
        
        % Plot Position of Offshore Conditions
        xline(X_bef_sh(i_off_fl), 'LineStyle','-','Color','g','LineWidth',2)
        
        % Plot Wave Gauges
        plot([WG_sh; WG_sh], repmat(ylim',1,size(WG_sh,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
        
        % Plot Propreties
        grid('on');
        legend('Bed Before','Bed After','Offshore', 'Wave Gauges', 'Location','northwest');

%% Plot Data Processed for 1024 sized FUNWAVE
     % Initial Work
            % Slice off entries After Offshore (AO) conditions
            X_bef_AO = X_bef_sh(i_off_fl:end);
   
            % Interpolate End (AO)
            X_bef_AO_int = linspace(X_bef_AO(1),X_bef_AO(end),775);
            Y_bef_AO_int = interp1(X_bef_sh,Y_bef_fl,X_bef_AO_int,"linear");
            
            % Interpolate Beginning Before Offshore Conditions (BO)
                % Ensure that spacing is the same on each side
                    spacing = X_bef_AO_int(2)-X_bef_AO_int(1);
            
                % Generate X values
                X_bef_BO_int = [];
                for j = 1:249
                    new_x = X_bef_AO_int(1) - spacing*j;
                    X_bef_BO_int = [new_x, X_bef_BO_int];
    
                end

                % Generate Y values
                Y_bef_BO_int = interp1(X_bef_sh,Y_bef_fl,X_bef_BO_int);

            % Combine to form total series for FUNWAVE
            X_FW = [X_bef_BO_int, X_bef_AO_int];
            Y_FW = [Y_bef_BO_int, Y_bef_AO_int]; 

            % Shift left
            X_FW = X_FW - min(X_FW);
            % Check offshore position 
            [~, i_check] = min(abs(Y_FW + h));

            % Place Sponge at 180
            i_sponge = 180;
            
% Plot
figure(3)
    hold on

    % Plot Input Profile
    plot(X_FW,Y_FW,'LineWidth',1.5,'Color','b','LineStyle','-')

    % Plot Position of Offshore Conditions
    xline(X_FW(i_check), 'LineStyle','-','Color','g','LineWidth',2)

    % Plot Position of Offshore Conditions
    xline(X_FW(i_sponge), 'LineStyle','-','Color','r','LineWidth',2)

    % Plot Properties
    grid on
    legend('Bathymetry','Wavemaker','Sponge','southeast');


    