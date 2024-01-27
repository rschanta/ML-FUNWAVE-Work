classdef FW_input < handle

    %% Properties
    properties
        %%% Structure with all the FUNWAVE properties in input.txt
            FW
        %%% Name of the input.txt file to be generated
            Name
        %%% Structures with any parameters that were modified with `set`
            SetVars
    end

    %% Public Methods to be called by other files
    methods (Access = public)

        %%% Constructor: Build up FW_Input from default and give name
        function self = FW_input(Name)
            self.FW = self.Default_Template();
            self.Name = Name;
        end

        %%% Set Field: Edit one of the fields of FW_Template and record it
        %%% in the `SetVars` property
        function set(self,field,value)
            self.FW.(field) = value;
            self.SetVars.(field) = value;
        end
        
        %%% Edit Field: Edit one of the fields without recording it in the
        %%% `SetVars` Property
        function edit(self,field,value)
            self.FW.(field) = value;
        end


        %%% Print input.txt file using fields in FW_Template
        % `dir_to`: Directory to generate file in.
        function print_input(self,dir_to)
            % Construct path of folder and create it if it doesn't exist
                if ~exist(dir_to, 'dir'), mkdir(dir_to), end    
            % Open the file
                fid = fopen(fullfile(dir_to,[self.Name,'.txt']), 'w');
            % Loop through each field in FW_input
                fields = fieldnames(self.FW);
                for j = 1:numel(fields)
                    % Get parameter and its value
                         param = fields{j};
                         value = self.FW.(param);
                    % Make sure doubles are valid in FORTRAN
                         value = self.valid_Double(value);
                    % If section header selected, print header
                        if islogical(value) && value
                            feval(param(2:end),self,fid)
                    % Print parameter line
                        else
                            line = strcat(param, " = ",string(value),"\n");
                            fprintf(fid,line);
                        end
                end

            % Close the file
            fclose(fid);

        end
    end


    %% Private Methods just for this class
    methods (Access = private)

        %%% Function to ensure doubles are valid in FORTRAN
        function conv = valid_Double(~,value)
            if isa(value, 'double')
                % Need to ensure number has a decimal place.
                    conv = string(value);
                    if ~contains(conv, '.')
                       conv = strcat(conv, '.0');
                    end
            else
                conv = value;
            end
        end

    end

    %% Method for Default Template
    methods (Access = private)
        function Template = Default_Template(~)
            Template = struct();
            Template.hTITLE = true;
                Template.TITLE = 'input.txt';
            Template.hPARALLEL_INFO = true; 
                Template.PX = int64(16); 
                Template.PY = int64(2);
            Template.hDEPTH= true; 
                Template.DEPTH_TYPE = 'SLOPE'; 
                Template.DEPTH_FLAT = 10; 
                Template.SLP = 0.1;
                Template.Xslp = 800; 
            Template.hDIMENSION= true;
                Template.Mglob = int64(1024); 
                Template.Nglob = int64(3);
            Template.hTIME= true; 
                Template.TOTAL_TIME = 600; 
                Template.PLOT_INTX = 1; 
                Template.PLOT_INTV_STATION = 0.5; 
                Template.SCREEN_INTV = 1;
            Template.hGRID= true;
                Template.DX = 1; 
                Template.DY = 1;
            Template.hWAVEMAKER= true;
                Template.WAVEMAKER = 'WK_REG'; 
                Template.DEP_WK = 10; 
                Template.Xc_WK = 250; 
                Template.AMP_WK = 1; 
                Template.Tperiod = 1; 
                Template.Theta_WK = 0; 
                Template.Delta_WK = 3;
            Template.hPERIODIC_BC= true;
                Template.PERIODIC = 'F';
            Template.hPHYSICS= true; 
                Template.Cd = 0;
            Template.hSPONGE_LAYER= true; 
                Template.DIFFUSION_SPONGE = 'F'; 
                Template.FRICTION_SPONGE = 'T'; 
                Template.DIRECT_SPONGE = 'T'; 
                Template.Csp = '0.0'; 
                Template.CDsponge = 1.0; 
                Template.Sponge_west_width = 180; 
                Template.Sponge_east_width = 0; 
                Template.Sponge_south_width = 0; 
                Template.Sponge_north_width = 0;
            Template.hNUMERICS= true;
                Template.CFL = 0.4; 
                Template.FroudeCap = 3;
            Template.hWET_DRY= true; 
                Template.MinDepth = 0.01;
            Template.hBREAKING= true; 
                Template.VISCOSITY_BREAKING = 'T'; 
                Template.Cbrk1 = 0.65; 
                Template.Cbrk2 = 0.35;
            Template.hWAVE_AVERAGE= true;
                Template.T_INTV_mean = 3; 
                Template.STEADY_TIME = 3;
            Template.hOUTPUT= true;
                Template.DEPTH_OUT = 'T'; 
                Template.WaveHeight = 'F'; 
                Template.ETA = 'T'; 
                Template.MASK = 'F'; 
                Template.FIELD_IO_TYPE = 'BINARY';
                Template.RESULT_FOLDER = 'RESULT_FOLDER';
        end

    end

    %% Methods for Printing Annotations
    methods (Access = private)
    function BREAKING(~,fid)
        fprintf(fid, '\n  ! -------------- BREAKING ----------------------------\n');
    end

    function DEPTH(~,fid)
        fprintf(fid, '\n  ! --------------------DEPTH-------------------------------------\n');
        fprintf(fid, '  ! Depth types, DEPTH_TYPE=DATA: from depth file\n');
        fprintf(fid, '  !              DEPTH_TYPE=FLAT: idealized flat, need depth_flat\n');
        fprintf(fid, '  !              DEPTH_TYPE=SLOPE: idealized slope,\n');
        fprintf(fid, '  !                                 need slope,SLP starting point, Xslp\n');
        fprintf(fid, '  !                                 and depth_flat\n');  
    end
    
    function DIMENSION(~,fid)
        fprintf(fid, '\n  ! ------------------DIMENSION-----------------------------\n');
        fprintf(fid, '  ! global grid dimension\n');
    end
    
    function GRID(~,fid)
        fprintf(fid, '\n  ! -----------------GRID----------------------------------\n');
        fprintf(fid, '  ! if use spherical grid, in decimal degrees\n');
    end
    
    function NUMERICS(~,fid)
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
    
    function OUTPUT(~,fid)
        fprintf(fid, '\n  ! -----------------OUTPUT-----------------------------\n');
        fprintf(fid, '  ! stations\n');
        fprintf(fid, '  ! if NumberStations>0, need input i,j in STATION_FILE\n');
    end
    
    function PARALLEL_INFO(~,fid)
        fprintf(fid, '\n  ! -------------------PARALLEL INFO-----------------------------\n');
        fprintf(fid, '  ! \n');
        fprintf(fid, '  !    PX,PY - processor numbers in X and Y\n');
        fprintf(fid, '  !    NOTE: make sure consistency with mpirun -np n (px*py)\n');
    end
    
    function PERIODIC_BC(~,fid)   
        fprintf(fid, '\n  ! ---------------- PERIODIC BOUNDARY CONDITION ---------\n');
        fprintf(fid, '  ! South-North periodic boundary condition\n');
    end
    
    function PHYSICS(~,fid)
        fprintf(fid, '\n  ! ----------------PHYSICS------------------------------\n');
        fprintf(fid, '  ! parameters to control type of equations\n');
        fprintf(fid, '  ! dispersion: all dispersive terms\n');
        fprintf(fid, '  ! gamma1=1.0, gamma2=1.0: default: Fully nonlinear equations\n');
        fprintf(fid, '  !----------------Friction-----------------------------\n');
    end
    
    function PRINT(~,fid)
        fprintf(fid, '\n  ! -------------------PRINT---------------------------------\n');
        fprintf(fid, '  ! PRINT*,\n');
        fprintf(fid, '  ! result folder\n');
    end
    
    function SPONGE_LAYER(~,fid)
        fprintf(fid, '\n  ! ---------------- SPONGE LAYER ------------------------\n');
        fprintf(fid, '  ! need to specify widths of four boundaries and parameters if needed\n');
        fprintf(fid, '  ! set width=0.0 if no sponge\n');
    end
    
    function TIME(~,fid)
        fprintf(fid, '\n  ! ----------------- TIME----------------------------------\n');
        fprintf(fid, '  ! time: total computational time/ plot time / screen interval\n');
        fprintf(fid, '  ! all in seconds\n');       
    end
    
    function TITLE(~,fid)
        fprintf(fid,'!INPUT FILE FOR FUNWAVE_TVD\n'); 
        fprintf(fid,'  ! NOTE: all input parameter are capital sensitive\n'); 
        fprintf(fid,'  ! --------------------TITLE------------------------------------- \n'); 
        fprintf(fid,'  ! title only for log file \n');
    end
    
    function WAVE_AVERAGE(~,fid)
        fprintf(fid, '\n  ! ----------------- WAVE AVERAGE ------------------------\n');
        fprintf(fid, '  ! if use smagorinsky mixing, have to set -DMIXING in Makefile\n');
        fprintf(fid, '  ! and set averaging time interval, T_INTV_mean, default: 20s\n');
    end

    function WAVEMAKER(~,fid)
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

    function WET_DRY(~,fid)
        fprintf(fid, '\n  ! --------------WET-DRY-------------------------------\n');
        fprintf(fid, '  ! MinDepth for wetting-drying\n');
    end

    end


end