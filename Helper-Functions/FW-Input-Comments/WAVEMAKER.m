function WAVEMAKER(fid)
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