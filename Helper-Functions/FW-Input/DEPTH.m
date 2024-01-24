function DEPTH(fid)
        fprintf(fid, '\n  ! --------------------DEPTH-------------------------------------\n');
        fprintf(fid, '  ! Depth types, DEPTH_TYPE=DATA: from depth file\n');
        fprintf(fid, '  !              DEPTH_TYPE=FLAT: idealized flat, need depth_flat\n');
        fprintf(fid, '  !              DEPTH_TYPE=SLOPE: idealized slope,\n');
        fprintf(fid, '  !                                 need slope,SLP starting point, Xslp\n');
        fprintf(fid, '  !                                 and depth_flat\n');  
    end