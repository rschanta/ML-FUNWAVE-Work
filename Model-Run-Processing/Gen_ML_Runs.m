%% Naming
    % Name for the Run: Should be somewhat descriptive of the purpose
        Run_Name = 'ML-refactor';
    % Directory where all the files should be generated
        gen_dir = './test_out/';

%% Setup
    %%% Load in template to use and path to the FW-Input function
        load('./Template/ML-Template.mat')
        Temp = ML_base;
        addpath('../Helper-Functions/FW-Input/')

    %%% Construct the directories needed for generation
        d = construct_directories(Run_Name,gen_dir);
    
%% File Creation
    %%% Define variable parameter ranges (R)
        r_S = linspace(0.05, 0.1,10); % Slope
        r_T = linspace(3, 12,10);     % Period
        r_A = linspace(0.5, 1.5,10);  % Amplitude

    %%% Loop through ranges
    iter = 1; 
    v = struct();
    for S = r_S; for T = r_T; for A = r_A
        %%% File naming
            n = construct_file_names(d,iter);
        
        %%% Set parameters in Structures
            % Title
                Temp.TITLE = n.TITLE;
            % Xslp (note- Mglob is an int)
                Xslp = double(Temp.Mglob)*Temp.DX-Temp.DEPTH_FLAT/S;
                [Temp, v] = set('Xslp',Xslp,Temp,v);
            % 3 Loop variables
                [Temp, v] = set('AMP_WK',A,Temp,v);
                [Temp, v] = set('SLP',S,Temp,v);
                [Temp, v] = set('Tperiod',T,Temp,v);
            % Result Folder
                Temp.RESULT_FOLDER = n.RESULT_FOLDER;
        
        %%% Generate input.txt file from Structure
            FW_input(Temp,n.input_path);
    
        %%% Continue iteration
            iter = iter + 1;
    end; end; end

    %%% Save summary structures: 
        [sumconst, sumvars] = save_summaries(d,v,Temp);
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functions
%%% Function for Directories
function d = construct_directories(Run_Name,gen_dir)
    % Store inputs
        d.Run_Name = Run_Name;
        d.gen_dir = gen_dir;
    % Create input, summary, and output directories
        d.input_dir = fullfile(gen_dir,Run_Name,'in');
        d.summary_dir = fullfile(gen_dir,Run_Name,'sum');
        d.output_dir = fullfile(gen_dir,Run_Name,'out');
    % Creation of directories if they do not exist
        if ~exist(d.input_dir, 'dir'), mkdir(d.input_dir), end
        if ~exist(d.summary_dir, 'dir'), mkdir(d.summary_dir), end
end

%%% Function for File Names
function n = construct_file_names(d,iter)
    %%% Construct iteration number as 5 digits
        no = sprintf('%05d', iter); % iteration number
    %%% Construct name of input.txt file and path to it
        n.input_name = ['input_',no,'.txt']; 
        n.input_path = fullfile(d.input_dir,n.input_name);

    %%% Construct Title for input.txt file
        n.TITLE = [d.Run_Name,'_',n.input_name];
    %%% Construct name of RESULT_FOLDER and path to it
        output_name = ['out_',no,'.txt']; % RESULT_FOLDER name
        % NOTE: need to cognizant of MATLAB / vs \ processing
            RESULT_FOLDER = [fullfile(d.output_dir,output_name),'/'];
            n.RESULT_FOLDER = strrep(RESULT_FOLDER,'\','/');       
end

%%% Function to set variable and store as a variable in sumvars
function [Temp, v] = set(Var,Value,Temp,v)
    %%% Add to template
    Temp.(Var) = Value;
    %%% Add to summary of variables
    if ~isfield(v, Var)
        v.(Var) = Value;
    else
        v.(Var) = [v.(Var); Value];
    end
end

%%% Function to save summary variables
function [sumconst, sumvars] = save_summaries(d,v,FW)
    %%% Redefine v as sumvars
        sumvars = v;
    %%% Remove variable fields of FW
        var_fields = fieldnames(sumvars);
        sumconst = rmfield(FW,var_fields);
    %%% Construct file names for saving
        sumvars_path = fullfile(d.summary_dir,'sumvars.mat');
        sumconst_path = fullfile(d.summary_dir,'sumconst.mat');
    %%% Save each
        save(sumvars_path,'sumvars');
        save(sumconst_path,'sumconst');
end
