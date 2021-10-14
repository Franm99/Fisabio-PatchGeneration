% cuttingScript.m
%
% This script loades tiff images and xml annotation files and saves squared
% images around the area given by the annotations
%
% Creation: 09/07/2020
% author: sabate@uji.es


clear all
close all
clc

%% IMAGE LOADER

% Add folders to path

addpath(genpath('..\Images'),genpath('..\fordanic-openslide-matlab-240c223'),genpath('..\openslide-win64-20160717'));

% Get folder of this file
[folder,~,~] = fileparts(mfilename('fullpath'));

% Load openslide library
openslide_load_library();

% Set file name of whole-slide image to work with
WSI = [folder,filesep,'..\Images',filesep,'20B0005175 A 18 PM.tif'];

% Open whole-slide image
slidePtr = openslide_open(WSI);


%% XML LOADER AND STRUCTURE PREPARATION

str = fileread('../Images/20B0005175-A-18-PM.xml');
str = str(1:2:length(str)); % Esta línea esta aqui porque el xml añade espacios entre
                            % caracteres
                            
                            
labels = strfind(str,'<Counter name=');

offset = length('<Counter name=');

Annotations.FileName = '20B0005175-A-18-PM';
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




%% CUTTING AND SAVING SUBIMAGES

folderName = strcat('../ProcessedImages/',Annotations.FileName,'/');
status = mkdir(folderName) ;
squaredDimension = 512;

Annotations.NumberOfPoints

for labelIndex = 1:length(Annotations.LabelName)
    
    for pointIndex = 1:Annotations.NumberOfPoints{labelIndex}
    
    % Read a part of the image
    
        xHighLeftCorner = Annotations.LabelPosition{labelIndex}(pointIndex,1) - squaredDimension/2;
        yHighLeftCorner = Annotations.LabelPosition{labelIndex}(pointIndex,2) - squaredDimension/2;

        ARGB = openslide_read_region(slidePtr,xHighLeftCorner,yHighLeftCorner,squaredDimension,squaredDimension,0);
    
        % Display RGB part

        fig = figure('visible','off');
        imshow(ARGB(:,:,2:4));
        set(gcf,'Name','WSI','NumberTitle','off');
        
        imageName = strcat('../ProcessedImages/',Annotations.FileName,'/',Annotations.FileName,'-',Annotations.LabelName{labelIndex},'-Point',num2str(pointIndex),'.png');
        saveas(fig,imageName);

        
    end
    
end


