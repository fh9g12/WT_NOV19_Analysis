restoredefaultpath;
addpath('..\CommonLibrary')

% set global parameters
localDir = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\data_v2\';  % the directory containing the 'data' folder

% Open the Meta-Data file
load([localDir,'..\MetaData.mat']);     % the Metadata filepath   


massConfigs = {'mFull','m3Qtr','mHalf','mQtr','mEmpty'};

%% calculate the required runs
currentlockedState = false;
massCases = [2,4];

% create a set of indicies that covers all mass cases
indicies = true([1,length(MetaData)]);
indicies = indicies & string({MetaData.Job}) == 'HingeAngleStudy';
indicies = indicies & string({MetaData.TestType}) == 'rGust';
if currentlockedState
    indicies = indicies & [MetaData.Locked];
else
    indicies = indicies & ~[MetaData.Locked];
end

global plotObjs;
plotObjs = struct();
figure(1)
close(gcf)
figure(1)
colours = {'b','r'};
hold off
for i = 1:length(massCases)
    m = massConfigs{massCases(i)};
    ind = indicies & string({MetaData.MassConfig}) == m;
    RunsMeta = MetaData(ind);
    [a,v,h] = GetMeanData(localDir,RunsMeta);
    
    % create the plot
    
    subplot(1,length(massCases),1)
    CreatePlot(v,a,['va_',m],colours{i});
    
    subplot(1,length(massCases),2)
    CreatePlot(v,h,['vh_',m],colours{i}); 
end

subplot(1,2,1)
grid minor
xlabel('Velocity [m/s]');
ylabel('AoA [deg]')
title('Test Points considered in the Hinge Angle Study')
legend([plotObjs.p_va_mQtr,plotObjs.p_va_m3Qtr],{'mQtr','m3Qtr'});

subplot(1,2,2)
grid minor
xlabel('Velocity [m/s]');
ylabel('Hinge Angle [deg]')
title('Test Points considered in the Hinge Angle Study')
legend([plotObjs.p_vh_mQtr,plotObjs.p_vh_m3Qtr],{'mQtr','m3Qtr'});



function CreatePlot(x,y,distinctStr,col)
    global plotObjs;
    k = convhull(x,y);
    plotObjs.(['sh_',distinctStr]) = fill(x(k),y(k),col);
    hold on
    plotObjs.(['sh_',distinctStr]).FaceAlpha = 0.2;
    plotObjs.(['sh_',distinctStr]).LineStyle='none';
    plotObjs.(['p_',distinctStr]) = plot(x,y,[col,'+']);
end


function [aoa,velocity,hingeAngle] = GetMeanData(localDir,RunsMeta)

% get unique folders ( to average files in unique folders )
folders = unique([{RunsMeta.Folder}]);

% get uniqe AoA and velocity combinations
data = [[RunsMeta.AoA]',[RunsMeta.Velocity]'];
[B, ~, ib] = unique(data, 'rows');
indices = accumarray(ib, find(ib), [], @(rows){rows});  %the find(ib) simply generates (1:size(a,1))'


% pre-allocate arrays
aoa=zeros(length(indices),1);
velocity=zeros(length(indices),1);
hingeAngle=zeros(length(indices),1);

% Extract Mean Info
for i =1:length(indices)
    runs = RunsMeta(indices{i});
    ha = zeros(1,length(runs));
    parfor j = 1:length(runs)
        m = load([localDir,runs(j).Folder,'\',runs(j).Filename]);
        e = m.d.daq.encoder;
        ha(j) = mean(e.v)*e.calibration.slope + e.calibration.constant;
    end
    aoa(i) = runs(1).AoA;
    velocity(i) = runs(1).Velocity;
    hingeAngle(i) = mean(ha);
end
end

