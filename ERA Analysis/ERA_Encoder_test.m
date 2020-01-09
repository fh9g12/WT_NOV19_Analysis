close all;
%% ERA Test
restoredefaultpath;
addpath('..\CommonLibrary')
addpath('..\CommonLibrary\ERA');

% set global parameters
localDir = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\data_v2\';     % the directory containing the all the runs (should end 'data')

% Open the Meta-Data file
load('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\MetaData.mat');     % the Metadata filepath     
 
 
%% Get Meta-data of the relevent files

currentlockedState = false; % set false / true for locked / unlocked data
%MassConfig = 'mEmpty';      % uncommment the required case
MassConfig = 'mQtr';
%MassConfig = 'mHalf';
%MassConfig = 'm3Qtr';
%MassConfig = 'mFull';

%% calculate the indicies for each the current case  %%%% MASS STUDY %%%%
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
data = [];
% get f and d for each of the cases
hold off
disp (length(a))
for i = 1:length(a)
    disp(i)
    indicies = [RunsMeta.AoA] == a(i) & ...
        round([RunsMeta.Velocity],1) == round(v(i),1);
    meta = RunsMeta(indicies);
    [fSelected,dSelected] = readFile(zIdx,zIdxRef,localDir,meta,dr,1);       % Z plot 
    data = [data; fSelected(1:2)',dSelected(1:2)'];
end

% RunsMeta = MetaData(indicies);
% 
%  
% %% prep
% channelNames = {'z_wg','y_hg','z_hg','x_hg','y_wt','z_wt','x_wt','x_rt','z_rt','z_wgt','z_hgt'};
% % zIdx = [1,3,6,10,11];
% zIdxRef = 9;        % Z Refernce at the root
% % zIdx = [3];       % Z Tri-Axis at the Hinge
% zIdx = [6];         % Wingtip Tri-axis Z
% % zIdx = [3,6];
% 
% xIdxRef = 2;        % root x ref
% % xIdx = [4,7];
% % xIdx = [4];       % Hinge (Tri-axis) X
% xIdx = [5];         % WIngtip (Tri-axis) X
% %% load files
% dr = 4;
% [fSelected,dSelected] = readFile(zIdx,zIdxRef,localDir,RunsMeta,dr,1);       % Z plot
% % [fSelected,dSelected] = readFile(xIdx,xIdxRef,fDir,fname,dr);     % X plot
% %% Function
% pos = [0,0.05,1,0.4;0,0.53,1,0.4];
% for i = 3:4
%     f = figure(i);
%     f.Units = 'normalized';
%     f.Position = pos(i-2,:);
%     ax = gca;
%     subplot(1,5,1:4,ax)
%     t = uitable();
%     t.Units = 'normalized';
%     t.Position = [0.75,0.15,0.2,0.7];
%     t.Data = [fSelected,dSelected];
%     t.ColumnName = {'Frequency (Hz)','Damping (%)'};
%     if currentlockedState
%         s = ' Locked';
%     else
%         s = ' Unlocked';
%     end
%     title([MassConfig,s,sprintf('  AOA %.1f deg V %.1f m/s',RunsMeta(1).AoA,RunsMeta(1).Velocity)])   
% end

 
 
function [fSelected,dSelected] = readFile(idx,idxRef,localDir,RunsMeta,dr,encoder)
if ~exist('encoder','var')
    encoder = false;
end

% read files
y = [];
for i = 1:length(RunsMeta)
    m = load([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename]);
    
    if encoder
        x = m.d.daq.encoder.v.*m.d.daq.encoder.calibration.slope...
            + m.d.daq.encoder.calibration.constant;
        
        x1 = detrend(x);
        v = decimate(x1,dr);
    else
        for jj = 1:length(idx)
            x = m.d.daq.accelerometer.calibration(idx(jj))*m.d.daq.accelerometer.v(:,idx(jj)) ...
                -m.d.daq.accelerometer.calibration(idxRef)*m.d.daq.accelerometer.v(:,idxRef);
            v(:,jj) = decimate(x,dr);
        end
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
[fSelected,dSelected] = runERACorrel(y,samplingRate,fmax,alpha,nCorrel,2);

fprintf('ERA Freq(Hz) ERA Damping(%%)\n')
fprintf('%12.3f %14.2f\n',[fSelected,dSelected]');
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
