restoredefaultpath;
addpath('..\CommonLibrary')

% Need to run the ExtractStepSineResponse script first too produce the data
% to analysis
load('StepSineResults.mat')

massConfigs = {'mFull','m3Qtr','mHalf','mQtr','mEmpty'};
L = {'z_wg','y_hg','z_hg','x_hg','y_wt','z_wt','x_wt','x_rt','z_rt','z_wgt','z_hgt'};
ind = [3,4,5,6,7];
L={L{ind}};

%Create an Overview image 
f = figure(1);
f.Units = 'normalized';
f.OuterPosition = [0 0 1 1];
for i = 1:length(massConfigs)
    subplot(5,2,(i-1)*2+1)
    MakePlot(Results.(massConfigs{i}).Locked,L,ind)
    title([massConfigs{i},' Locked'])
    subplot(5,2,(i-1)*2+2)
    MakePlot(Results.(massConfigs{i}).Unlocked,L,ind)
    title([massConfigs{i},' Unlocked'])
%     if i == 1
%         gif('myfile.gif','DelayTime',0.4,'frame',f)
%     else
%         gif
%     end
end

% Create vairtion of wt on one plot
f = figure(2);
f.Units = 'normalized';
f.OuterPosition = [0 0 1 1];

subplot(2,2,1)
CreateMassVarPlot(Results,massConfigs,6:7,0)
legend('Wing-tip Z Accelrometer','Wing-tip X Accelrometer')
title(['Wing-tip ZX accelerometers response to mass variation - Unlocked'])

subplot(2,2,2)
CreateMassVarPlot(Results,massConfigs,6:7,1)
legend('Wing-tip Z Accelrometer','Wing-tip X Accelrometer','location','northwest')
title(['Wing-tip ZX accelerometers response to mass variation - Locked'])


subplot(2,2,3)
CreateMassVarPlot(Results,massConfigs,3:4,0,[0,5])
legend('Hinge Z Accelrometer','Hinge X Accelrometer')
title(['Hinge ZX accelerometers response to mass variation - Unlocked'])

subplot(2,2,4)
CreateMassVarPlot(Results,massConfigs,3:4,1,[0,5])
legend('Hinge Z Accelrometer','Hinge X Accelrometer','location','northwest')
title(['Hinge ZX accelerometers response to mass variation - Locked'])




function CreateMassVarPlot(runData,massConfigs,accels,locked,ylimits)
    if ~exist('ylimits','var')
        ylimits = [0,8];
    end

    hold off
    for i = 1:length(massConfigs)
        if locked
           r = runData.(massConfigs{i}).Locked; 
        else
           r = runData.(massConfigs{i}).Unlocked;
        end
        if i == 1
            AddToPlot(r,accels,(i-1)*1/(length(massConfigs)));   
        else
            AddToPlot(r,accels,(i-1)*1/(length(massConfigs)),'off');   
        end  
    end
    xlabel('freq, Hz')
    ylabel('A_{cal}')
    grid on
    ylim(ylimits)
end


%web('myfile.gif')

function AddToPlot(runData,ind,fraction,handleVisibility)
    if ~exist('visibility','var')
        handleVisibility = 'on';
    end
    p1 = plot(runData.aFreqs,runData.arSVec(:,ind(1)),'o-');
    p1.Color = [0 fraction 1];
    p1.HandleVisibility = handleVisibility;
    hold on
    p2 = plot(runData.aFreqs,runData.arSVec(:,ind(2)),'v-');
    p2.Color = [1 fraction 0];
    p2.HandleVisibility = handleVisibility;
end


function MakePlot(runData,L,ind)
    if ~exist('ind','var')
        ind = ones(1,size(runData.arSVec,2));
    end
    hold off
    plot(runData.aFreqs,runData.arSVec(:,ind),'o-');
    legend(L,'location','northeast');
    xlabel('freq, Hz')
    ylabel('A_{cal}')
    grid on
    ylim([0,8])
end