
% Update MetaData
load('MetaData.mat')

runs = length(MetaData);
i=0;

for i = 1:runs
  % get folders
  folders = strsplit(MetaData(i).FileLocation,'\');
   
  %remove first two paths C:\LocalData
  folders(1:2)=[];
  
  %get filename
  filename = folders{end};
  folders(end) = [];
  
  
  % create relative folder path
  folderPath = strjoin(folders,'\');
  
  % add to the MetaData 
  MetaData(i).Filename = filename;
  MetaData(i).Folder = folderPath;
end
