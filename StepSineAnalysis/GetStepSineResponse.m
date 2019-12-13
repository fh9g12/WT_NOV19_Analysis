function [aFreqs,arSVec,arVec,stdSVec,stdVec] = GetStepSineResponse(localDir,MetaData,currentMassConfig,currentlockedState,currentJob,currentTestType)
%GETSTEPSINERESPONSE Summary of this function goes here
%   Extracts the averaged, gust corrected, frequency response for a test
%   case during the 'MassStudy' job
%
%   Input parameters:
%       localDir - Directory of the 'data' folder
%       MetaData - Structured Array of run MetaData
%       currentMassConfig - massConfig of the test to extract
%       currentlockedState - whether to extract locked or unlocked wing case
%       currentJob - job to extract data from (default = 'massStudy')
%       currentTestType - Test Type to extract data from (default = 'conGust')
%
%   OutputParameters:
%       aFreqs - Frequencies that data has been record at
%       arSVec - gust-corrected response of each accelerometer
%       arVec - response of each accelerometer
%       stdSVec - gust-corrected std of each accelerometer
%       stdVec - std of each accelerometer
%
% Created by Fintan Healy, 12th Dec 2019, Matlab 2019a.

% set defualts if required
if ~exist('currentJob','var')
    currentJob = 'MassStudy';
end
if ~exist('currentTestType','var')
    currentTestType = 'conGust';
end


%% calculate the required runs
indicies = string({MetaData.Job}) == currentJob;
indicies = indicies & string({MetaData.MassConfig}) == currentMassConfig;
indicies = indicies & string({MetaData.TestType}) == currentTestType;
if currentlockedState
    indicies = indicies & [MetaData.Locked];
else
    indicies = indicies & ~[MetaData.Locked];
end

% filter the MetaData
RunsMeta = MetaData(indicies);

%% calculate the responses for each run

%pre-allocate some arrays
Freqs = zeros(1,length(RunsMeta));  % frequency of each run
rVec = zeros(length(RunsMeta),11);  % ungust-corrected responses
rSVec = zeros(length(RunsMeta),11); % gust-corrected response

parfor i = 1:length(RunsMeta)
    % load the data for this run
    data = load([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename]);
    d = data.d;
    
    % extract the required data from the file
    accV = d.daq.accelerometer.v;
    vel = d.cfg.velocity;
    Fs = d.daq.rate;
    a = d.daq.gust.v;
    N = size(accV,1);
    Freqs(i) = d.gust.frequency;
    
    % for each accelerometer channel compute the Frequency response
    for j = 1:11
    %for j = 1:size(accV,2)
        x = accV(:,j);
%         y = lowpass(x,fpass,m.d.daq.rate);
%         rVec(ff,ii) = rms(y);
        
        % calculate the response of the aceelerometer
        [FRF, dft_a, dft_b] = FRA(a,x,Freqs(i),Fs,N);
        rVec(i,j) = abs(FRF);
        
        % correct for the frequency response of the gust vanes
        AmpDeg = rms(a);
        sc = gustScaling(vel,Freqs(i),AmpDeg)/AmpDeg;
        rSVec(i,j) = rVec(i,j)/sc;
    end  
end

% calculate the average response for each frequency
aFreqs = unique(round(Freqs,1));

% pre-allocate average arrays
arVec = zeros(length(aFreqs),11);  % ungust-corrected responses
stdVec = zeros(length(aFreqs),11);  % ungust-corrected std
arSVec = zeros(length(aFreqs),11); % gust-corrected response
stdSVec = zeros(length(aFreqs),11); % gust-corrected std

for i = 1: length(aFreqs)
    %populate means
    arVec(i,:) = mean(rVec(Freqs==aFreqs(i),:));
    arSVec(i,:) = mean(rSVec(Freqs==aFreqs(i),:));
    
    % populate std's
    stdVec(i,:) = std(rVec(Freqs==aFreqs(i),:));
    stdSVec(i,:) = std(rSVec(Freqs==aFreqs(i),:));
end

end


function [FRF, dft_a, dft_b] = FRA(a,b,f,Fs,N)

% FRA - Frequency Response Analyzer
% Applies Hanning window and then computes FRF point from stepped sine measurement. It uses Goertzel algorithm for computation of discrete Fourier transform 
% 
%   FRF = FRA(a,b,f,Fs)
%   FRF = FRA(a,b,f,Fs,N)
%
% Input parameters:
%   a ... excitation signal - vector (n,1)
%   b ... output signal in steady state - vector(n,1)
%   f ... frequency of interest (excitation frequency) [Hz]
%   Fs ... sampling frequency [Hz]
%   N ... number of points for calculation (N last points from a,b), N should be as high as possible (N < numel(a)) - default: 100 
%
% Output parameters:  
%   FRF - one points of frequency response function at given frequency (f) - compex scalar (1,1)
%
% Example:
%   Fs = 1000;  
%   f = 50; 
%   t = linspace(0,1,Fs);
%   a = sin(2*pi*50*t)';
%   b = 2*sin(2*pi*50*t + pi)';
%   FRF = FRA(a,b,f,Fs);
%   FRF = FRA(a,b,f,Fs,500);
%
% Referencies:
%   [1] Ewins D.J.: Modal Testing: theory, practice and application, 2001
%
% Created by Vaclav Ondra, 20th Jul 2014, Matlab 2014a,

    if nargin == 4 % only 4 inputs entered
        N = 100; % default value for points
    end
    
    win = hann(N); % hanning window
    a = a(end-N+1:end).*win; % application of window on the signal, just in steady state (given by N)
    b = b(end-N+1:end).*win;

    freq_index = round(f/Fs*N)+1; % index of frequency which will be computed

    
    dft_a = 2*2*goertzel(a,freq_index)/N; % DFT computed using Goertzel algorithm - System Processing Toolbox is needed
    dft_b = 2*2*goertzel(b,freq_index)/N; % corrections: first '2' for Hanning window, and '2/N' for the algorithm

    FRF = dft_b/dft_a; % FRF estimate

end
