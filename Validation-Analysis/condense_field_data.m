work_dir = 'C:/Users/rschanta/ML-Funwave-Work/';

D3_dir = 'Validation-Data/DUNE3_data/';
foo = dir(fullfile(work_dir,D3_dir));

%%
D3_struc = struct(); 
for j = 1:length(foo)
    name = foo(j).name;
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


