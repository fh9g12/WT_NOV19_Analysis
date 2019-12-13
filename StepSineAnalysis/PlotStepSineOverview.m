restoredefaultpath;
addpath('..\CommonLibrary')


% Need to run the ExtractStepSineResponse script first too produce the data
% to analysis
load('StepSineResults.mat')

massConfigs = {'mFull','m3Qtr','mHalf','mQtr','mEmpty','mQtr','mHalf','m3Qtr'};
L = {'z_wg','y_hg','z_hg','x_hg','y_wt','z_wt','x_wt','x_rt','z_rt','z_wgt','z_hgt'};

f = figure(i);
f.Units = 'normalized';
f.OuterPosition = [0 0 1 1];
for i = 1:length(massConfigs)
    subplot(2,1,1)
    MakePlot(Results.(massConfigs{i}).Locked,L)
    title([massConfigs{i},' Locked'])
    subplot(2,1,2)
    MakePlot(Results.(massConfigs{i}).Unlocked,L)
    title([massConfigs{i},' Unlocked'])
    if i == 1
        gif('myfile.gif','DelayTime',0.4,'frame',f)
    else
        gif
    end
end

web('myfile.gif')

function MakePlot(runData,L)
    hold off
    plot(runData.aFreqs,runData.arSVec,'o-');
    legend(L,'location','northeast');
    xlabel('freq, Hz')
    ylabel('A_{cal}')
    grid on
    ylim([0,8])
end