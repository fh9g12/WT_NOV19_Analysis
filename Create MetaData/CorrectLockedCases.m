localDir = '\\rdsfcifs.acrc.bris.ac.uk\Aeroelasticity\WINDY\WINDY_TEST_NOV2019\data_v2\';

% Open the Meta-Data file
load([localDir,'..\MetaData.mat']);     % the Metadata filepath

% get the offending runs found when studying hinge case

%% calculate the required runs
currentlockedState = false;
indicies = true([1,length(MetaData)]);
indicies = indicies & string({MetaData.Job}) == 'HingeAngleStudy';
indicies = indicies & string({MetaData.MassConfig}) == massConfigs{2};
indicies = indicies & string({MetaData.TestType}) == 'rGust';
indicies = indicies & ~[MetaData.Locked];
indicies = indicies & contains([{MetaData.Folder}],'locked','IgnoreCase',true);



% Update the meatData
for i = 1:length(MetaData)
    if indicies(i)
        MetaData(i).Locked = 1;
    end   
end
% Save the meta-data
save([localDir,'..\MetaData.mat'],'MetaData')

% filter the MetaData
RunsMeta = MetaData(indicies);


% correct the files themselves
parfor i = 1:length(RunsMeta)
    % If here incorrect mass set
    data = load([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename]);
    data.d.cfg.locked = 1;    
    parsave([localDir,RunsMeta(i).Folder,'\',RunsMeta(i).Filename],d)
end



function parsave(fname, d)
save(fname, 'd')
end