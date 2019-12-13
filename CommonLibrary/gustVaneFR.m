function [p] = gustVaneFR(AmpDeg)
a = max(AmpDeg,0); % make sure input is positive
% 5 deg
p5 = [-0.096555, 0.516143, 0.179915];
%   10 deg
p10 = [-0.105219, 0.613675, 0.040256];
% find output polynomial
p = zeros(size(p5));
for ii = 1:length(p)
    p(ii) = interp1([5,10],[p5(ii),p10(ii)],a,'linear','extrap');
end
end