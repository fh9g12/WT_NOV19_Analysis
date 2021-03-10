clear all;
restoredefaultpath;

% the directory containing the 'data' folder
localDir = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\data_v2\'; 

% Open the Meta-Data file
load([localDir,'..\MetaData.mat']);     % the Metadata filepath   

%% calculate the required runs

% The Meta-data folder contains all the information about each run, along
% with the file location of the assciated data file, what we first need to
% do is filter this table to select the runs we are interested in

massConfigs = {'mFull','m3Qtr','mHalf','mQtr','mEmpty'};

currentlockedState = false;
massCases = [2,4];

% create a set of indicies that covers all mass cases

% setup a place holder array
indicies = true([1,length(MetaData)]); 

% select only the runs in either the GVT study or ImpulseResponseStudy
%   GvtStudy - Wind-off, hinged locked, 5 different mass cases, response to
%       pulling the wing tip down
%   ImpulseResponseStudy - Wind-on hinge unlocked, response to
%       pulling the wing tip down

indicies = indicies & string({MetaData.Job}) == 'GvtStudy';
%indicies = indicies & string({MetaData.Job}) == 'ImpulseResponseStudy';

% we only want the 'SteadyState' test types (there were also 'datum' runs)
indicies = indicies & string({MetaData.TestType}) == 'steadyState';

% pick the mass case you would like to extract the data for

%indicies = indicies & string({MetaData.MassConfig}) == 'mEmpty';
indicies = indicies & string({MetaData.MassConfig}) == 'mQtr';
%indicies = indicies & string({MetaData.MassConfig}) == 'mHalf';
%indicies = indicies & string({MetaData.MassConfig}) == 'm3Qtr';
%indicies = indicies & string({MetaData.MassConfig}) == 'mFull';

% pick if you want the hinge locked / unlocked
indicies = indicies & [MetaData.Locked];

%use the indices to select the required runs out of the meta-data file
RunsMeta = MetaData(indicies);

%--TODO-- : run all the lines up to (select them and then press F9) and
%look at the RunsMeta object in your workspace, these are the runs you have
%selected!

%% Time to Extract some Data!

% pick your accelerometers!

% the reference accelerometer is one on the root 
% (to remove strustural noise etc)
iAccelRef = [9]; 

% this is the accelerometer to plot
iAccel = [6];

% each column of y matrix will be data accelerometer data from the wing 
y =[];
dr = 4; % a decimation factor to speed up processing

% loop through each run in our meta data
for i= 1:length(RunsMeta)
    % open the data file
    m = load([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename]);
     
    for jj = 1:length(iAccel)
        % get the reference accelerometer Data (get its calibration as well)
        refA_gain = m.d.daq.accelerometer.calibration(iAccelRef(jj));
        refA = refA_gain*m.d.daq.accelerometer.v(:,iAccelRef(jj));
        
        % get the accelerometer data
        A_gain = m.d.daq.accelerometer.calibration(iAccel(jj))
        
        % remove reference signal
        x = A_gain*m.d.daq.accelerometer.v(:,iAccel(jj))-refA
        
        % decimate to reduce data size
        v(:,jj) = decimate(x,dr);
    end
    
    % Add accelerometer data to array
    y = [y,v];
end

% calc sampling period (sampling freq was 1700Hz)
dt = 1/(1700/dr);

% filter the signal with a low-pass filter
fmax = 15;

[y,~] = filterSignal(y,dt,fmax);

%for each accelerometer, normalise the data to the size of the first peak
[maxval,peakIndex] = max(y);
for i = 1:size(y,2)
   y(:,i) = y(:,i)./maxval(i);
   [a,b]=findpeaks(y(:,i));
   peaks = b(a>0.5);
   y(:,i) = y(:,i)./y(peaks(1),i);
   peakIndex(i) = peaks(1);
end

% pad each column with zeros at either the start or end to ensure all the
% initial peaks line up
for i = 2:size(y,2)
    delta = peakIndex(1)-peakIndex(i);
    if delta > 0
        y(:,i)=[zeros(delta,1);y(1:end-delta,i)];
    elseif delta < 0
        y(:,i)=[y(1-delta:end,i);zeros(-delta,1)];
    end
end

%plot some data
figure(5)
plot((1:4000)/425,y(1:4000,:))
grid minor
l = legend(arrayfun(@(x)sprintf('Run %.0f',x),1:length(RunsMeta),'UniformOutput',false));
l.FontSize = 18;
ylabel('Normailised Response')
xlabel('Time [s]')

