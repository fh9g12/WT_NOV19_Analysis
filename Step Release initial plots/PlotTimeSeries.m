clear all;
restoredefaultpath;
addpath('..\CommonLibrary')
addpath('..\CommonLibrary\ERA')

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
indicies = indicies & string({MetaData.Job}) == 'ImpulseResponseStudy';
indicies = indicies & string({MetaData.TestType}) == 'steadyState';
indicies = indicies & string({MetaData.MassConfig}) == 'mQtr';
indicies = indicies & ~[MetaData.Locked];

%get all runs in the Impluse Test (unlocked)
RunsMeta = MetaData(indicies);

% get one of each velocity as an example
[speeds,b] = unique([RunsMeta.Velocity]);
SingleRunsMeta = RunsMeta(b);


iAccelRef = [9];
iAccel = [6];
% iAccelRef = [2];
% iAccel = [5];

y =[];
dr = 4;

for i= 1:length(SingleRunsMeta)
    m = load([localDir,SingleRunsMeta(i).Folder,'\',SingleRunsMeta(i).Filename]);
    
    for jj = 1:length(iAccel)
        x = m.d.daq.accelerometer.calibration(iAccel(jj))*m.d.daq.accelerometer.v(:,iAccel(jj)) ...
            -m.d.daq.accelerometer.calibration(iAccelRef(jj))*m.d.daq.accelerometer.v(:,iAccelRef(jj));
        v(:,jj) = decimate(x,dr);
    end
    y = [y,v];
end

dt = 1/(1700/dr);
fmax = 15;
%% filter signal
[y,~] = filterSignal(y,dt,fmax);

%normlise to largest peak
[maxval,peakIndex] = max(y);

for i = 1:size(y,2)
   y(:,i) = y(:,i)./maxval(i);
   [a,b]=findpeaks(y(:,i));
   peaks = b(a>0.5);
   y(:,i) = y(:,i)./y(peaks(1),i);
   peakIndex(i) = peaks(1);
end

% normalise to the first peak over 0.5




for i = 2:size(y,2)
    delta = peakIndex(1)-peakIndex(i);
    if delta > 0
        y(:,i)=[zeros(delta,1);y(1:end-delta,i)];
    elseif delta < 0
        y(:,i)=[y(1+delta:end,i);zeros(delta,1)];
    end
end

figure(5)
plot((1:3000)/425,y(1:3000,:))
grid minor
l = legend(arrayfun(@(x)sprintf('%.1f m/s',x),round(speeds,1),'UniformOutput',false));
l.FontSize = 18;
t = title('Normalised response of the Wing-tip Z accelerometer to a Step Response at multiple speeds (Unlocked)');
ylabel('Normailised Response')
xlabel('Time [s]')

% 
% global plotObjs;
% plotObjs = struct();
% figure(1)
% close(gcf)
% figure(1)
% colours = {'b','r'};
% hold off
% for i = 1:length(massCases)
%     m = massConfigs{massCases(i)};
%     ind = indicies & string({MetaData.MassConfig}) == m;
%     RunsMeta = MetaData(ind);
%     [a,v,h] = GetMeanData(localDir,RunsMeta);
%     
%     % create the plot
%     
%     subplot(1,length(massCases),1)
%     CreatePlot(v,a,['va_',m],colours{i});
%     
%     subplot(1,length(massCases),2)
%     CreatePlot(v,h,['vh_',m],colours{i}); 
% end
% 
% subplot(1,2,1)
% grid minor
% xlabel('Velocity [m/s]');
% ylabel('AoA [deg]')
% title('Test Points considered in the Hinge Angle Study')
% legend([plotObjs.p_va_mQtr,plotObjs.p_va_m3Qtr],{'mQtr','m3Qtr'});
% 
% subplot(1,2,2)
% grid minor
% xlabel('Velocity [m/s]');
% ylabel('Hinge Angle [deg]')
% title('Test Points considered in the Hinge Angle Study')
% legend([plotObjs.p_vh_mQtr,plotObjs.p_vh_m3Qtr],{'mQtr','m3Qtr'});
% 
% 
% 
% function CreatePlot(x,y,distinctStr,col)
%     global plotObjs;
%     k = convhull(x,y);
%     plotObjs.(['sh_',distinctStr]) = fill(x(k),y(k),col);
%     hold on
%     plotObjs.(['sh_',distinctStr]).FaceAlpha = 0.2;
%     plotObjs.(['sh_',distinctStr]).LineStyle='none';
%     plotObjs.(['p_',distinctStr]) = plot(x,y,[col,'+']);
% end
% 
% 
% function [aoa,velocity,hingeAngle] = GetMeanData(localDir,RunsMeta)
% 
% % get unique folders ( to average files in unique folders )
% folders = unique([{RunsMeta.Folder}]);
% 
% % pre-allocate arrays
% aoa=zeros(length(folders),1);
% velocity=zeros(length(folders),1);
% hingeAngle=zeros(length(folders),1);
% 
% % Extract Mean Info
% for i =1:length(folders)
%     ind = strcmp([{RunsMeta.Folder}], folders(i));
%     runs = RunsMeta(ind);
%     ha = zeros(1,length(runs));
%     parfor j = 1:length(runs)
%         m = load([localDir,runs(j).Folder,'\',runs(j).Filename]);
%         e = m.d.daq.encoder;
%         ha(j) = mean(e.v)*e.calibration.slope + e.calibration.constant;
%     end
%     aoa(i) = runs(1).AoA;
%     velocity(i) = runs(1).Velocity;
%     hingeAngle(i) = mean(ha);
% end
% end

