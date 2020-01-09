
%% mQtr Case
data = readmatrix('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\hinge study results quarter mass.xlsx','Range','B3:H31');

% remove dodgy row
data(26,4:5) = [NaN,NaN]; %
data([14,end],:) = [];  % both not cases I actually ran

%% m3Qtr Case
%data = readmatrix('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\hinge study results 3 quarter mass.xlsx','Range','B3:H17');

% remove dodgy row
%data(26,4:5) = [NaN,NaN]; %
%data([14,end],:) = [];  % both not cases I actually ran



%% Data Processing
aoa = round(data(:,1),1);
v = round(data(:,2),1);
hingeAngle = data(:,3);
f1 = data(:,4);
d1=data(:,5);
f2= data(:,6);
d2 = data(:,7);


%% Make some graphs

% get unique aoa's
AoAs = unique(aoa);
f = figure(1);
f.Units = 'normalized';
f.Position = [0,0,0.5,1];
% plot frequency and damping for each aoa 
for i = 1:length(AoAs)
    frac = (i-1)*(1/length(AoAs));
    index = aoa == AoAs(i);
    
    subplot(2,1,1)
    if i==1
        hold off
    end
    p1 = plot(v(index),f1(index),'o-');
    p1.Color = [1 frac 0];
    hold on
    p2 = plot(v(index),f2(index),'o-');
    p2.Color = [0 frac 1];
    
    subplot(2,1,2)
    if i==1
        hold off
    end
    p1 = plot(v(index),d1(index),'o-');
    p1.Color = [1 frac 0];
    hold on
    p2 = plot(v(index),d2(index),'o-');
    p2.Color = [0 frac 1];  
end

subplot(2,1,1)
grid minor
xlabel('Velocity [m/s]')
ylabel('Frequency [Hz]')
legend('First Mode','Second Mode')
title('Variation in the frequency of the first and second modes of the model with airspeed, for 4 differnt AoA (2.5,5,7.5,10)')
title('Variation in the frequency of the first and second modes of the model with airspeed, for 3 differnt AoA (6,8.6,10)')

subplot(2,1,2)
grid minor
xlabel('Velocity [m/s]')
ylabel('Damping []')
legend('First Mode','Second Mode')
title('Variation in the damping of the first and second modes of the model with airspeed, for 4 differnt AoA (2.5,5,7.5,10)')
title('Variation in the damping of the first and second modes of the model with airspeed, for 3 differnt AoA (6,8.6,10)')


% get unique aoa's
Vs = unique(v);


f = figure(2);
f.Units = 'normalized';
f.Position = [0.5,0,0.5,1];
for i = 1:length(Vs)
    frac = (i-1)*(1/length(Vs));
    index = v == Vs(i);
    
    subplot(2,1,1)
    if i==1
        hold off
    end
    p1 = plot(hingeAngle(index),f1(index),'o');
    p1.Color = [1 frac 0];
    hold on
    p2 = plot(hingeAngle(index),f2(index),'o');
    p2.Color = [0 frac 1];
    
    subplot(2,1,2)
    if i==1
        hold off
    end
    p1 = plot(hingeAngle(index),d1(index),'o');
    p1.Color = [1 frac 0];
    hold on
    p2 = plot(hingeAngle(index),d2(index),'o');
    p2.Color = [0 frac 1];  
end


subplot(2,1,1)
xlabel('Hinge Angle [Deg]')
ylabel('Frequency [Hz]')
legend('First Mode','Second Mode')
title('Variation in the frequency of the first and second modes of the model with Hinge Angle')
grid minor

subplot(2,1,2)
xlabel('Hinge Angle [Deg]')
ylabel('Damping []')
legend('First Mode','Second Mode')
title('Variation in the damping of the first and second modes of the model with Hinge Angle')
grid minor








% xi = 2;
% yi = 3;
% 
% z = [data(:,[])]
% 
% z = data(:,6)-data(:,4);
% %z = data(:,4);
% 
% 
% index = ~isnan(z);
% 
% z = z(index);
% x = data(index,xi);
% y = data(index,yi);
% 
% f = scatteredInterpolant(x,y,z,'natural','none');
% 
% k = boundary(x,y);
% 
% bx = x(k);
% by = y(k);
% 
% xg = linspace(min(x),max(x),200);
% yg = linspace(min(y),max(y),200);
% 
% [X,Y] = meshgrid(xg,yg);
% 
% F = fBoundary(X,Y,f,bx,by);
% %F = f(X,Y);
% 
% figure(6);
% hold off
% contourf(X,Y,F);
% hold on
% plot(x,y,'+');
% colorbar;
% 
% 
% function out = fBoundary(X,Y,f,bx,by)
%     out = f(X,Y);
%     for i = 1:size(X,1)
%         for j = 1:size(X,2)
%             if ~any(inpolygon(X(i,j),Y(i,j),bx,by))
%                 out(i,j) = NaN;
%             end
%         end
%     end
% end
% 
% function output =  sel(booleanVal,ifTrue,ifFalse)
% if booleanVal
%     output = ifTrue;
% else
%     output = ifFalse;
% end
% end