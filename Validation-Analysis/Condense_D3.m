%% Save All Data (a)
D3a = struct(); 

%%% Relevant Directories and folders
    work_dir = 'C:/Users/rschanta/ML-Funwave-Work/';
    D3_dir = 'Validation-Data/DUNE3_data/';
    tr_folders = dir(fullfile(work_dir,D3_dir));

%%% Loop through and get data from all folders
for j = 1:length(tr_folders)
    name = tr_folders(j).name;
    try
        if (strncmp(name, 'Trial', 5)) && (length(name) == 7)
            D3a.(name).('raw_data') = load(fullfile(work_dir,D3_dir,name,'raw_data.mat')).raw_data;
            D3a.(name).('filtered_data') = load(fullfile(work_dir,D3_dir,name,'filtered_data.mat')).filtered_data;
            D3a.(name).('wave_condition') = load(fullfile(work_dir,D3_dir,name,'wave_condition.mat')).wave_condition;
        end
    end
end
%%
D3a_name = fullfile(work_dir,D3_dir,'D3a.mat');
save(D3a_name,'-struct','D3a');






%% Save Condensed/Processed Version (c)
D3c = struct();
% Loop through all trials
for tr = 5:24
%%% Initialize structure
    D3 = struct();

%%% Load in Data
   % Construct names
    name = ['Trial',sprintf('%02d', tr)];

    % Load in Raw and Wave Conditions
    rd = D3a.(name).raw_data;
    wc = D3a.(name).wave_condition;

%%% Wave Conditions
	D3.Hs = wc.Hs;
    D3.Tp = wc.Tp;
    D3.h = wc.h;

%%% Raw Profile and Gauges
    % Get profiles as given
    Xb = rd.bed_before(:,1)'; Xa = rd.bed_after(:,1)';
    Yb = -rd.bed_before(:,2)'; Ya = -rd.bed_after(:,2)';

    % Position of Wave Gauges
    WG = rd.WG_loc_x;

    % Position of offshore conditions
    [~, i_off] = min(abs(Yb + wc.h));
    Xos = Xb(i_off);

    % Store to structure
    D3.Xb = Xb; D3.Xa = Xa;
    D3.Yb = Yb; D3.Ya = Ya;
    D3.WG = WG;
    D3.Xos = Xos;

%%% Profile Shifted Left and Flipped
    % Shift X coordinates left
    Xb_s = Xb - min(Xb);
    Xa_s = Xa - min(Xa);
    WG_s = WG - min(Xb);
            
    % Adjust Y coordinates accordingly
    Yb_s = fliplr(Yb);
    Ya_s = fliplr(Ya);

    % Find position of offshore Conditions
    [~, i_off_s] = min(abs(Yb_s + wc.h));
    Xos_s = Xb_s(i_off);

    D3.Xb_s = Xb_s; D3.Xa_s = Xa_s;
    D3.Yb_s = Yb_s; D3.Ya_s = Ya_s;
    D3.WG_s = WG_s;
    D3.Xos_s = Xos_s;

%%% Pass through other properties
    % eta profile
    D3.eta = rd.eta;

    % time info
    D3.t = rd.t;
    D3.t0 = rd.t0;
    D3.t_end = rd.t_end;

    % wave statistics
    D3.MWL = rd.MWL;
    D3.Hrms = rd.Hrms;
    D3.Hmo = rd.Hmo;
    D3.H3 = rd.H3;
    D3.eta_max = wc.eta_max;
    D3.eta_min = wc.eta_min;

%%% Add to structure
    D3c.(name) = D3;

end

%%% Save Structure to File
D3c_name = fullfile(work_dir,D3_dir,'D3c.mat');
save(D3c_name,'-struct','D3c');

%% Plotting for Sanity
Xb = D3c.Trial05.Xb; Xa = D3c.Trial05.Xa;
Yb = D3c.Trial05.Yb; Ya = D3c.Trial05.Ya;
WG = D3c.Trial05.WG;
Xos = D3c.Trial05.Xos;
close all
figure(1)
    hold on
        plot(Xb,Yb,'LineWidth', 1.5,'Color','b','LineStyle','-');
        plot(Xa,Ya,'LineWidth',1.5,'Color','r','LineStyle','-');

        xline(Xos, 'LineStyle','-','Color','g','LineWidth',2)
        plot([WG; WG], repmat(ylim',1,size(WG,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
        title('Data as Given')
        grid on

Xb_s = D3c.Trial05.Xb_s;
Xa_s = D3c.Trial05.Xa_s;
Yb_s = D3c.Trial05.Yb_s;
Ya_s = D3c.Trial05.Ya_s;
WG_s = D3c.Trial05.WG_s;
Xos_s = D3c.Trial05.Xos_s;

figure(2)
hold on
    plot(Xb_s, Yb_s, 'LineWidth', 1.5, 'Color', 'b', 'LineStyle', '-');
    plot(Xa_s, Ya_s, 'LineWidth', 1.5, 'Color', 'r', 'LineStyle', '-');

    xline(Xos_s, 'LineStyle', '-', 'Color', 'g', 'LineWidth', 2)
    plot([WG_s; WG_s], repmat(ylim', 1, size(WG_s, 2)), 'Color', [0 0 0, 0.5], 'LineStyle', '--', 'LineWidth', 0.75);
    title('Data Shifted')
    grid on


%% Create a save bathy file
    % 3 x 1024 array
    bathy_FW = [Y_FW; Y_FW; Y_FW];
    % other relevant information
    DX = DX;
    const_tab = table();
    const_tab.DX = DX;
    const_tab.AMP_WK = wc.Hs/2;
    const_tab.TPERIOD = wc.Tp;
    DY = 1;
    writematrix(-bathy_FW, 'bathy_Trial05.txt')
    writetable(const_tab,'Const_Trial05.txt')
