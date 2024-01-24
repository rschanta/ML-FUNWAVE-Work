function animate_1D(eta)

close all
figure()
    p = plot(eta(1,:),'Color','b','LineWidth',2);
    grid on
    ylim([min(min(eta)),max(max(eta))]);

for j = 2:length(eta)
    set(p,'YData',eta(j,:))
    drawnow()
    pause(0.05)
end

end