
% Update MetaData
load('MetaData.mat')

parfor i = 1:length(localDir)
  % set Job
  folders = strsplit(localDir(i).folder,'\');   
  % check if it was a calibration
  index = find(contains(folders,'calibration'),1);
  if ~isempty(index)
      MetaData(i).Job = 'Calibration';
  end

  % check if it was a Part of the Trim Tests
  indicies = [find(contains(folders,'19NOV2019'),1),...
  find(contains(folders,'20NOV2019'),1),...
  find(contains(folders,'21NOV2019'),1),...
  find(contains(folders,'22NOV2019'),1)];  
  if ~isempty(indicies)
      MetaData(i).Job = 'TrimStudy';
  end

  %find is returning a nmber that I can't or!!!!!!!!!!


  % check if it was a Part of the Mass Tests
  indicies = [find(contains(folders,'25NOV2019'),1),...
            find(contains(folders,'26NOV2019'),1),...
            find(contains(folders,'27NOV2019'),1),...
            find(contains(folders,'28NOV2019'),1),...
            find(contains(folders,'29NOV2019'),1),...
            find(contains(folders,'02DEC2019'),1)];
  if ~isempty(indicies)
      MetaData(i).Job = 'MassStudy';
  end



  % check if it was a Hinge Angle Test
  index = find(contains(folders,'EffectOfHingeAngle'),1);
  if ~isempty(index)
      MetaData(i).Job = 'HingeAngleStudy';
  end

  % check if it was an Impulse Test
  index = find(contains(folders,'Impulse Response Tests'),1);
  if ~isempty(index)
      MetaData(i).Job = 'ImpulseResponseStudy';
  end

  % check if it was a Part of GRT Tests
  index = find(contains(folders,'GRT'),1);
  if ~isempty(index)
      MetaData(i).Job = 'GvtStudy';
  end

  % check if it was the random LCO/Flutter Data
  index = find(contains(folders,'mEmpty_LCO'),1);
  if ~isempty(index)
      MetaData(i).Job = 'LcoStudy';
  end
end
