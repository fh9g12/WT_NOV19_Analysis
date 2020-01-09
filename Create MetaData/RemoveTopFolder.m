% Update MetaData
load('MetaData.mat')

runs = length(MetaData);

for i = 1:runs
  % get folders
  folders = strsplit(MetaData(i).Folder,'\');
   
  %remove first path
  folders(1)=[];
  
  
  % create relative folder path
  folderPath = strjoin(folders,'\');
  
  % add to the MetaData 
  MetaData(i).Folder = folderPath;
end
