function WAVE_AVERAGE(fid)
        fprintf(fid, '\n  ! ----------------- WAVE AVERAGE ------------------------\n');
        fprintf(fid, '  ! if use smagorinsky mixing, have to set -DMIXING in Makefile\n');
        fprintf(fid, '  ! and set averaging time interval, T_INTV_mean, default: 20s\n');
    end