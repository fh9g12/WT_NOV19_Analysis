
% Update MetaData
load('MetaData.mat')

%runs = length(MetaData);
localDir = 'C:\LocalData\';

for i = 1:length(MetaData)
    MetaData(i).Locked = false;
end


parfor i = 1:length(MetaData)
    % If here incorrect mass set
    data = load([localDir,MetaData(i).Folder,'\',MetaData(i).Filename]);
    d = data.d;
    MetaData(i).Locked = logical(d.cfg.locked);
end
