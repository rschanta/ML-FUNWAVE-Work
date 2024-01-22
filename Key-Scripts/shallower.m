function shallower(master_dir)
    %%% Folder Structure
        % Construct master_dir
            super_dir = fullfile(master_dir,dbstack().name);
        % Construct input, summary, and output folder names.
            in_dir = fullfile(super_dir,'in');
            sum_dir = fullfile(super_dir,'sum');
            out_dir = fullfile(super_dir,'out');
        % Make the input and summary folders
            if ~exist(in_dir, 'dir') mkdir(in_dir), end
            if ~exist(sum_dir, 'dir') mkdir(sum_dir), end


    %%% Define variable parameter ranges (R)
        r_S = linspace(0.05, 0.1,10); % Slope
        r_T = linspace(3, 12,10);     % Period
        r_A = linspace(0.5, 1.5,10);  % Amplitude

    %%% Loop through all variables
    iter = 1;
    for S = r_S; for T = r_T; for A = r_A

        % Calculate any other dependencies
            Mglob = 1024; DX = 1 ; DEPTH_FLAT = 10 ; 
            xslp = Mglob*DX-DEPTH_FLAT/S;
        
        % Call main function
            in_name = fullfile(in_dir,['input_',sprintf('%02d', iter),'.txt']);
            disp(in_name)
            f = FW_write(in_name);
            create_input(f);
            iter = iter + 1;

    end; end; end

    %%% Function that creates the file
    function create_input(f)
        %%% Nomenclature
            % Input file title
                input_title = ['Input_',sprintf('%05d', iter)];
            % Summary File Generation
                sum_file = fullfile(sum_dir,'sumconst.mat');
            % FUNWAVE output folder
                output_dir = strrep(out_dir, '\', '/');
                output_dir = [output_dir,'out_',sprintf('%05d', iter),'/'];
        %%% Populate File
            f.TITLE(); 
                f.set('TITLE',input_title)
            f.PARALLEL_INFO(); 
                f.set('PX',16); f.set('PY',2)
            f.DEPTH(); 
                f.set('DEPTH_TYPE','SLOPE'); 
                f.set('SLP', S)
                f.setf('DEPTH_FLAT', DEPTH_FLAT)
                f.setf('Xslp', xslp);
            f.DIMENSION();
                f.set('Mglob', Mglob); f.set('Nglob',3)
            f.TIME()
                f.setf('TOTAL_TIME',600);
                f.setf('PLOT_INTV',1.0);
                f.setf('PLOT_INTV_STATION', 0.5); 
                f.setf('SCREEN_INTV', 1.0);
            f.GRID()
                f.setf('DX',DX); 
                f.setf('DY',1)
            f.WAVEMAKER()
                f.set('WAVEMAKER','WK_REG')
                f.setf('DEP_WK',DEPTH_FLAT); f.setf('Xc_WK',250); 
                f.setf('AMP_WK',A); f.setf('Tperiod',T);
                f.setf('Theta_WK',0);f.setf('Delta_WK',3);
            f.PERIODIC_BC()
                f.set('PERIODIC', 'F');
            f.PHYSICS()
                f.setf('Cd', 0);
            f.SPONGE_LAYER()
                f.set('DIFFUSION_SPONGE', 'F'); f.set('FRICTION_SPONGE', 'T');
                f.set('DIRECT_SPONGE', 'T'); f.setf('Csp', '0.0');
                f.setf('CDsponge', 1);
                f.setf('Sponge_west_width', 180); f.setf('Sponge_east_width', 0);
                f.setf('Sponge_south_width', 0); f.setf('Sponge_north_width', 0);
            f.NUMERICS()
                f.setf('CFL', 0.4); f.setf('FroudeCap', 3);  
            f.WET_DRY()
                f.setf('MinDepth', 0.01);
            f.BREAKING()
                f.set('VISCOSITY_BREAKING', 'T'); f.setf('Cbrk1', 0.65); f.setf('Cbrk2', 0.35);
            f.WAVE_AVERAGE()
                f.setf('T_INTV_mean', 10); f.setf('STEADY_TIME', 10);
            f.OUTPUT()
                f.set('DEPTH_OUT','T'); 
                f.set('WaveHeight','T'); 
                f.set('ETA','T'); 
                f.set('MASK','F');

                f.set('RESULT_FOLDER', output_dir)
        %%% Save FW Input structure
        if iter ==1
            FW_vars = f.FW_vars;
            save(sum_file,'FW_vars')
        end

    end

end

