%%% Generate Baseline Dune3 FUNWAVE Input Structure

%% Set params
FW_base = struct();

FW.hTITLE = true;
    FW.TITLE = 'input_00000.txt';
FW.hPARALLEL_INFO = true; 
    FW.PX = int8(16); 
    FW.PY = int8(2);
FW.hDEPTH= true; 
    FW.DEPTH_TYPE = 'DATA'; 
    FW.DEPTH_FILE = 'DEPTH_FILE';
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
%% Save
    save('./FWD3_Template','FW')

