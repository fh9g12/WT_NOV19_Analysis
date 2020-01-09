data = readmatrix('\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\Reports\hinge study results quarter mass.xlsx','Range','B3:H31');

xi = 2;
yi = 1;

z = [data(:,[])]

%z = data(:,6)-data(:,4);
z = data(:,6);


index = ~isnan(z);

z = z(index);
x = data(index,xi);
y = data(index,yi);

f = scatteredInterpolant(x,y,z,'natural','none');

k = boundary(x,y);

bx = x(k);
by = y(k);

xg = linspace(min(x),max(x),50);
yg = linspace(min(y),max(y),50);

[X,Y] = meshgrid(xg,yg);

F = fBoundary(X,Y,f,bx,by);
%F = f(X,Y);

figure(6);
hold off
contourf(X,Y,F);
hold on
plot(x,y,'+');
colorbar;


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