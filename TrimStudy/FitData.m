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


%% Where does the variance come from? Perhaps the delta AoA between main wing and Wing tip?

% calc errors for all postions below AoA 14 as obvisous different regime
% above
e = d_ca - polyval(p,AoAl);
f = figure(2);
f.Units = 'normalized';
f.Position = [1,0.55,0.5,0.4];

sp = subplot(1,2,1)
cla(sp);
grid minor
xlabel('AoAl - AoAr [deg]')
ylabel('\Deltad_{ca}C_{L\alpha}')
hold on

sp = subplot(1,2,2)
cla(sp);
grid minor
xlabel('Hinge Angle [deg]')
ylabel('\Deltad_{ca}C_{L\alpha}')
hold on

for i = 1:5 
    ind = Mass == masses(i) & AoAl <8;
    subplot(1,2,1)
    plot(DeltaAlpha(ind),e(ind),'o');
    grid minor
    hold on
    subplot(1,2,2)
    plot(theta(ind),e(ind),'o');
    grid minor
    hold on 
end




f = figure(2);
close(f)
f = figure(2);
f.Units = 'normalized';
f.Position = [1,0.5,0.98,0.4];

% remove linear trend for AoAl below 9 degrees
ind = AoAl <9 & v>18;
B = d_ca(ind);
A = [ones(size(d_ca(ind))),AoAl(ind)];
x = A\B;

d_ca_org = d_ca;
d_ca = d_ca - [ones(size(d_ca)),AoAl]*x;

% remove linear trend for v above 15 m/s
ind = AoAl <9 & v>18;
B = d_ca(ind);
A = [ones(size(d_ca(ind))),v(ind)];
x = A\B;

%d_ca = d_ca - [ones(size(d_ca)),v]*x;
%d_ca_org = d_ca_org - [ones(size(d_ca)),v]*x;
% remove squared trend from Delta AoA
ind = AoAl <9 & v>18;
B = d_ca(ind);
A = [ones(size(d_ca(ind))),DeltaAlpha(ind).^2,DeltaAlpha(ind)];
x = A\B;

%d_ca = d_ca - [ones(size(d_ca)),DeltaAlpha.^2,DeltaAlpha]*x;
%d_ca_org = d_ca_org - [ones(size(d_ca)),DeltaAlpha.^2,DeltaAlpha]*x;
%d_ca = d_ca_org;


for i = 1:5
    ind = Mass == masses(i) & AoAl <9 & v>18 ;  
    subplot(1,5,1)
    plot(v(ind),d_ca(ind),'o');
    grid minor
    hold on
    xlabel('Velocity [m/s]')
    ylabel('d_{ca}C_L')
    subplot(1,5,2)
    plot(AoAr(ind),d_ca(ind),'o');
    grid minor
    hold on
    xlabel('Root AoA [Deg]')
    ylabel('d_{ca}C_L')
    subplot(1,5,3)
    plot(AoAl(ind),d_ca(ind),'o');
    grid minor
    hold on
    xlabel('Wing tip local AoA [Deg]')
    ylabel('d_{ca}C_L')
    subplot(1,5,4)
    plot(Moment(ind),d_ca(ind),'o');
    grid minor
    hold on
    xlabel('Moment [Kgm]')
    ylabel('d_{ca}C_L')
    subplot(1,5,5)
    plot(DeltaAlpha(ind),d_ca(ind),'o');
    grid minor
    hold on
    xlabel('Delta AoA [deg]')
    ylabel('d_{ca}C_L')    
end




plot3(v(ind),AoAl(ind),d_ca(ind),'o')
grid minor
hold off
ind = v>15;

sf = fit([AoAr(ind),AoAl(ind)],d_ca(ind),'poly22');

plot(sf,[AoAr(ind),AoAl(ind)],d_ca(ind))

f = scatteredInterpolant(AoAr(ind),AoAl(ind),d_ca(ind));

[X,Y] = meshgrid(linspace(min(AoAr),max(AoAr),100),linspace(min(AoAl),max(AoAl),100));

Z = f(X,Y);

p = plot3(AoAr(ind),AoAl(ind),d_ca(ind),'o');
hold on
surf(X,Y,Z);





% clear out some dodgy cases



