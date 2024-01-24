%%% Generate Baseline Dune3 FUNWAVE Input Structure

%% Set params
ML_base = struct();

ML_base.hTITLE = true;
    ML_base.TITLE = 'input_00000.txt';
ML_base.hPARALLEL_INFO = true; 
    ML_base.PX = int64(16); 
    ML_base.PY = int64(2);
ML_base.hDEPTH= true; 
    ML_base.DEPTH_TYPE = 'SLOPE'; 
    ML_base.DEPTH_FLAT = 10; 
    ML_base.SLP = 0.1;
    ML_base.Xslp = 800; 
ML_base.hDIMENSION= true;
    ML_base.Mglob = int64(1024); 
    ML_base.Nglob = int64(3);
ML_base.hTIME= true; 
    ML_base.TOTAL_TIME = 600; 
    ML_base.PLOT_INTX = 1; 
    ML_base.PLOT_INTV_STATION = 0.5; 
    ML_base.SCREEN_INTV = 1;
ML_base.hGRID= true;
    ML_base.DX = 1; 
    ML_base.DY = 1;
ML_base.hWAVEMAKER= true;
    ML_base.WAVEMAKER = 'WK_REG'; 
    ML_base.DEP_WK = 10; 
    ML_base.Xc_WK = 250; 
    ML_base.AMP_WK = 1; 
    ML_base.Tperiod = 1; 
    ML_base.Theta_WK = 0; 
    ML_base.Delta_WK = 3;
ML_base.hPERIODIC_BC= true;
    ML_base.PERIODIC = 'F';
ML_base.hPHYSICS= true; 
    ML_base.Cd = 0;
ML_base.hSPONGE_LAYER= true; 
    ML_base.DIFFUSION_SPONGE = 'F'; 
    ML_base.FRICTION_SPONGE = 'T'; 
    ML_base.DIRECT_SPONGE = 'T'; 
    ML_base.Csp = '0.0'; 
    ML_base.CDsponge = 1.0; 
    ML_base.Sponge_west_width = 180; 
    ML_base.Sponge_east_width = 0; 
    ML_base.Sponge_south_width = 0; 
    ML_base.Sponge_north_width = 0;
ML_base.hNUMERICS= true;
    ML_base.CFL = 0.4; 
    ML_base.FroudeCap = 3;
ML_base.hWET_DRY= true; 
    ML_base.MinDepth = 0.01;
ML_base.hBREAKING= true; 
    ML_base.VISCOSITY_BREAKING = 'T'; 
    ML_base.Cbrk1 = 0.65; 
    ML_base.Cbrk2 = 0.35;
ML_base.hWAVE_AVERAGE= true;
    ML_base.T_INTV_mean = 3; 
    ML_base.STEADY_TIME = 3;
ML_base.hOUTPUT= true;
    ML_base.DEPTH_OUT = 'T'; 
    ML_base.WaveHeight = 'F'; 
    ML_base.ETA = 'T'; 
    ML_base.MASK = 'F'; 
    ML_base.FIELD_IO_TYPE = 'BINARY';
    ML_base.RESULT_FOLDER = 'RESULT_FOLDER';
%% Save
    save('./ML-Template.mat','ML_base')

