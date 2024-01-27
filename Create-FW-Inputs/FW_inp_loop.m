%% Define where things will output to
base = './Test_Today_8/';

%% Construct a default input and change the common parameters
template = FW_input('Template');
    template.edit('TOTAL_TIME',600);
    template.edit('DEPTH_TYPE','SLOPE');
    template.edit('DEPTH_FLAT',6);
    template.edit('DEP_WK',6);
    template.edit('Xc_WK',250);
    template.edit('Sponge_west_width',180)
    template.edit('FIELD_IO_TYPE','BINARY');
        

%% Loop through different parameters
    %%% Define variable parameter ranges (R)
        r_S = linspace(0.05, 0.1,10); % Slope
        r_T = linspace(3, 12,10);     % Period
        r_A = linspace(0.5, 1.5,10);  % Amplitude

    %%% Counter and storage variable
    iter = 1;
    sumvars = table();
    sum_inputs = struct();
    %%% Start the loop
    for S = r_S; for T = r_T; for A = r_A
        % Create an input.txt object from template
            input = template;
        % Calculate/Create Parameters
            cv = create_params(iter,input,S,base);
        % Change parameters of interest
            input.edit('TITLE',cv.title);
            input.set('Xslp',cv.Xslp);
            input.set('AMP_WK',A);
            input.set('SLP',S);
            input.set('Tperiod',T);
            input.edit('RESULT_FOLDER',cv.RESULT_FOLDER);
        % Write file to output directory
            input.Name = cv.title;
            input.print_input(fullfile(base,'in'));
        % Progress iteration
            iter = iter + 1;
        % Store set variables to sumvars
            sum_inputs.(cv.title) = input;
            sumvars = [sumvars; struct2table(input.SetVars)];
    end; end; end

%% Store sumvars and a FW Template
    %%% Names and directory
        sum_dir = fullfile(base,"sum");
        sumvars_path = fullfile(sum_dir,"sumvars.mat");
        suminputs_path = fullfile(sum_dir,"suminputs.mat");
        if ~exist(sum_dir, 'dir'), mkdir(sum_dir), end
    %%% Save
        save(sumvars_path,"sumvars");
        save(suminputs_path, "sum_inputs")




function cv =  create_params(iter,input,S,base)
    %%% Calculate Xslp
        % Pull out variables
            Mglob = double(input.FW.Mglob);
            DX = input.FW.DX;
            DEPTH_FLAT = input.FW.DEPTH_FLAT;
        % Calcualte
            cv.Xslp = Mglob*DX - DEPTH_FLAT/S;

    %%% Construct input.txt file name
        cv.title = ['input_',sprintf('%05d',iter)];

    %%% Construct RESULT_FOLDER name
        output_name = ['out_',sprintf('%05d',iter)];
        RESULT_FOLDER = [fullfile(base,output_name),'/'];
        RESULT_FOLDER = strrep(RESULT_FOLDER,'\','/');
        cv.RESULT_FOLDER = RESULT_FOLDER;
end
