restoredefaultpath;
addpath('..\CommonLibrary')

% set global parameters
localDir = 'C:\LocalData\';  % the directory containing the 'data' folder

% Open the Meta-Data file
load('..\..\MetaData.mat');


massConfigs = {'mFull','m3Qtr','mHalf','mQtr','mEmpty'};


%pre-allocate strusture
Results = struct();

for i=1:length(massConfigs)
    % pre-allocate
    mCase = massConfigs{i};
    Locked = struct();
    Unlocked = struct();
    
   % get Results
    [Locked.aFreqs,Locked.arSVec,Locked.arVec,Locked.stdSVec,Locked.stdVec]...
        = GetStepSineResponse(localDir,MetaData,mCase,true);
    [Unlocked.aFreqs,Unlocked.arSVec,Unlocked.arVec,Unlocked.stdSVec,Unlocked.stdVec]...
        = GetStepSineResponse(localDir,MetaData,mCase,false);
    
    % Add to Main Structure
    Results.(mCase) = struct();
    Results.(mCase).Locked = Locked;
    Results.(mCase).Unlocked = Unlocked;    
end

save('StepSineResults.mat','Results')

