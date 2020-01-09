restoredefaultpath;
addpath('..\CommonLibrary')

% set global parameters
localDir = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\data_v2\';  % the directory containing the 'data' folder

% Open the Meta-Data file
load([localDir,'..\MetaData.mat']);     % the Metadata filepath   


massConfigs = {'mFull','m3Qtr','mHalf','mQtr','mEmpty'};

%% calculate the required runs
currentlockedState = false;
massCase = massConfigs{2};

% create a set of indicies that covers all mass cases
indicies = true([1,length(MetaData)]);
indicies = indicies & string({MetaData.Job}) == 'HingeAngleStudy';
indicies = indicies & string({MetaData.TestType}) == 'rGust';
indicies = indicies & string({MetaData.MassConfig}) == massCase;
indicies = indicies & ~[MetaData.Locked];

RunsMeta = MetaData(indicies);
[a,v,h] = GetMeanData(localDir,RunsMeta);
num2clip(sortrows([a,round(v,1),h],[1,2]))

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

