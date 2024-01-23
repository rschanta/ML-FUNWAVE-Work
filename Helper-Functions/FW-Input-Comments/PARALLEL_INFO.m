function  PARALLEL_INFO(fid)
fprintf(fid, '\n  ! -------------------PARALLEL INFO-----------------------------\n');
fprintf(fid, '  ! \n');
fprintf(fid, '  !    PX,PY - processor numbers in X and Y\n');
fprintf(fid, '  !    NOTE: make sure consistency with mpirun -np n (px*py)\n');
end