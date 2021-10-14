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

cd ../Imagenes3 % Chose data base we are going to cut
folderList = dir;
cd ..
cd CodigosMatlab

folderList = {folderList.name};
% folderList = {'CONTAJE 2021-04-21'};

for folderIterator = 3:length(folderList)
    folderList(folderIterator)
    filePath = strcat('../Imagenes3/',folderList{folderIterator});
    cd(filePath)
    fileList = dir('*.tif');
    cd ../..
    cd CodigosMatlab
    fileList = {fileList.name};
    
%     fileList = {'20B0006900 PAS.tif'};
    for fileIterator = 1:length(fileList)
        
        
        % Set file name of whole-slide image to work with
        WSI = [folder,filesep,filePath,filesep,fileList{fileIterator}];

        % Open whole-slide image
        slidePtr = openslide_open(WSI);


        %% XML LOADER AND STRUCTURE PREPARATION
        
        xmlFileName = fileList{fileIterator};
%         xmlFileName = '09B0009704 PM.tif';
        xmlFileName = xmlFileName(1:end-4);
        xmlFileName = strcat(xmlFileName,'.xml');
        
        indiceAuxiliarTincion = strfind(xmlFileName,' ');
        indiceAuxiliarTincionPunto = strfind(xmlFileName,'.');
        Annotations.Tincion = xmlFileName(indiceAuxiliarTincion+1:indiceAuxiliarTincionPunto-1);
        
        loadString = strcat(filePath,'/',xmlFileName);
        str = fileread(loadString);
        str = str(1:2:length(str)); % Esta línea esta aqui porque el xml añade espacios entre
                                    % caracteres


        labels = strfind(str,'<Counter name=');

        offset = length('<Counter name=');

        Annotations.FileName = xmlFileName(1:end-4);
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
           
           if isempty(labelPointIndices)
               Annotations.LabelPosition{labelIndex} = [];
           end
           
           if size(Annotations.LabelPosition,2)<labelIndex
               Annotations.NumberOfPoints{labelIndex} = 0;
           else
               Annotations.NumberOfPoints{labelIndex} = size(Annotations.LabelPosition{labelIndex},1);
           end

        end




        %% CUTTING AND SAVING SUBIMAGES

        
        squaredDimension = 600;

        for labelIndex = 1:length(Annotations.LabelName)
            
            folderName = strcat('../DataBase3/',Annotations.Tincion,'/',Annotations.LabelName{labelIndex},'/');
            status = mkdir(folderName);

            for pointIndex = 1:Annotations.NumberOfPoints{labelIndex}

            % Read a part of the image

                xHighLeftCorner = Annotations.LabelPosition{labelIndex}(pointIndex,1) - squaredDimension/2;
                yHighLeftCorner = Annotations.LabelPosition{labelIndex}(pointIndex,2) - squaredDimension/2;
                
                [widthLevel, heightLevel] = openslide_get_level_dimensions(slidePtr,0);
                
                if xHighLeftCorner + squaredDimension - 1 >= widthLevel
                    xHighLeftCorner = widthLevel - squaredDimension;
                end
                if yHighLeftCorner + squaredDimension - 1 >= heightLevel
                    yHighLeftCorner = heightLevel - squaredDimension;
                end
                if xHighLeftCorner < 0
                    xHighLeftCorner = 0;
                end
                if yHighLeftCorner < 0
                    yHighLeftCorner = 0;
                end
                
                ARGB = openslide_read_region(slidePtr,xHighLeftCorner,yHighLeftCorner,squaredDimension,squaredDimension,0);

                % Display RGB part

                fig = figure('visible','off');
                imshow(ARGB(:,:,2:4));
                set(gcf,'Name','WSI','NumberTitle','off');
                
                I = getimage(fig);
                imageName = strcat('../DataBase3/',Annotations.Tincion,'/',Annotations.LabelName{labelIndex},'/',Annotations.FileName,'-',Annotations.LabelName{labelIndex},'-Point',num2str(pointIndex),'.png');
                imwrite(I,imageName);
                

            end

        end
        imageName = strcat(Annotations.FileName,'.mat');
        save(strcat('../DataBase3/structureFiles/',imageName),'Annotations');
%         clear Annotations;
    end
end


