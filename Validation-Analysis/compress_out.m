
function compress_out(name,all,number)



%%% Paths to Files
    lustre = '/lustre/scratch/rschanta/';
    name_dir = fullfile(lustre,name);

    

%%% Grab single trial by number
    function grab_outputs(number,name_dir)
    % Convert number to string
        number_str = sprintf('%02d', number);
        out = ['Tr',number_str];
    % Create output directory for trial
        out_dir = fullfile(name_dir,out);
        Mglob = 200; time_max = 1450;

    % Load in the eta files: Start with 0 and work up until try block
    % fails (helps with flexibility)
        eta_out = zeros(time_max,Mglob);
        for j = 1:time_max
            %%% Construct file name
                file = fullfile(out_dir,['eta_',sprintf('%05d', j-1)]);
            %%% Read the binary file info
                fileID = fopen(file)
                eta = fread(fileID,[Mglob,Nglob],'single');
                fclose(fileID);
            %%% Pull out just a middle row
                eta_out(j,:) = eta(2,:);
        end
    % Write the matrix out
        disp('Writing Files');
        writematrix(eta_out, ['eta_out,','.txt']);
        save([file_name,'.mat'],'eta_out');
        parquetwrite(['eta_out,','.parquet'],array2table(eta_out));
    end
    



end
    


