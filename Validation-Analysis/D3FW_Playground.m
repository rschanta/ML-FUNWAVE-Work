D3c = load('../Validation-Data/DUNE3_data/D3c.mat');
D3FW = load('../Analysis-Playground/D101_Tr05_out.mat');
D3FW = D3FW.out_struct;

%% 
D3a = load('../Validation-Data/DUNE3_data/D3a.mat');
%%
D3Sum = load('../Validation-Data/D3-Funwave-Data/D101/D101summary.mat')

%% Downsample the actual data as we need
D3D = DownsampleD3(D3c,5,1450);

%% Pull out the spatial domain too
[eta_XFW, WG_new] = setUpDomain(D3Sum,D3c,5,D3D);

%%
etaD3 = D3D.eta;
etaFW = D3FW.Tr05;
%%
close all
figure()
    hold on
        %%% Actual data
        f = plot(WG_new,etaD3(1,:));
        %%% Funwave
        g = plot(eta_XFW,etaFW(1,:));
        %%% Grid on
        grid on
        %%% Maxima and Minima
        lower = min([min(min(etaFW)),min(min(etaD3))]);
        upper = max([max(max(etaFW)),max(max(etaD3))]);
        ylim([lower upper])

    for j = 1:1450
        set(f,'YData',etaD3(j,:))
        set(g,'YData',etaFW(j,:))
        drawnow()
        pause(0.1)
    end


%% Set up domain
function [eta_XFW, WG_new] = setUpDomain(Sum,D3c,tri_n,D3D)
    trif = ['Tr',sprintf('%02d', tri_n)];
    tri = ['Trial',sprintf('%02d', tri_n)];

    %%% Get gauge locations
    offset = Sum.Summary.(trif).Xc_WK - D3c.(tri).WG_cut(1);
    WGD3 = D3D.WG;
    WG_new = WGD3 + offset ;

    %%% Get eta profile locations
    Mglob = double(Sum.Summary.(trif).Mglob);
    DX = Sum.Summary.(trif).DX;
    eta_XFW = 0:DX:DX*(Mglob-1);
end

%% Downsample
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