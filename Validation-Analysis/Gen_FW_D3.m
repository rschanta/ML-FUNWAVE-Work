%% Load in Data
work_dir = 'C:/Users/rschanta/ML-Funwave-Work/';
D3_dir = 'Validation-Data/DUNE3_data/D3c.mat';
D3c_name = fullfile(work_dir,D3_dir);
D3c = load(D3c_name); clear('work_dir',"D3_dir",'D3c_name');
%% Plotting for Sanity
    close all
    %%% Regular Data
    Xb = D3c.Trial05.Xb; Xa = D3c.Trial05.Xa;
    Yb = D3c.Trial05.Yb; Ya = D3c.Trial05.Ya;
    WG = D3c.Trial05.WG; Xos = D3c.Trial05.Xos;

    %%% Shifted Data
    Xb_s = D3c.Trial05.Xb_s; Xa_s = D3c.Trial05.Xa_s;
    Yb_s = D3c.Trial05.Yb_s; Ya_s = D3c.Trial05.Ya_s;
    WG_s = D3c.Trial05.WG_s; Xos_s = D3c.Trial05.Xos_s;

    
    subplot(1,2,1)
    hold on
        plot(Xb,Yb,'LineWidth', 1.5,'Color','b','LineStyle','-');
        plot(Xa,Ya,'LineWidth',1.5,'Color','r','LineStyle','-');
        %xline(Xos, 'LineStyle','-','Color','g','LineWidth',2)
        xline(Xb(6805), 'LineStyle', '--', 'Color', 'g', 'LineWidth', 2)
        xline(Xb(7420), 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2)
        plot([WG; WG], repmat(ylim',1,size(WG,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
        title('Data as Given'); grid on

        

    subplot(1,2,2)
    hold on
    plot(Xb_s, Yb_s, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-');
    plot(Xa_s, Ya_s, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-');
    %xline(Xos_s, 'LineStyle', '-', 'Color', 'g', 'LineWidth', 2)
    xline(Xb_s(2198), 'LineStyle', '--', 'Color', 'g', 'LineWidth', 2)
    xline(Xb_s(1583), 'LineStyle', '--', 'Color', 'r', 'LineWidth', 2)
    plot([WG_s; WG_s], repmat(ylim', 1, size(WG_s, 2)), 'Color', [0 0 0, 0.5], 'LineStyle', '--', 'LineWidth', 0.75);
    title('Data Shifted'); grid on

%% Reference bathy file

a_15 = load("C:/Users/rschanta/OneDrive - University of Delaware - o365/Desktop/depth_a15.txt");
levee = load("C:/Users/rschanta/OneDrive - University of Delaware - o365/Desktop/depth_levee.txt");

%% Make bathy file
%%% Construct bathymetry file
    X_FW = linspace(0,round(max(Xb_s)),1024);
    Y_FW = round(interp1(Xb_s,Yb_s,X_FW, 'linear'),4);

    % Smooth out around wave maker
    Y_FW(245:255) = Y_FW(250);
    bathy = [-Y_FW];
%%% Plot for sanity
    close all
    figure(2)
        plot(X_FW,Y_FW)

%%% Get other relevant constants
    DX = diff(X_FW); DX = DX(1);
    amp = D3c.Trial05.Hs/2;
    period = D3c.Trial05.Tp;

%%% Save bathy file
    writematrix(bathy, 'C:/Users/rschanta/OneDrive - University of Delaware - o365/Desktop/bathy_Trial05_1D.txt')

