%% Load in File to Work With
work_dir = 'C:/Users/rschanta/ML-Funwave-Work/';
D3_dir = 'Validation-Data/DUNE3_data/';
D3_struc = load(fullfile(work_dir,D3_dir,"D3_struct.mat"));




%% Plot Profiles Accordingly- Test on Profile 5
cla
close

%% Plot Data As Given
rd = D3_struc.('Trial05').raw_data;
wc = D3_struc.('Trial05').wave_condition;
cla
close all
figure(1)
    hold on

    % Plot Before and After Profiles
    plot(rd.bed_before(:,1),-rd.bed_before(:,2),'LineWidth',1.5,'Color','b','LineStyle','-')
    plot(rd.bed_after(:,1),-rd.bed_after(:,2),'LineWidth',1.5,'Color','r','LineStyle','-')

    % Plot Position of Offshore Conditions
    [~, index] = min(abs(rd.bed_before(:,2) - wc.h));
    xline(rd.bed_before(index,1), 'LineStyle','-','Color','g','LineWidth',2)
    
    % Plot Wave Gauges
    gauges = rd.WG_loc_x;
    plot([gauges; gauges], repmat(ylim',1,size(gauges,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
    
    % Plot Properties\
    grid on
    legend('Bed Before','Bed After','Wave Gauges', 'Offshore', 'Location','southwest');

%% Plot Processed Data
rd = D3_struc.('Trial05').raw_data;
wc = D3_struc.('Trial05').wave_condition;
%cla
%close all
    % Initial Work
        % Shift X coordinates to the left to the left
            Xshift_bef = rd.bed_before(:,1)' - min(rd.bed_before(:,1));
            Xshift_aft = rd.bed_after(:,1)' - min(rd.bed_after(:,1));
            WG_shift = gauges - min(rd.bed_before(:,1));
            
        % Elevation
            % flip
            el_bef = fliplr(rd.bed_before(:,2)');
            el_aft = fliplr(rd.bed_after(:,2)');
        
figure(2)
        hold on
        
        % Plot Before and After Profiles
        plot(Xshift_bef,-el_bef,'LineWidth',1.5,'Color','b','LineStyle','-')
        plot(Xshift_aft,-el_aft,'LineWidth',1.5,'Color','r','LineStyle','-')
        
        % Plot Position of Offshore Conditions
        [~, index] = min(abs(el_bef - wc.h));
        xline(Xshift_bef(index), 'LineStyle','-','Color','g','LineWidth',2)
        
        % Plot Wave Gauges
        plot([WG_sflip; WG_sflip], repmat(ylim',1,size(WG_sflip,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
        
        % Plot Propreties
        grid('on');
        legend('Bed Before','Bed After','Offshore', 'Wave Gauges', 'Location','northwest');
%% Plot Data Processed for 1024 sized FUNWAVE
            % Index of Offshore
            [~, i_o] = min(abs(el_bef - wc.h));

            % Slice off last 775 entries
            X_slice_end = Xshift_bef(i_o:end);
   
            % Interpolate End
            X_end_int = linspace(X_slice_end(1),X_slice_end(end),775);
            el_end_int = interp1(Xshift_bef,el_bef,X_end_int,"linear");
            
            % Interpolate Beginning
            dif = X_end_int(2)-X_end_int(1);
            
            % Ensure spacing the same beforehand
            X_beg_int = [];
            for j = 1:249
                new_x = X_end_int(1) - dif*j;
                X_beg_int = [new_x, X_beg_int];

            end
            el_beg_int = interp1(Xshift_bef,el_bef,X_beg_int);

            FW_slice_X = [X_beg_int, X_end_int];
            FW_slice_Y = [el_beg_int, el_end_int]; 

            [~, i_check] = min(abs(FW_slice_Y - wc.h));
            figure(4)
                plot(FW_slice_X,-FW_slice_Y)



    