work_dir = 'C:/Users/rschanta/ML-Funwave-Work/';

D3_dir = 'Validation-Data/DUNE3_data/';
gauges = dir(fullfile(work_dir,D3_dir));

%%
D3_struc = struct(); 
for j = 1:length(gauges)
    name = gauges(j).name;
    try
        if (strncmp(name, 'Trial', 5)) && (length(name) == 7)
            D3_struc.(name).('raw_data') = load(fullfile(work_dir,D3_dir,name,'raw_data.mat')).raw_data;
            D3_struc.(name).('filtered_data') = load(fullfile(work_dir,D3_dir,name,'filtered_data.mat')).filtered_data;
            D3_struc.(name).('wave_condition') = load(fullfile(work_dir,D3_dir,name,'wave_condition.mat')).wave_condition;
        end
    end
end
%%
save_file_name = fullfile(work_dir,D3_dir,'D3_struct.mat');
save(save_file_name,'-struct','D3_struc');


%%
cla
close
rd = D3_struc.('Trial05').raw_data;
%plot(raw_data.bed_before(:,1),-raw_data.bed_before(:,2))
figure(1)
    hold on
    plot(rd.bed_before(:,1),-rd.bed_before(:,2),'LineWidth',1.5,'Color','b','LineStyle','-')
    plot(rd.bed_after(:,1),-rd.bed_after(:,2),'LineWidth',1.5,'Color','r','LineStyle','-')
    grid on
    gauges = rd.WG_loc_x
    plot([gauges; gauges], repmat(ylim',1,size(gauges,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
    legend('Bed Before','Bed After','Wave Gauges', 'Location','southwest');

%% Processed
% Shift to the left
Xshift_bef = rd.bed_before(:,1)' - min(rd.bed_before(:,1));
Xshift_aft = rd.bed_after(:,1)' - min(rd.bed_after(:,1));
WG_shift = gauges - min(rd.bed_before(:,1));

% Flip about 
Xsflip_bef = fliplr(Xshift_bef);
Xsflip_aft = fliplr(Xshift_aft);
WG_sflip = max(Xshift_bef) - WG_shift;

figure(2)
    hold on
    plot(Xsflip_bef,-rd.bed_before(:,2),'LineWidth',1.5,'Color','b','LineStyle','-')
    plot(Xsflip_aft,-rd.bed_after(:,2),'LineWidth',1.5,'Color','r','LineStyle','-')
    grid on
    plot([WG_sflip; WG_sflip], repmat(ylim',1,size(WG_sflip,2)), 'Color',[0 0 0,0.5],'LineStyle','--','LineWidth',0.75);
    legend('Bed Before','Bed After','Wave Gauges', 'Location','southwest');
%%
[~, index] = min(abs(rd.bed_before(:,2) - 2));
Xsflip_bef(index)


    