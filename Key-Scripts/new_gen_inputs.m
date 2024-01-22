
%% Testing
new_gen_inputss()
%%% Function to generate the files
function new_gen_inputss()
    super_dir = dbstack().name;
    %%% Make Directories if needed
            mkdir(fullfile(super_dir,'in'))
            mkdir(fullfile(super_dir,'sum'))

    %%% Define the variable parameter ranges
        SLP_r = linspace(0.05, 0.1,10);
        T_r = linspace(3, 12,10); 
        AMP_r = linspace(0.5, 1.5,10); 

    %%% Set up loop here:
    iter = 1;
    for slp = SLP_r; for T = T_r; for AMP = AMP_r
        %%% Calculate Xslp
            Mglob = 1024; DX = 1 ; DEPTH_FLAT = 10 ; 
            xslp = Mglob*DX-DEPTH_FLAT/slp;
        %%% Create file
            in_name = fullfile(super_dir,'in',['input_',sprintf('%05d', iter),'.txt']);
            disp(in_name)
            f = FW_write(in_name);
        %%% Add things to it
            make_file(f,iter,super_dir)
        %%% Go to next iteration
            iter = iter + 1;
    end; end; end


    
    function make_file(f,iter,super_dir)
        %%% Populate File
        f.TITLE(); 
            f.set('TITLE',['input_',sprintf('%05d', iter)])
        f.PARALLEL_INFO(); 
            f.set('PX',16); 
            f.set('PY',2)
        f.DEPTH(); 
            f.set('DEPTH_TYPE','SLOPE');
            f.setf('DEPTH_FLAT', DEPTH_FLAT);
            f.setf('SLP',slp);
            f.setf('Xslp',xslp);
        f.DIMENSION();
            f.set('Mglob', Mglob); 
            f.set('Nglob',3)
        f.TIME()
            f.setf('TOTAL_TIME',600);
            f.setf('PLOT_INTX',1);
            f.setf('PLOT_INTV_STATION', 0.5); 
            f.setf('SCREEN_INTV', 1);
        f.GRID()
            f.setf('DX',DX); 
            f.setf('DY',1)
        f.WAVEMAKER()
            f.set('WAVEMAKER','WK_REG')
            f.setf('DEP_WK',DEPTH_FLAT); 
            f.setf('Xc_WK',250); 
            f.setf('AMP_WK',AMP); 
            f.setf('Tperiod',T);
            f.setf('Theta_WK','0.0');
            f.setf('Delta_WK','3.0');
        f.PERIODIC_BC()
            f.set('PERIODIC', 'F');
        f.PHYSICS()
            f.setf('Cd', '0.0');
        f.SPONGE_LAYER()
            f.set('DIFFUSION_SPONGE', 'F'); f.set('FRICTION_SPONGE', 'T');
            f.set('DIRECT_SPONGE', 'T'); f.set('Csp', '0.0');
            f.setf('CDsponge', '1.0');
            f.setf('Sponge_west_width', '3.0'); 
            f.setf('Sponge_east_width', '0.0');
            f.setf('Sponge_south_width', '0.0'); 
            f.setf('Sponge_north_width', '0.0');
        f.NUMERICS()
            f.setf('CFL', '0.4'); 
            f.setf('FroudeCap', '3.0');  
        f.WET_DRY()
            f.setf('MinDepth', '0.01');
        f.BREAKING()
            f.set('VISCOSITY_BREAKING', 'T'); 
            f.setf('Cbrk1', '0.65'); f.setf('Cbrk2', '0.35');
        f.WAVE_AVERAGE()
            f.setf('T_INTV_mean', '10.0'); 
            f.setf('STEADY_TIME', '10.0');
        f.OUTPUT()
            f.set('DEPTH_OUT','T'); 
            f.set('WaveHeight','T'); 
            f.set('ETA','T'); 
            f.set('MASK','F');
            out_dir = [fullfile(super_dir,'out_',sprintf('%05d', iter)),'/" '];
            f.set('RESULT_FOLDER',out_dir )
        %%% Output summary for first rub
            if iter ==1
                FW_vars = f.FW_vars;
                sum_name = fullfile(super_dir,'sum/sumconst.mat');
                save(sum_name,'FW_vars') 
            end
        end
end