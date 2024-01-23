%%% FW_write.m class

%%



FW = struct();

%FW.hTITLE = true;
    FW.TITLE = 'input_00000.txt';
FW.hPARALLEL_INFO = true; 
    FW.PX = int8(16); 
    FW.PY = 2;
FW.hDEPTH= true; 
    FW.DEPTH_TYPE = 'DATA'; 
    FW.DEPTH_FILE = 'Depth';
FW.hDIMENSION= true;
    FW.Mglob = 1024; 
    FW.Nglob = 4;
FW.hTIME= true; 
    FW.TOTAL_TIME = 1450; 
    FW.PLOT_INTX = 1; 
    FW.PLOT_INTV_STATION = 0.5; 
    FW.SCREEN_INTV = 1;
FW.hGRID= true;
    FW.DX = 1; 
    FW.DY = 1;
FW.hWAVEMAKER= true;
    FW.WAVEMAKER = 'WK_REG'; 
    FW.DEP_WK = 1; 
    FW.Xc_WK = 1; 
    FW.AMP_WK = 1; 
    FW.Tperiod = 1; 
    FW.Theta_WK = 0; 
    FW.Delta_WK = 3;
FW.hPERIODIC_BC= true;
    FW.PERIODIC = 'F';
FW.hPHYSICS= true; 
    FW.Cd = 0;
FW.hSPONGE_LAYER= true; 
    FW.DIFFUSION_SPONGE = 'F'; 
    FW.FRICTION_SPONGE = 'T'; 
    FW.DIRECT_SPONGE = 'T'; 
    FW.Csp = '0.0'; 
    FW.CDsponge = 1.0; 
    FW.Sponge_west_width = 3; 
    FW.Sponge_east_width = 0; 
    FW.Sponge_south_width = 0; 
    FW.Sponge_north_width = 0;
FW.hNUMERICS= true;
    FW.CFL = 0.4; 
    FW.FroudeCap = 3;
FW.hWET_DRY= true; 
    FW.MinDepth = 0.01;
FW.hBREAKING= true; 
    FW.VISCOSITY_BREAKING = 'T'; 
    FW.Cbrk1 = 0.65; 
    FW.Cbrk2 = 0.35;
FW.hWAVE_AVERAGE= true;
    FW.T_INTV_mean = 3; 
    FW.STEADY_TIME = 3;
FW.hOUTPUT= true;
    FW.DEPTH_OUT = 'T'; 
    FW.WaveHeight = 'F'; 
    FW.ETA = 'T'; 
    FW.MASK = 'F'; 
    FW.FIELD_IO_TYPE = 'BINARY';

FW_Input(FW,'write3test.txt')


%%
function FW_Input(FW,path)
    %%% Add path to Input Comments
    addpath('../Helper-Functions/FW-Input-Comments/')
    
    %%% Create file
    fid = fopen(path, 'w');

    %%% Loop through elements in FW
    % Get all field names
        fields = fieldnames(FW);

    %%% Loop
    for j = 1:numel(fields)
        %%% Get name of parameter
            param = fields{j};
            value = FW.(param);
            disp(class(value))
        %%% Cases: Double, Int, String, or Header (Logical) Text
            % Case 1: Is an integer
            if isa(value, 'int8')
                line = strcat(param, " = ",string(value),"\n");
                fprintf(fid,line);
            % Case 2: Is a string/character
            elseif isstring(value)||ischar(value)||iscellstr(value)
                line = strcat(param, " = ",string(value),"\n");
                fprintf(fid,line);
            % Case 3: Is a double
            elseif isa(value, 'double')
                disp('HAHAHA')
                % Need ensure decimal place for FORTRN
                    value_s = string(value);
                    if ~contains(value_s, '.')
                       value_s = strcat(value_s, '.0');
                    end
                %
                line = strcat(param, " = ",value_s,"\n");
                fprintf(fid,line);

            % Class 4: Is a header (see functions below) 
            elseif value == true
                %disp(param(2:end))
                feval(param(2:end),fid)

            else
                disp(['Could not write, char(param)']);
            end

            
    end

    %%% Create file
        fclose(fid);
            
    %%% Header Functions

end




