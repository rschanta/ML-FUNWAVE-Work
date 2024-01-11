%% load in data
    work_dir = 'C:/Users/rschanta/ML-Funwave-Work/';
    D3c_path = 'Validation-Data/DUNE3_data/D3c';
    D3c = load(fullfile(work_dir,D3c_path));

%% Plot profiles
    WG = D3c.Trial08.WG;
    eta = D3c.Trial08.eta;
    % Find beginning times index
    t = D3c.Trial08.t;
    t0 = D3c.Trial08.t0;
    t_end = D3c.Trial08.t_end;
    [~, j_0] = min(abs(t0 -t));
    [~, j_end] = min(abs(t_end -t));

close all
figure(1)
    % Plot first element of animation
        hold on
        p = plot(WG,fliplr(eta(1,:))); 
        yyaxis right
        g = plot(D3c.Trial05.Xb,D3c.Trial05.Yb,'LineWidth', 1.5,'Color',"#D95319",'LineStyle','-');
        ylim([-4.5, 4.5])
        yyaxis left
    % Set invariants
        ylim([min(min(eta)), max(max(eta))]);
        xlabel('X'); ylabel('/eta');
        title('Default');
        grid on
    % Align axes
        yyaxis right; ylimr = get(gca,'Ylim');ratio = ylimr(1)/ylimr(2);
        yyaxis left; yliml = get(gca,'Ylim');
        if yliml(2)*ratio<yliml(1)
            set(gca,'Ylim',[yliml(2)*ratio yliml(2)])
        else
            set(gca,'Ylim',[yliml(1) yliml(1)/ratio])
        end
    
    % Set up movie writer
        delete Animation.mp4
        writerObj = VideoWriter('Animation.mp4', 'MPEG-4');
        writerObj.FrameRate = 10; % Frame Rate
        open(writerObj);

    % Plot each 
    iter = 0;
    for j = j_0:10:j_end
        % Set XData and YData for plot
        set(p, 'YData', fliplr(eta(j,:)));

        % Set Title of Plot
        if mod(iter, 10) == 0
            title_name = ['t = ', num2str(D3c.Trial05.t(j))];
            set(get(gca,'Title'),'String',title_name);
            
        end
        iter = iter + 1;

        % Animate: drawnow() to update, pause()
        drawnow; % Update the figure window
        %pause(0.0001); 

        % Get frame for animation and save to video writer
        frame = getframe(gcf); 
        writeVideo(writerObj, frame); 
    end

    close(writerObj)

