clear

all_data = load("stacked_Dune3.txt");

ind = 2:3:1802;

data_1D = all_data(ind,:);
%%
% Plot each row as an animation
for j = 1:size(data_1D, 1)
    plot(data_1D(j,:)); % Plot the current row
    length(data_1D(j,:))
    title(['Row: ' num2str(j)]); % Set title with the current row number
    xlabel('X');
    ylabel('Y');
    %ylim([-3, 3]); % Set y-axis limits
    %drawnow; % Update the figure window
    pause(0.1); % Add a pause for visualization (adjust as needed)
end
