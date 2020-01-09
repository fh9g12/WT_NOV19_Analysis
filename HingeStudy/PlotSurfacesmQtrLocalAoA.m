
%% mQtr Data
data = readmatrix('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\hinge study results quarter mass.xlsx','Range','B3:H31');
data(26,4:5) = [NaN,NaN]; %
data([14,end],:) = [];  % both not cases I actually ran


%% m3Qtr Data
data2 = readmatrix('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\hinge study results 3 quarter mass.xlsx','Range','B3:H17');

data = [data;data2];
%%Calculate WT Local AoA

theta = deg2rad(data(:,3));
gamma = deg2rad(10);
DeltaAlpha = rad2deg(-atan(tan(theta)*sin(gamma)));
data(:,end+1) = data(:,1)+DeltaAlpha;


%% AoA plot

xi = 2;
yi = 3;
figure(6);

subplot(2,2,1)
GenPlot(data(:,xi),data(:,yi),data(:,4));
xlabel('Velocity m/s')
ylabel('AoA [Deg]')
title('Variation in the first modes frequency [Hz]')

subplot(2,2,2)
GenPlot(data(:,xi),data(:,yi),data(:,6));
xlabel('Velocity m/s')
ylabel('AoA [Deg]')
title('Variation in the second modes frequency [Hz]')

subplot(2,2,3)
GenPlot(data(:,xi),data(:,yi),data(:,5));
xlabel('Velocity m/s')
ylabel('AoA [Deg]')
title('Variation in the first modes damping')

subplot(2,2,4)
GenPlot(data(:,xi),data(:,yi),data(:,7));
xlabel('Velocity m/s')
ylabel('AoA [Deg]')
title('Variation in the second modes damping')


%% Hinge Angle Plot plot
figure(5);
yi = size(data,2);
subplot(2,2,1)
GenPlot(data(:,xi),data(:,yi),data(:,4));
xlabel('Velocity m/s')
ylabel('WT Local AoA [Deg]')
title('Variation in the first modes frequency [Hz]')

subplot(2,2,2)
GenPlot(data(:,xi),data(:,yi),data(:,6));
xlabel('Velocity m/s')
ylabel('WT Local AoA [Deg]')
title('Variation in the second modes frequency [Hz]')

subplot(2,2,3)
GenPlot(data(:,xi),data(:,yi),data(:,5));
xlabel('Velocity m/s')
ylabel('WT Local AoA [Deg]')
title('Variation in the first modes damping')

subplot(2,2,4)
GenPlot(data(:,xi),data(:,yi),data(:,7));
xlabel('Velocity m/s')
ylabel('WT Local AoA [Deg]')
title('Variation in the second modes damping')


function GenPlot(x,y,z)
    zInd = ~isnan(z);
    z = z(zInd);
    x = x(zInd);
    y = y(zInd);


    f = scatteredInterpolant(x,y,z,'natural','none');

    k = boundary(x,y);

    bx = x(k);
    by = y(k);

    xg = linspace(min(x),max(x),50);
    yg = linspace(min(y),max(y),50);

    [X,Y] = meshgrid(xg,yg);

    F = fBoundary(X,Y,f,bx,by);
    
    hold off
    contourf(X,Y,F);
    hold on
    plot(x,y,'+');
    colorbar;
end



function out = fBoundary(X,Y,f,bx,by)
    out = f(X,Y);
    for i = 1:size(X,1)
        for j = 1:size(X,2)
            if ~any(inpolygon(X(i,j),Y(i,j),bx,by))
                out(i,j) = NaN;
            end
        end
    end
end

function output =  sel(booleanVal,ifTrue,ifFalse)
if booleanVal
    output = ifTrue;
else
    output = ifFalse;
end
end