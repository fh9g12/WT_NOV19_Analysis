function [RealAmpDeg] = gustScaling(vel,freq,AmpDeg)
% find scaled amplitude due to Gust Vane response
p = gustVaneFR(AmpDeg);
xp = freq./vel*pi;
RealAmpDeg = polyval(p,xp)*AmpDeg;
end