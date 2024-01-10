%% Load data
all_data = load("stacked_Dune3.txt");
ind = 2:3:1802;
data_1D = all_data(ind,:);

%% Plot Data
f = figure(1)
    % Plot first element of animation
        p = plot(1:1024,data_1D(1,:)); 

    % Set invariants
        ylim([-2e-5, 2e-5]);
        xlabel('X');
        ylabel('Y');
        title('Default')
    
    % Set up movie writer
        writerObj = VideoWriter('animation3.mp4', 'MPEG-4');
        writerObj.FrameRate = 10; % Frame Rate
        open(writerObj);

    % Plot each 
    for j = 1:size(data_1D, 1)
        % Set XData and YData for plot
        set(p, 'XData', 1:1024,'YData', data_1D(j,:));

        % Set Title of Plot
        title_name = ['Row: ' num2str(j)];
        set(get(gca,'Title'),'String',title_name);

        % Animate: drawnow() to update, pause()
        drawnow; % Update the figure window
        pause(0.05); 

        % Get frame for animation and save to video writer
        frame = getframe(gcf); 
        writeVideo(writerObj, frame); 
    end

    close(writerObj)
