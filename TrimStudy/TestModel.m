close all;
%% ERA Test
restoredefaultpath;
addpath('..\CommonLibrary')
addpath('..\CommonLibrary\ERA');

% set global parameters
localDir = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\data_v2\';     % the directory containing the all the runs (should end 'data')

% Open the Meta-Data file
load('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\MetaData.mat');     % the Metadata filepath     

% get inidicies for trim study
indicies = string({MetaData.Job}) == 'TrimStudy';
indicies = indicies & string({MetaData.TestType}) == 'steadyState';
indicies = indicies & ~[MetaData.Locked];
indicies = indicies & ~endsWith(string({MetaData.Folder}),'orginial'); % remove dodgy files

RunsMeta = MetaData(indicies);

[v, theta, AoAr, Mass, Moment] = deal(zeros(length(RunsMeta),1));
[slope,offset] = GetEncoderCalib(MetaData,localDir);

parfor i=1:length(RunsMeta)
    m = load([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename]);
    v(i) = RunsMeta(i).Velocity;
    AoAr(i) = RunsMeta(i).AoA;
    theta(i) = mean(m.d.daq.encoder.v.*slope + offset);    
    [Mass(i),Moment(i)] = CalcMassAndMoment(m.d)
end

% calculate Wing tip local AoA
gamma = 10;
DeltaAlpha = -atand(tand(theta)*sind(gamma));

AoAl = AoAr+DeltaAlpha;

figure(10)
plot(v,AoAl,'+')


%%  estimate the moment of the wing tip
e=[];
i =1;
x = 0.01:0.001:0.1;
for ms = x
    ind = AoAl <10;
    M = Moment(ind) + ms;

    M = M .* cosd(theta(ind)) * 9.81;

    d_ca = (2*M)./(v(ind).^2*1.225*0.035);

    p = polyfit(AoAl(ind),d_ca,4);
    e(i) = sum((d_ca-polyval(p,AoAl(ind))).^2);
    i = i +1;
end
[~,i] = min(e);
fprintf('predicted moment = %.3f Nm\n',x(i));
M = Moment + x(i);
M = M .* cosd(theta) * 9.81;
d_ca = (2*M)./(v.^2*1.225*0.035);
p = polyfit(AoAl,d_ca,4);

% plot the collapse picture 
f = figure(1);
f.Units = 'normalized';
f.Position = [1,0.05,0.5,0.4];
hold off
for i = 1:5 
    ind = Mass == masses(i);  
    plot(AoAl(ind),d_ca(ind),'o');
    grid minor
    hold on
    xlabel('Wing tip local AoA [Deg]')
    ylabel('d_{ca}C_{L\alpha}')   
end
legend({'mEmpty','mQtr','mHalf','m3Qtr','mFull'},'location','southeast')
pl = plot(unique(AoAl),polyval(p,unique(AoAl)),'--');
pl.HandleVisibility = 'off';
title('Variation in the predicted Lift moment arm with local AoA')

function [slope,offset] = GetEncoderCalib(MetaData,localDir)
    indicies = [MetaData.RunNumber] == 153 | [MetaData.RunNumber] == 154;
    RunsMeta = MetaData(indicies);
    encoderVoltage = ones(length(RunsMeta),2);
    Angle = [-63.75 0]'; 
    
    for i =1:length(RunsMeta)
        m = load([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename]);
        encoderVoltage(i,2) = mean(m.d.daq.encoder.v);
    end
    calib = encoderVoltage\Angle;
    slope = calib(2);
    offset = calib(1); 
end

function [mass,moment] = CalcMassAndMoment(runData)
mass = 0;
moment = 0;
for i=0:10
    posMass = runData.inertia.(sprintf('position_%i',i)).mass;
    posMass = posMass /1000;
    mass = mass + posMass;
    moment = moment + posMass * runData.inertia.(sprintf('position_%i',i)).xOffset;
end
end


