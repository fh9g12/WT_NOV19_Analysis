
% Update MetaData
load('MetaData.mat')

%runs = length(MetaData);
localDir = 'C:\LocalData\';

parfor i = 1:length(MetaData)
    mConfig = MetaData(i).MassConfig;
    switch mConfig
        case {'mEmpty','mQtr','mHalf','m3Qtr','mFull'}
            continue;  
    end
    % If here incorrect mass set
    data = load([localDir,MetaData(i).Folder,'\',MetaData(i).Filename]);
    d = data.d;
    if ~isfield(d,'inertia')
        disp([localDir,MetaData(i).Folder,'\',MetaData(i).Filename])   
    elseif d.inertia.position_10.mass>0
        if d.inertia.position_8.mass>0
            if d.inertia.position_6.mass>0
                MetaData(i).MassConfig = 'mFull';
            else
                MetaData(i).MassConfig = 'm3Qtr';
            end
        else
            MetaData(i).MassConfig = 'mQtr';
        end
    elseif d.inertia.position_8.mass>0
        MetaData(i).MassConfig = 'mFull';
    else
        MetaData(i).MassConfig = 'mEmpty';
    end   
end
