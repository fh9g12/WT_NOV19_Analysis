load('ERA_timeSeries.mat')

f = figure(1);
f.Units = 'normalized';
f.OuterPosition = [0 0 1 1];
hold off
for i=1:5
    
   subplot(5,2,(i-1)*2+1) 
   t = (1:length(data.yInitialFiliter(:,i)))/425;
   plot(t,data.yInitialFiliter(:,i))
   if i == 1
       title('Filtered Random Time Signal')    
   elseif i == 5
       xlabel('time [s]')
   end
   ylabel('Signal Voltage [V]')
     
   subplot(5,2,(i-1)*2+2) 
   t = (1:length(data.yCorrel(:,i)))/425;
   plot(t,data.yCorrel(:,i))
   if i == 1
       title('Puesdo Impulse Response')
   elseif i == 5
       xlabel('time [s]')
   end   
   
end
