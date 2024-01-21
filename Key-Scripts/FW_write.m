%%% FW_write.m class

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEV HISTORY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
Last edit: 20 January 2024
Edit made: 
    - Created to generalize functions to create input.txt scripts in
    general
Ryan Schanta
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef FW_write  < handle
    properties
        % File path of input.txt file created
            path
        % Structure of all variables set
            FW_vars = struct() 

    end

methods
    %% Construct to create input.txt file
    function self = FW_write(dir,name)
        self.path = [fullfile(dir,name),'.txt'];
        fid = fopen(self.path,'wt');
        fclose(fid);
        self.FW_vars = struct();
    end

    %% Set a parameter and store it in FW_vars
    function set(self,param,value)
        % Open file
            fid = fopen(self.path, 'a');
        % Set parameter in file
            fprintf(fid,strcat(string(param), " = ",string(value),"\n"));
        % Close file
        fclose(fid);
        % Add variable to structure (convert to double if possible)
        try
            self.FW_vars.(param) = str2double(value);
        catch
            self.FW_vars.(param) = value;
        end

    end

    %% Descriptive Comments
    function TITLE(self)
        fid = fopen(self.path, 'a');
        fprintf(fid,'!INPUT FILE FOR FUNWAVE_TVD\n'); 
        fprintf(fid,'  ! NOTE: all input parameter are capital sensitive\n'); 
        fprintf(fid,'  ! --------------------TITLE------------------------------------- \n'); 
        fprintf(fid,'  ! title only for log file \n'); 
        fclose(fid);
    end
    
    function PARALLEL_INFO(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! -------------------PARALLEL INFO-----------------------------\n');
        fprintf(fid, '  ! \n');
        fprintf(fid, '  !    PX,PY - processor numbers in X and Y\n');
        fprintf(fid, '  !    NOTE: make sure consistency with mpirun -np n (px*py)\n');
        fclose(fid);
    end
    
    function DEPTH(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! --------------------DEPTH-------------------------------------\n');
        fprintf(fid, '  ! Depth types, DEPTH_TYPE=DATA: from depth file\n');
        fprintf(fid, '  !              DEPTH_TYPE=FLAT: idealized flat, need depth_flat\n');
        fprintf(fid, '  !              DEPTH_TYPE=SLOPE: idealized slope,\n');
        fprintf(fid, '  !                                 need slope,SLP starting point, Xslp\n');
        fprintf(fid, '  !                                 and depth_flat\n');
        fclose(fid);
    end
    
    function PRINT(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! -------------------PRINT---------------------------------\n');
        fprintf(fid, '  ! PRINT*,\n');
        fprintf(fid, '  ! result folder\n');
    end
    
    function DIMENSION(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! ------------------DIMENSION-----------------------------\n');
        fprintf(fid, '  ! global grid dimension\n');
        fclose(fid);
    end
    
    function TIME(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! ----------------- TIME----------------------------------\n');
        fprintf(fid, '  ! time: total computational time/ plot time / screen interval\n');
        fprintf(fid, '  ! all in seconds\n');
        fclose(fid);
    end
    
    function GRID(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! -----------------GRID----------------------------------\n');
        fprintf(fid, '  ! if use spherical grid, in decimal degrees\n');
        fclose(fid);
    end
    
    function WAVEMAKER(self)
        fid = fopen(self.path, 'a');
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
        fclose(fid);
    end
    
    function PERIODIC_BC(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! ---------------- PERIODIC BOUNDARY CONDITION ---------\n');
        fprintf(fid, '  ! South-North periodic boundary condition\n');
        fclose(fid);
    end
    
    function SPONGE_LAYER(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! ---------------- SPONGE LAYER ------------------------\n');
        fprintf(fid, '  ! need to specify widths of four boundaries and parameters if needed\n');
        fprintf(fid, '  ! set width=0.0 if no sponge\n');
        fclose(fid);
    end
    
    function PHYSICS(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! ----------------PHYSICS------------------------------\n');
        fprintf(fid, '  ! parameters to control type of equations\n');
        fprintf(fid, '  ! dispersion: all dispersive terms\n');
        fprintf(fid, '  ! gamma1=1.0, gamma2=1.0: default: Fully nonlinear equations\n');
        fprintf(fid, '  !----------------Friction-----------------------------\n');
        fclose(fid);
    end
    
    function NUMERICS(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! ----------------NUMERICS----------------------------\n');
        fprintf(fid, '  ! time scheme: runge_kutta for all types of equations\n');
        fprintf(fid, '  !              predictor-corrector for NSWE\n');
        fprintf(fid, '  ! space scheme: second-order\n');
        fprintf(fid, '  !               fourth-order\n');
        fprintf(fid, '  ! construction: HLLC\n');
        fprintf(fid, '  ! cfl condition: CFL\n');
        fprintf(fid, '  ! froude number cap: FroudeCap\n');
        fprintf(fid, '  ! CFL\n');
        fclose(fid);
    end
    
    function WET_DRY(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! --------------WET-DRY-------------------------------\n');
        fprintf(fid, '  ! MinDepth for wetting-drying\n');
        fclose(fid);
    end
    
    function BREAKING(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! -------------- BREAKING ----------------------------\n');
        fclose(fid);
    end
    
    function WAVE_AVERAGE(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! ----------------- WAVE AVERAGE ------------------------\n');
        fprintf(fid, '  ! if use smagorinsky mixing, have to set -DMIXING in Makefile\n');
        fprintf(fid, '  ! and set averaging time interval, T_INTV_mean, default: 20s\n');
        fclose(fid);
    end
    
    function OUTPUT(self)
        fid = fopen(self.path, 'a');
        fprintf(fid, '\n  ! -----------------OUTPUT-----------------------------\n');
        fprintf(fid, '  ! stations\n');
        fprintf(fid, '  ! if NumberStations>0, need input i,j in STATION_FILE\n');
        % fprintf(fid, 'DEPTH_OUT = T\n');
        % fprintf(fid, 'U = F\n');
        % fprintf(fid, 'V = F\n');
        % fprintf(fid, 'ETA = T\n');
        % fprintf(fid, 'ETAscreen = T\n');
        % fclose(fid);
    end
end
end



