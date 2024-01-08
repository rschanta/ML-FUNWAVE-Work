clear 
clc
close all
iter = 1;
for j = 1:3786
    try
        % Read in data
        Xshore_raw = h5read('./US_GC_data/Profile_data.h5',['/Profile/ID_',num2str(j),'/Xshore']);
        Elevation_raw = h5read('./US_GC_data/Profile_data.h5',['/Profile/ID_',num2str(j),'/Elevation']);

        % Find zero crossings and index out
        zero_cross = (Elevation_raw(1:end-1) .* Elevation_raw(2:end)) <= 0;
        zero_cross_i = find(zero_cross);

        Xshore_pro = Xshore_raw(1:zero_cross_i(1));
        Elevation_pro = Elevation_raw(1:zero_cross_i(1));

        % Append to cell arrays
        Xshore{iter} = Xshore_pro;
        Elevation{iter} = Elevation_pro;
        
        iter = iter + 1;
    catch
        disp('Profile not found');
    end

end
%%

figure()
    for j = 1:100
        hold on
        plot(Xshore{j},Elevation{j})
    end

