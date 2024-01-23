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