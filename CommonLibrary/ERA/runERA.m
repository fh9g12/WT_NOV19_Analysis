function [fSelected,dSelected] = runERA(yi,samplingRate,fmax,alpha)
%% ERA
% Created by : R Cheung
% Contact: r.c.m.cheung@bristol.ac.uk
% Date: Oct 2019
%
% Input : each column of yi is an input data channel
%% prep
dt = 1/samplingRate;
%% filter signal
[y,~] = filterSignal(yi,dt,fmax);
%% FFT
N = size(y,1);
N = 2^nextpow2(N);
df = samplingRate/N;
[~,ys] = genfft(samplingRate,y,N);
%% prep ERA-DC
[H0,H1] = genHankelMat(y,alpha);
[P,D,Q] = svd(H0,'econ'); % SVD of H0 matrix  (using the "skinny" version)
plotSVD(D); % plot SVD
[fSelected,dSelected] = solveERA(H1,P,D,Q,dt,df,ys,fmax);
end
