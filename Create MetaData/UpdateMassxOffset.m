
% Update MetaData
load('MetaData.mat')

%runs = length(MetaData);
localDir = 'C:\LocalData\';

L = 0.1535:0.0148:0.302; % moment arms

parfor i = 1:length(MetaData)
    % If here incorrect mass set
    data = load([localDir,MetaData(i).Folder,'\',MetaData(i).Filename]);
    d = data.d;
    for j=1:11
       d.inertia.(sprintf('position_%d',j-1)).xOffset = L(j); 
    end
    parsave([localDir,MetaData(i).Folder,'\',MetaData(i).Filename],d)
end



function parsave(fname, d)
save(fname, 'd')
end