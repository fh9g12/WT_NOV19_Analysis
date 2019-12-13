%%get a list of all .mat files within a directory

matFiles = struct([]);

localDir = dir('C:\LocalData\data_v2\**\*.mat');

parfor i = 1:length(localDir)
    %clearvars -except localDir matFiles RunNumber i
    d = load([localDir(i).folder,'\',localDir(i).name])
    if ~isempty(d)
      if isfield(d,'cfg')
          % if here this is a valid .mat file
          if ~isfield(d.cfg,'runNumber')
              % no run Number field so create one
              d.cfg.runNumber = i;          
          end
      end
      
      % save the new file
       parsave([localDir(i).folder,'\',localDir(i).name],d)
      
      % Populate the Meta Data structure
      matFiles(i).RunNumber = i;
      matFiles(i).AoA = d.cfg.aoa;
      matFiles(i).Velocity = d.cfg.velocity;
      matFiles(i).MassConfig = d.cfg.testType;
      matFiles(i).ZeroRun = [];
      matFiles(i).SteadyStateRun = [];
      matFiles(i).FinalZeroRun = [];
      matFiles(i).Comment = '';
      matFiles(i).Job = '';
      matFiles(i).FileLocation = [localDir(i).folder,'\',localDir(i).name];
           
      % set Test Type Info
      if contains(localDir(i).name,'datum')
          matFiles(i).TestType = 'datum';
      elseif contains(localDir(i).name,'rGust')
          matFiles(i).TestType = 'rGust';
          matFiles(i).Amplitude = d.gust.amplitudeDeg;
      elseif contains(localDir(i).name,'conGust')
          matFiles(i).TestType = 'conGust';
          matFiles(i).Frequency = d.gust.frequency;
          matFiles(i).Amplitude = d.gust.amplitudeDeg;
      else
          matFiles(i).TestType = 'steadyState';
      end
      
      % set Date 
      folders = strsplit(localDir(i).folder,'\')
      index = find(contains(folders,'2019'));
      if ~isempty(index)
          matFiles(i).Date = folders{index};
      end
           
    end
end


function parsave(fname, d)
save(fname, 'd')
end




