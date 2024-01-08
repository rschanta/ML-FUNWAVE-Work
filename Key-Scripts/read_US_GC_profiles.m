clear 
clc
close all
profiles = {}; iter = 1;
for j = 1:3786
    try
        Xshore{iter} = h5read('./US_GC_data/Profile_data.h5',['/Profile/ID_',num2str(j),'/Xshore']);
        Elevation{iter} = h5read('./US_GC_data/Profile_data.h5',['/Profile/ID_',num2str(j),'/Elevation']);
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

