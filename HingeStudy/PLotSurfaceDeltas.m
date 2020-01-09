dataQtr = readmatrix('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\hinge study results quarter mass.xlsx','Range','B3:H31');
dataQtr(26,4:5) = [NaN,NaN]; %
dataQtr([14,end],:) = [];  % both not cases I actually ran

data3Qtr = readmatrix('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\hinge study results 3 quarter mass.xlsx','Range','B3:H17');


xi = 2;
%% Delta Plots
figure(1);
yi = 3;
zi = 4;
DeltaPlot(dataQtr(:,xi),dataQtr(:,yi),dataQtr(:,6)-dataQtr(:,4),data3Qtr(:,xi),data3Qtr(:,yi),data3Qtr(:,6)-data3Qtr(:,4));
xlabel('Velocity m/s')
ylabel('Hinge Angle [Deg]')
title('Variation in the first modes frequency [Hz]')



function DeltaPlot(x1,y1,z1,x2,y2,z2)
    [f1,bx1,by1] = GetFunc(x1,y1,z1);
    [f2,bx2,by2] = GetFunc(x2,y2,z2);
    
    xrange = [max(min(x1),min(x2)),min(max(x1),max(x2))];
    yrange = [max(min(y1),min(y2)),min(max(y1),max(y2))];

    xg = linspace(min(xrange),max(xrange),50);
    yg = linspace(min(yrange),max(yrange),50);

    [X,Y] = meshgrid(xg,yg);

    F = f1(X,Y)-f2(X,Y);
    F = CheckBoundary(X,Y,F,bx1,by1);
    F = CheckBoundary(X,Y,F,bx2,by2);
    hold off
    contourf(X,Y,F);
    hold on
    %plot(x,y,'+');
    colorbar;
end

function [f,bx,by] = GetFunc(x,y,z)
    zInd = ~isnan(z);
    z = z(zInd);
    x = x(zInd);
    y = y(zInd);

    f = scatteredInterpolant(x,y,z,'natural','none');
    
    k = boundary(x,y);

    bx = x(k);
    by = y(k);
end

function GenPlot(x,y,z)
    [f,bx,by] = GetFunc(x,y,z);

    xg = linspace(min(x),max(x),50);
    yg = linspace(min(y),max(y),50);

    [X,Y] = meshgrid(xg,yg);

    F = f(X,Y);
    F = CheckBoundary(X,Y,F,bx,by);
    hold off
    surf(X,Y,F);
    hold on
    plot(x,y,'+');
    colorbar;
end


function Z = CheckBoundary(X,Y,Z,bx,by)
    for i = 1:size(X,1)
        for j = 1:size(X,2)
            if ~any(inpolygon(X(i,j),Y(i,j),bx,by))
                Z(i,j) = NaN;
            end
        end
    end
end

function output = sel(booleanVal,ifTrue,ifFalse)
if booleanVal
    output = ifTrue;
else
    output = ifFalse;
end
end