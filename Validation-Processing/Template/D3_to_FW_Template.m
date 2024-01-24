%%% Generate Baseline Dune3 FUNWAVE Input Structure

%% Set params
FW_base = struct();

FW_base.hTITLE = true;
    FW_base.TITLE = 'input_00000.txt';
FW_base.hPARALLEL_INFO = true; 
    FW_base.PX = int64(16); 
    FW_base.PY = int64(2);
FW_base.hDEPTH= true; 
    FW_base.DEPTH_TYPE = 'DATA'; 
    FW_base.DEPTH_FILE = 'FILE'; 
FW_base.hDIMENSION= true;
    FW_base.Mglob = 1024; 
    FW_base.Nglob = 4;
FW_base.hTIME= true; 
    FW_base.TOTAL_TIME = 1450; 
    FW_base.PLOT_INTX = 1; 
    FW_base.PLOT_INTV_STATION = 0.5; 
    FW_base.SCREEN_INTV = 1;
FW_base.hGRID= true;
    FW_base.DX = 1; 
    FW_base.DY = 1;
FW_base.hWAVEMAKER= true;
    FW_base.WAVEMAKER = 'WK_REG'; 
    FW_base.DEP_WK = 1; 
    FW_base.Xc_WK = 1; 
    FW_base.AMP_WK = 1; 
    FW_base.Tperiod = 1; 
    FW_base.Theta_WK = 0; 
    FW_base.Delta_WK = 3;
FW_base.hPERIODIC_BC= true;
    FW_base.PERIODIC = 'F';
FW_base.hPHYSICS= true; 
    FW_base.Cd = 0;
FW_base.hSPONGE_LAYER= true; 
    FW_base.DIFFUSION_SPONGE = 'F'; 
    FW_base.FRICTION_SPONGE = 'T'; 
    FW_base.DIRECT_SPONGE = 'T'; 
    FW_base.Csp = '0.0'; 
    FW_base.CDsponge = 1.0; 
    FW_base.Sponge_west_width = 3; 
    FW_base.Sponge_east_width = 0; 
    FW_base.Sponge_south_width = 0; 
    FW_base.Sponge_north_width = 0;
FW_base.hNUMERICS= true;
    FW_base.CFL = 0.4; 
    FW_base.FroudeCap = 3;
FW_base.hWET_DRY= true; 
    FW_base.MinDepth = 0.01;
FW_base.hBREAKING= true; 
    FW_base.VISCOSITY_BREAKING = 'T'; 
    FW_base.Cbrk1 = 0.65; 
    FW_base.Cbrk2 = 0.35;
FW_base.hWAVE_AVERAGE= true;
    FW_base.T_INTV_mean = 3; 
    FW_base.STEADY_TIME = 3;
FW_base.hOUTPUT= true;
    FW_base.DEPTH_OUT = 'T'; 
    FW_base.WaveHeight = 'F'; 
    FW_base.ETA = 'T'; 
    FW_base.MASK = 'F'; 
    FW_base.FIELD_IO_TYPE = 'BINARY';
    FW_base.RESULT_FOLDER = 'RESULT_FOLDER';
%% Save
    save('./Template5.mat','FW_base')

