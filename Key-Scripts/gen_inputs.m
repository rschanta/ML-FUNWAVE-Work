%%% GENERATE_INPUTS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 4 January 2024
Edit made: 
    - Changed rounding of tabular values in sumvars to accomodate more
    decimal places
Ryan Schanta
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%% DOCUMENTATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{ 
%% Description
This function generates a series of 'input.txt' files for FUNWAVE, 
labeled 'input_XXXXX.txt' in a subdirectory. A file summarizing the 
parameters constant between each 'input.txt' file are output to 
'sumconst.txt' and a file summarizing the parameters varied between each
'input.txt' file are output to 'sumvars.txt' in a separate subdirectory

%% Arguments
'in': (str)- The directory within which the subdirectory containing all
    the 'input.txt' files will be generated. In the directory specified
    by 'in', a subdirectory specified by the name of the function
    appended by '-in' will contain the 'input.txt' files. Use './' to
    generate in the cwd.
'sum': (str)- The directory within which the subdirectory containing the 
    two summary files (sumconst.txt & sumvars.txt) will be generated. In 
    the directory specified by 'sum', a subdirectory specified by the 
    name of the function appended by '-sum' will contain the files. Use 
    './' to generate in the cwd.
'out': (str)- FUNWAVE parameter. The directory in which FUNWAVE will
    generate the output subdirectory(s) for each model run containing all
    other outputs specified by FUNWAVE. In the directory specified by 
    'out', a subdirectory specified by the name of the function appended 
    by '-out' will contain the files. Within this directory, the output
    directories for the FUNWAVE model runs will be generated. See 
    'overwrite' for more details.
'overwrite': (boolean)- Setting for overwriting results. If set to TRUE, 
    the outputs from all runs will be generated in the folder 'overwrite'
    within the output directory, meaning that the results are not saved
    from one run to the next if run iteratively. If set to FALSE, a new
    folder subdirectory 'out_XXXXX' is created for each 'input_XXXXX.txt'
    file. Be mindful of memory constaints.
'stge': (boolean)- Setting for station generation. 
    
    

%% Outputs

%% General Use Notes
    Respect the 'DO NOT EDIT' flags found in the headers or on individual
    lines
    
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Function Definition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gen_inputs(in,sum,out,overwrite,stge,stgi,stna,stno)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File I/O SETUP- DO NOT EDIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get name of function
fna = dbstack().name;

% Name files by name of function
in = [in,fna,'-in']; % Location of input.txt files
sum = [sum,fna,'-sum']; % Location of summary file
out = [out,fna,'-out']; % Location of output subdirectories

% Create directories if they don't exist
if ~exist(in, 'dir') mkdir(in), end
if ~exist(sum, 'dir') mkdir(sum), end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameters to Vary between models- EDIT AS NEEDED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterator and array to store variable parameters (don't edit)
iter = 1; sumvars = table();

% Set up nested loop here
for slp = linspace(0.05, 0.1,10)
for tperiod = linspace(3, 12,10)
for ampwk = linspace(0.5, 1.5,10)

    % CONDITION: positive xslp (make sure these all match below)
    Mglob = 1024; DX = 1 ; DEPTH_FLAT = 10 ; 
    xslp = Mglob*DX-DEPTH_FLAT/slp;
    if xslp>0

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % FILE SETUP- DO NOT EDIT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create new file
        fid = createInput(in,iter); % don't edit
    % Print title and header
        TITLE(fid); % don't edit
        setparam('TITLE',['input_',sprintf('%05d', iter)],fid); % don't edit
    % Initialize empty table for variable parameters
        vtab = table(); % don't edit
        vtab.iter = iter; % don't edit

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set variable parameters here- EDIT AS NEEDED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Output variables allowed to vary (make sure they're strings!)
        ML_VARS(fid) % don't edit
        vtab = setparam_vars('SLP',slp,vtab,fid);
        vtab = setparam_vars('Tperiod',tperiod,vtab,fid);
        vtab = setparam_vars('AMP_WK',ampwk,vtab,fid);
        vtab = setparam_vars('Xslp',xslp,vtab,fid);
        sumvars = vertcat(sumvars,vtab); % don't edit
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set results folder here- DO NOT EDIT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        setresultfolder(fid,iter,out,overwrite); % don't edit

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set station settings- EDIT AS NEEDED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Display warning- can't generate stations and use a station file
        if (stge == true && stgi == true)
            disp('Warning: Cannot generate stations if station file already set.')
    % GENERATE STATIONS- choose how many stations wanted
        elseif(stge == true)
            gen_stations(in, iter, Mglob,100,fid)
    % STATION FILE- writes name of station file to 'input.txt'
        elseif(stgi == true)
            given_stations(stna,stno,fid);
    % NO STATIONS- for case with no station file usage
        else
            setparam('NumberStations','0',fid);
            setparam('STATIONS_FILE','not_found',fid)
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set constant parameters here- DO NOT EDIT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Output everything in common
        Constant_VARS(fid); 
        sumconst = table(); 
        sumconst = printCommonParams(fid,sumconst); 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % End File and Loops
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Close file
        fclose(fid); % don't edit
    % Progress iteration
        iter = iter + 1; % don't edit

    end % for conditional on xslp

    % End loops (one per parameter)
end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Summary Tables- DO NOT EDIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables allowed to vary
writetable(sumvars, [sum,'/sumvars'], 'Delimiter', ' ');
writetable(sumconst, [sum,'/sumconst'], 'Delimiter', ' ');
disp([num2str(iter-1), ' Files successfully generated to ', in])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters in Common between models- EDIT AS NEEDED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function const = printCommonParams(fid,const)
    PARALLEL_INFO(fid)
        const = setparam_const('PX','16',const,fid);
        const = setparam_const('PY','2',const,fid);
    DEPTH(fid)
        const = setparam_const('DEPTH_TYPE','SLOPE',const,fid);
        const = setparam_const('DEPTH_FLAT','10.0',const,fid); % make sure this agrees!
        %setparam('SLP','DEPINPUT',fid); ML variable!
    %PRINT(fid) varying this!
        %setparam('RESULT_FOLDER', 'INPUT', fid);
    DIMENSION(fid)
        const = setparam_const('Mglob', '1024',const, fid);
        const = setparam_const('Nglob', '3', const,fid);
    TIME(fid)
        const = setparam_const('TOTAL_TIME', '600.0',const, fid);
        const = setparam_const('PLOT_INTV', '1.0', const,fid);
        const = setparam_const('PLOT_INTV_STATION', '0.5',const, fid);
        const = setparam_const('SCREEN_INTV', '1.0', const,fid);
    GRID(fid)
        const = setparam_const('DX', '1.0', const,fid); % make sure this agrees!
        const = setparam_const('DY', '1.0',const, fid);
    WAVEMAKER(fid)
        const = setparam_const('WAVEMAKER', 'WK_REG',const, fid);
        const = setparam_const('DEP_WK', '10.0',const, fid);
        const = setparam_const('Xc_WK', '250.0',const, fid);
        const = setparam_const('Yc_WK', '0.0',const, fid);
        %setparam('Tperiod', 'INPUT', fid); ML variable!
        %setparam('AMP_WK', 'INPUT', fid); ML variable!
        const =setparam_const('Theta_WK', '0.0',const, fid);
        const = setparam_const('Delta_WK', '3.0',const, fid); 
    PERIODIC_BC(fid)
        const = setparam_const('PERIODIC', 'F',const, fid);
    PHYSICS(fid)
        const = setparam_const('Cd', '0.0',const, fid);
    SPONGE_LAYER(fid)
        const = setparam_const('DIFFUSION_SPONGE', 'F',const, fid);
        const = setparam_const('FRICTION_SPONGE', 'T',const, fid);
        const = setparam_const('DIRECT_SPONGE', 'T',const, fid);
        const = setparam_const('Csp', '0.0',const,fid);
        const = setparam_const('CDsponge', '1.0', const,fid);
        const = setparam_const('Sponge_west_width', '180.0',const, fid);
        const = setparam_const('Sponge_east_width', '0.0',const, fid);
        const = setparam_const('Sponge_south_width', '0.0',const, fid);
        const = setparam_const('Sponge_north_width', '0.0',const, fid);
    NUMERICS(fid)
        const = setparam_const('CFL', '0.4',const, fid);
        const = setparam_const('FroudeCap', '3.0',const, fid);  
    WET_DRY(fid)
        const = setparam_const('MinDepth', '0.01',const, fid);
    BREAKING(fid)
        const = setparam_const('VISCOSITY_BREAKING', 'T',const, fid);
        const = setparam_const('Cbrk1', '0.65',const, fid);
        const = setparam_const('Cbrk2', '0.35',const, fid);
    WAVE_AVERAGE(fid)
        const = setparam_const('T_INTV_mean', '10.0',const, fid);
        const = setparam_const('STEADY_TIME', '10.0',const, fid);
    OUTPUT(fid)
        const = setparam_const('DEPTH_OUT','F',const,fid);
        const = setparam_const('ETA','F',const,fid);
        const = setparam_const('MASK','F',const,fid);
        const = setparam_const('WaveHeight','F',const,fid);   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% `setparam` function- DO NOT EDIT
% Helper function used to set the variable parameters as text 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setparam(param,value,fid)
    fprintf(fid,[param, ' = ',value,'\n']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% `setparam_vars` function- DO NOT EDIT
% Helper function used to set the variable parameters as text and append to
% a table as needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vtab = setparam_vars(param,value,vtab,fid)
    value_str = num2str(value,'%.4f');
    fprintf(fid,[param, ' = ',value_str,'\n']);
    vtab.(param) = value; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% `setparam_com` function- DO NOT EDIT
% Helper function used to set the common parameters as text and append to a
% table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ctab = setparam_const(param,value,ctab,fid)
    fprintf(fid,[param, ' = ',value,'\n']);
    ctab.(param) = value;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% `createInput` function- DO NOT EDIT
% Function to create input.txt file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fid = createInput(in,iter)
    fid = fopen(fullfile(in,['input_',sprintf('%05d', iter),'.txt']),'wt');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% `setresultfolder` function- DO NOT EDIT
% Function to set the result folder based on overwrite value
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setresultfolder(fid,iter,out,overwrite)
            if overwrite == false
                result_folder = [out,'/out_',sprintf('%05d', iter),'/'];
                setparam('RESULT_FOLDER',result_folder , fid);
            else
                result_folder = [out,'/overwrite/'];
                setparam('RESULT_FOLDER',result_folder , fid);
            end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Station folder stuff- Edit as needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gen_stations(in, iter, Mglob,spacing,fid)
    m_sta = (1:spacing:Mglob)';
    sta_fl = [m_sta 2*ones(length(m_sta),1)];

    % Don't edit beyond this- this just outputs the gages to the right
    % folder
    sta_fl_name = [in,'/gage_',sprintf('%05d', iter), '.txt'];
    writematrix(sta_fl, sta_fl_name , 'delimiter', ' ');
    setparam('STATIONS_FILE',sta_fl_name,fid);
    setparam('NumberStations',num2str(length(m_sta)),fid)
end

function given_stations(stna,stno,fid)
    setparam('STATIONS_FILE',stna,fid)
    setparam('NumberStations',stno,fid)
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Comments for Variable vs. Constant Parameters- DO NOT EDIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ML_VARS(fid)
fprintf(fid,'\n!-----------------------------------------------------------------  \n');
fprintf(fid,'!-----------------------------------------------------------------  \n');
fprintf(fid,'!VARIABLE PARAMETERS FOR ML MODEL\n'); 
fprintf(fid,'!note: these are the only parameters that will change for each input \n'); 
fprintf(fid,'!-----------------------------------------------------------------  \n');
fprintf(fid,'!-----------------------------------------------------------------  \n');
end

function Constant_VARS(fid)
fprintf(fid,'\n!-----------------------------------------------------------------  \n');
fprintf(fid,'!-----------------------------------------------------------------  \n');
fprintf(fid,'!CONSTANT PARAMETERS FOR ML MODEL\n'); 
fprintf(fid,'!note: these parameters are all the same for each input \n'); 
fprintf(fid,'!-----------------------------------------------------------------  \n');
fprintf(fid,'!-----------------------------------------------------------------  \n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FUNWAVE input.txt files comments- DO NOT EDIT
% These functions add the plaintext comments to the FUNWAVE input.txt files
% following the conventions of the `simple case` samples. For brevity, they
% can be commented out as well.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function TITLE(fid)
fprintf(fid,'!INPUT FILE FOR FUNWAVE_TVD\n'); 
fprintf(fid,'  ! NOTE: all input parameter are capital sensitive\n'); 
fprintf(fid,'  ! --------------------TITLE------------------------------------- \n'); 
fprintf(fid,'  ! title only for log file \n'); 
end

function PARALLEL_INFO(fid)
fprintf(fid, '\n  ! -------------------PARALLEL INFO-----------------------------\n');
fprintf(fid, '  ! \n');
fprintf(fid, '  !    PX,PY - processor numbers in X and Y\n');
fprintf(fid, '  !    NOTE: make sure consistency with mpirun -np n (px*py)\n');

end


function DEPTH(fid)
fprintf(fid, '\n  ! --------------------DEPTH-------------------------------------\n');
fprintf(fid, '  ! Depth types, DEPTH_TYPE=DATA: from depth file\n');
fprintf(fid, '  !              DEPTH_TYPE=FLAT: idealized flat, need depth_flat\n');
fprintf(fid, '  !              DEPTH_TYPE=SLOPE: idealized slope,\n');
fprintf(fid, '  !                                 need slope,SLP starting point, Xslp\n');
fprintf(fid, '  !                                 and depth_flat\n');
end

function PRINT(fid)
fprintf(fid, '\n  ! -------------------PRINT---------------------------------\n');
fprintf(fid, '  ! PRINT*,\n');
fprintf(fid, '  ! result folder\n');
end

function DIMENSION(fid)
fprintf(fid, '\n  ! ------------------DIMENSION-----------------------------\n');
fprintf(fid, '  ! global grid dimension\n');
end

function TIME(fid)
fprintf(fid, '\n  ! ----------------- TIME----------------------------------\n');
fprintf(fid, '  ! time: total computational time/ plot time / screen interval\n');
fprintf(fid, '  ! all in seconds\n');
end

function GRID(fid)
fprintf(fid, '\n  ! -----------------GRID----------------------------------\n');
fprintf(fid, '  ! if use spherical grid, in decimal degrees\n');
end

function WAVEMAKER(fid)
fprintf(fid, '\n  ! ----------------WAVEMAKER------------------------------\n');
fprintf(fid, '  !  wave maker\n');
fprintf(fid, '  ! LEF_SOL- left boundary solitary, need AMP, DEP, LAGTIME\n');
fprintf(fid, '  ! INI_SOL- initial solitary wave, WKN B solution,\n');
fprintf(fid, '  !          need AMP, DEP, XWAVEMAKER\n');
fprintf(fid, '  ! INI_REC - rectangular hump, need to specify Xc, Yc, and WID\n');
fprintf(fid, '  ! WK_REG - Wei and Kirby 1999 internal wave maker, Xc_WK, Tperiod\n');
fprintf(fid, '  !          AMP_WK, DEP_WK, Theta_WK, Time_ramp (factor of period)\n');
fprintf(fid, '  ! WK_IRR - Wei and Kirby 1999 TMA spectrum wavemaker, Xc_WK,\n');
fprintf(fid, '  !          DEP_WK, Time_ramp, Delta_WK, FreqPeak, FreqMin, FreqMax,\n');
fprintf(fid, '  !          Hmo, GammaTMA, ThetaPeak\n');
fprintf(fid, '  ! WK_TIME_SERIES - fft time series to get each wave component\n');
fprintf(fid, '  !                 and then use Wei and Kirby 1999\n');
fprintf(fid, '  !          need input WaveCompFile (including 3 columns: per, amp, pha)\n');
fprintf(fid, '  !          NumWaveComp, PeakPeriod, DEP_WK, Xc_WK, Ywidth_WK\n'); 
end

function PERIODIC_BC(fid)
fprintf(fid, '\n  ! ---------------- PERIODIC BOUNDARY CONDITION ---------\n');
fprintf(fid, '  ! South-North periodic boundary condition\n');
end

function SPONGE_LAYER(fid)
fprintf(fid, '\n  ! ---------------- SPONGE LAYER ------------------------\n');
fprintf(fid, '  ! need to specify widths of four boundaries and parameters if needed\n');
fprintf(fid, '  ! set width=0.0 if no sponge\n');
end

function PHYSICS(fid)
fprintf(fid, '\n  ! ----------------PHYSICS------------------------------\n');
fprintf(fid, '  ! parameters to control type of equations\n');
fprintf(fid, '  ! dispersion: all dispersive terms\n');
fprintf(fid, '  ! gamma1=1.0, gamma2=1.0: default: Fully nonlinear equations\n');
fprintf(fid, '  !----------------Friction-----------------------------\n');
end

function NUMERICS(fid)
fprintf(fid, '\n  ! ----------------NUMERICS----------------------------\n');
fprintf(fid, '  ! time scheme: runge_kutta for all types of equations\n');
fprintf(fid, '  !              predictor-corrector for NSWE\n');
fprintf(fid, '  ! space scheme: second-order\n');
fprintf(fid, '  !               fourth-order\n');
fprintf(fid, '  ! construction: HLLC\n');
fprintf(fid, '  ! cfl condition: CFL\n');
fprintf(fid, '  ! froude number cap: FroudeCap\n');
fprintf(fid, '  ! CFL\n');
end

function WET_DRY(fid)
fprintf(fid, '\n  ! --------------WET-DRY-------------------------------\n');
fprintf(fid, '  ! MinDepth for wetting-drying\n');
end

function BREAKING(fid)
fprintf(fid, '\n  ! -------------- BREAKING ----------------------------\n');
end

function WAVE_AVERAGE(fid)
fprintf(fid, '\n  ! ----------------- WAVE AVERAGE ------------------------\n');
fprintf(fid, '  ! if use smagorinsky mixing, have to set -DMIXING in Makefile\n');
fprintf(fid, '  ! and set averaging time interval, T_INTV_mean, default: 20s\n');

end

function OUTPUT(fid)
fprintf(fid, '\n  ! -----------------OUTPUT-----------------------------\n');
fprintf(fid, '  ! stations\n');
fprintf(fid, '  ! if NumberStations>0, need input i,j in STATION_FILE\n');
fprintf(fid, 'DEPTH_OUT = T\n');
fprintf(fid, 'U = F\n');
fprintf(fid, 'V = F\n');
fprintf(fid, 'ETA = T\n');
fprintf(fid, 'ETAscreen = T\n');
end
end
