close all
clear all
clc

% Add folders to path

addpath(genpath('..\Images'),genpath('..\fordanic-openslide-matlab-240c223'),genpath('..\openslide-win64-20160717'));

str = fileread('../Images/20B1083-PAS.xml');
str = str(1:2:length(str)); % Esta línea esta aqui porque el xml añade espacios entre
                            % caracteres
                            
                            
labels = strfind(str,'<Counter name=');

offset = length('<Counter name=');

Annotations.FileName = '20B1083-PAS';
for labelIndex = 1:length(labels)
   
   if labelIndex<length(labels) 
       strLabel = str(labels(labelIndex):labels(labelIndex+1)); 
   else
       strLabel = str(labels(labelIndex):end);
   end
   
   strValueIndices = strfind(strLabel,'"');
   Annotations.LabelName{labelIndex} = strLabel((strValueIndices(1)+1):(strValueIndices(2)-1));
   
   labelPointIndices = strfind(strLabel,'<Point X=');
   offset2 = length('<Point X=');
   
   for labelPointIterator = 1:length(labelPointIndices)
      
       
       if labelPointIterator<length(labelPointIndices) 
           strPoint = strLabel(labelPointIndices(labelPointIterator):labelPointIndices(labelPointIterator+1)); 
       else
           strPoint = strLabel(labelPointIndices(labelPointIterator):end);
       end
       
       strValueIndices2 = strfind(strPoint,'"');
       xPos = strPoint((strValueIndices2(1)+1):(strValueIndices2(2)-1));
       yPos = strPoint((strValueIndices2(3)+1):(strValueIndices2(4)-1));
       
       if labelPointIterator == 1
           Annotations.LabelPosition{labelIndex} = [str2num(xPos),str2num(yPos)];
       else
           Annotations.LabelPosition{labelIndex} = [Annotations.LabelPosition{labelIndex};[str2num(xPos),str2num(yPos)]];
       end
       
   end
   
   Annotations.NumberOfPoints{labelIndex} = size(Annotations.LabelPosition{labelIndex},1);
   
end