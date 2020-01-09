close all;
%% ERA Test
restoredefaultpath;
addpath('..\CommonLibrary')
addpath('..\CommonLibrary\ERA');

% set global parameters
localDir = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\data_v2\';     % the directory containing the all the runs (should end 'data')

% Open the Meta-Data file
load('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\MetaData.mat');     % the Metadata filepath     
 

figFolder = 'figures';
 
%% Get Meta-data of the relevent files

currentlockedState = false; % set false / true for locked / unlocked data
%MassConfig = 'mEmpty';      % uncommment the required case
%MassConfig = 'mQtr';
%MassConfig = 'mHalf';
MassConfig = 'm3Qtr';
%MassConfig = 'mFull';

%% calculate the indicies for each the current case  %%%% MASS STUDY %%%%
indicies = string({MetaData.Job}) == 'MassStudy';
indicies = indicies & string({MetaData.TestType}) == 'rGust';
% if currentlockedState
%     indicies = indicies & [MetaData.Locked];
% else
%     indicies = indicies & ~[MetaData.Locked];
% end

% calculate the indicies for each the current case    %%% HINGE ANGLE STUDY  %%%
indicies = string({MetaData.Job}) == 'HingeAngleStudy';
indicies = indicies & string({MetaData.MassConfig}) == MassConfig;
indicies = indicies & string({MetaData.TestType}) == 'rGust';
if currentlockedState
    indicies = indicies & [MetaData.Locked];
else
    indicies = indicies & ~[MetaData.Locked];
end

% filter the MetaData
RunsMeta = MetaData(indicies);

% find groups
aoas = unique([RunsMeta.AoA]);

groups=struct();
index = 1;

for i = 1:length(aoas)
    ind = [RunsMeta.AoA] == aoas(i);
    meta = RunsMeta(ind);
    vs = unique([RunsMeta(ind).Velocity]);
    for j = 1:length(vs)
        ind_v = [meta.Velocity] == vs(j);
        meta_v = meta(ind_v);
        groups.(sprintf('group%d',index))= [meta_v.RunNumber];
        index = index +1;
    end
end

runs = groups.(sprintf('group%d',1));   %%%CHANGE NUMBER FOR RELEVANT AOA and Vel (see MetaData)
RunsMeta = MetaData(runs); 

 
%% prep
% channel names = {'z_wg','y_hg','z_hg','x_hg','y_wt','z_wt','x_wt','x_rt','z_rt','z_wgt','z_hgt'}
% zIdx = [1,3,6,10,11];
zIdxRef = 9;        % Z Refernce at the root
% zIdx = [3];       % Z Tri-Axis at the Hinge
zIdx = [6];         % Wingtip Tri-axis Z
% zIdx = [3,6];

xIdxRef = 2;        % root x ref
% xIdx = [4,7];
% xIdx = [4];       % Hinge (Tri-axis) X
xIdx = [5];         % WIngtip (Tri-axis) X
%% load files

%for each amss case make a plot
massConfigs = {'mFull','m3Qtr','mHalf','mQtr','mEmpty'};
for i=1:5
    indMass = indicies & string({MetaData.MassConfig}) == massConfigs{i};
    for j=0:0
        if j
            indLocked = indMass & [MetaData.Locked];
            s = ' Locked';
        else
            indLocked = indMass & ~[MetaData.Locked];
            s = ' Unlocked';
        end
    end
    RunsMeta = MetaData(indLocked);
    dr = 4;
    [fSelected,dSelected,plotHandle] = readFile(zIdx,zIdxRef,localDir,RunsMeta,dr);       % Z plot
    %[fSelected,dSelected] = readFile(xIdx,xIdxRef,localDir,RunsMeta,dr);     % X plot
    %% Function
    mkdir(figFolder)
    figure(plotHandle);
    title([massConfigs{i},s,sprintf('  AOA %.1f deg V %.1f m/s',RunsMeta(1).AoA,RunsMeta(1).Velocity)])
    saveas(plotHandle,[figFolder,'\',massConfigs{i},s,sprintf('  AOA %.1f deg V %.1f m_s',RunsMeta(1).AoA,RunsMeta(1).Velocity),'.png'])    
    close(plotHandle);
end



 
 
function [fSelected,dSelected,plotHandle] = readFile(idx,idxRef,localDir,RunsMeta,dr)
% read files
y = [];
for i = 1:length(RunsMeta)
    m = load([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename]);
    
%     encoderAngle = mean(m.d.daq.encoder.v.*m.d.daq.encoder.calibration.slope...
%         + m.d.daq.encoder.calibration.constant);   
    for jj = 1:length(idx)
        x = m.d.daq.accelerometer.calibration(idx(jj))*m.d.daq.accelerometer.v(:,idx(jj)) ...
            -m.d.daq.accelerometer.calibration(idxRef)*m.d.daq.accelerometer.v(:,idxRef);
        v(:,jj) = decimate(x,dr);
    end
    y = [y,v];
%         y = [y,m.d.daq.accelerometer.v(:,zIdx)'];
end
samplingRate = m.d.daq.rate/dr;
fmax = 15.0;

% alpha = 80; % Hankel Matrix Num of Rows Multiplier
% [fSelected,dSelected] = runERA(y,samplingRate,fmax,alpha);

% % ERA using correlated input
% nCorrel = 400; % Number of correlations
% alpha = 50; % Hankel Matrix Num of Rows Multiplier
nCorrel = 400;
alpha = nCorrel/2;
[fSelected,dSelected,plotHandle] = runERACorrel(y,samplingRate,fmax,alpha,nCorrel,3);

fprintf('ERA Freq(Hz) ERA Damping(%%)\n')
fprintf('%12.3f %14.2f\n',[fSelected,dSelected]');
end