masses = unique(Mass);
calibs = zeros(2,5);
f = figure(1);
f.Units = 'normalized';
f.Position = [0,0,1,1];
hold off
for i = 1:5
    ind = Mass == masses(i) & v>15;  
    p = plot(v(ind),AoAl(ind),'o');
    hold on
    B = AoAl(ind)./cosd(theta(ind));
    A = [ones(size(v(ind))),1./v(ind).^2];
    x = A\B;
    calibs(:,i) = x;
    vf = unique(v(ind));
    Af = [ones(size(vf)),1./vf.^2];
    p2 = plot(vf,Af*x,'--');
    p2.Color = p.Color;
    p2.HandleVisibility = 'off';
end
legend(arrayfun(@(x)sprintf('%.1f g',x),string(num2str(masses*1000)),'UniformOutput',false))
grid minor
xlabel('Velocity [m/s]')
ylabel('Wing tip Local AoA [Deg]')
title('Variation in the mean Wing tip Local AoA for varying speeds and tip masses')



f = figure(1);
f.Units = 'normalized';
f.Position = [0,0,1,0.5];
for i = 1:5
    subplot(1,5,i)
    hold off
    ind = Mass == masses(i);  
    AoAs = unique(AoAr(ind));
    labels = {};
    for j = 1:length(AoAs)
        indAoA = ind & AoAr == AoAs(j);
        plot(v(indAoA),AoAl(indAoA),'o');
        labels{j} = sprintf('%.1f Root AoA',AoAs(j));
        hold on
        legend(labels)
    end  
    grid minor
    xlabel('Velocity [m/s]')
    ylabel('Wing tip Local AoA [Deg]')
end


f = figure(2);
f.Units = 'normalized';
f.Position = [0,0,1,0.5];
for i = 1:5
    subplot(1,5,i)
    hold off
    ind = Mass == masses(i);  
    AoAs = unique(AoAr(ind));
    labels = {};
    for j = 1:length(AoAs)
        indAoA = ind & AoAr == AoAs(j);
        plot(v(indAoA),theta(indAoA),'o');
        labels{j} = sprintf('%.1f Root AoA',AoAs(j));
        hold on
        legend(labels)
    end  
    grid minor
    xlabel('Velocity [m/s]')
    ylabel('Hinge Angle [m/s]')
    title(sprintf('Mass case %.1f grammes',masses(i)*1000))
end

figure(3)
subplot(2,1,1)
hold off
AoAs = unique(AoAr(ind));
labels = {};
for j = 1:length(AoAs)
    indAoA = AoAr == AoAs(j);
    
    plot(v(indAoA),AoAl(indAoA),'o');
    labels{j} = sprintf('%.1f Root AoA',AoAs(j));
    hold on
    legend(labels)
end  
grid minor
xlabel('Velocity [m/s]')
ylabel('Wing tip local AoA [m/s]')


subplot(2,1,2)
extraMoment = 0.1035;
g = 9.81;
d_ca = ((Moment+extraMoment).*cosd(theta)*g)./(0.5.*v.^2.*AoAl);
y = (0.5*1.225.*v.^2.*theta)./(cosd(theta).*g);

hold off
for i = 1:5   
    ind = Mass == masses(i) & AoAl<10;
    plot(0.5*1.225.*v(ind).^2.*0.035.*AoAl(ind),(Moment(ind)+extraMoment).*cosd(theta(ind)).*g,'o');    
    hold on
end
legend(arrayfun(@(x)sprintf('%.1f g',x),string(num2str(masses*1000)),'UniformOutput',false))
grid minor
xlabel('Velocity [m/s]')
ylabel('d_ca [m]')


f = figure(4);
f.Units = 'normalized';
f.Position = [0,0,1,0.5];

for i = 1:5
    sp = subplot(1,5,i);
    hold off
    ind = Mass == masses(i) ;% & AoAl < 12;  
    AoAs = unique(AoAr(ind));
    labels = {};
    for j = 1:length(AoAs)
        indAoA = ind & AoAr == AoAs(j);
        p = plot(v(indAoA),d_ca(indAoA),'o');
        labels{j} = sprintf('%.1f Root AoA',AoAs(j));
        hold on
        legend(labels)      
    end  
    grid minor
    xlabel('Velocity [m/s]')
    ylabel('d_ca [m]')
    %sp.YScale = 'log';
    title(sprintf('Mass case %.1f grammes',masses(i)*1000))
end







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


