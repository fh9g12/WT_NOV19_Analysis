filepath = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\mass study results.xlsx';





genplot(filepath,'X');

function genplot(filepath,XZ)
    UnlockedZ = readmatrix(filepath,'Sheet','order freqs','Range','B4:G8');
    UnlockedX = readmatrix(filepath,'Sheet','order freqs','Range','B12:G16');
    LockedZ = readmatrix(filepath,'Sheet','order freqs','Range','B20:G24');
    LockedX = readmatrix(filepath,'Sheet','order freqs','Range','B29:G33');

    momentOfInertia = [0,7.96,11.62,18.4,23.55];
    mass = (0:4)*87.6;
    x = mass;

    colors = {'r','b','g'};
    
    figure(1)
    for i = 1:3
        subplot(1,2,1)
        if i == 1 
            hold off
        end
        eval(sprintf('p = plot(x'',Unlocked%s(:,(i-1)*2+1),''o-'');',XZ))
        p.Color = colors{i};
        hold on
        eval(sprintf('p = plot(x'',Locked%s(:,(i-1)*2+1),''o--'');',XZ))
        p.Color = colors{i};

        subplot(1,2,2)
        if i == 1 
            hold off
        end
        eval(sprintf('p = plot(x'',Unlocked%s(:,(i-1)*2+2),''o-'');',XZ))
        p.Color = colors{i};
        hold on
        eval(sprintf('p = plot(x'',Locked%s(:,(i-1)*2+2),''o--'');',XZ))
        p.Color = colors{i};
    end


    subplot(1,2,1)
    grid minor
    xlabel('Wing-tip Delta Mass [g]')
    ylabel('Frequency [Hz]')
    legend('Mode 1 (Unlocked)','Mode 1 (Locked)','Mode 2 (Unlocked)',...
        'Mode 2 (Locked)','Mode 3 (Unlocked)','Mode 3 (Locked)')
    title({'Variation in the frequency of the models first 3 modes with wing-tip mass.',[' Measured using the wing-tip ',XZ,' accelerometer']})

    subplot(1,2,2)
    grid minor
    xlabel('Wing-tip Delta Mass [g]')
    ylabel('Damping []')
    legend('Mode 1 (Unlocked)','Mode 1 (Locked)','Mode 2 (Unlocked)',...
        'Mode 2 (Locked)','Mode 3 (Unlocked)','Mode 3 (Locked)')
    title({'Variation in the frequency of the models first 3 modes with wing-tip mass.',[' Measured using the wing-tip ',XZ,' accelerometer']})
end
