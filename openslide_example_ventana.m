% OPENSLIDE_EXAMPLE An example of how to use the MATLAB bindings with
% the OpenSlide library for working with whole-slide images

% Copyright (c) 2016 Daniel Forsberg
% danne.forsberg@outlook.com
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

close all

% Add folders to path

addpath(genpath('..\Images'),genpath('..\fordanic-openslide-matlab-240c223'),genpath('..\openslide-win64-20160717'));

% Get folder of this file
[folder,~,~] = fileparts(mfilename('fullpath'));

% Load openslide library
openslide_load_library();

disp(['OpenSlide version: ',openslide_get_version()])

% Set file name of whole-slide image to work with
WSI = [folder,filesep,'..\Images',filesep,'20B0001083 A1 PM.tif'];

% Display vendor of whole-slide image
disp(['Vendor: ',openslide_detect_vendor(WSI)])

% Open whole-slide image
slidePtr = openslide_open(WSI);

% Get whole-slide image properties
[mppX, mppY, width, height, numberOfLevels, ...
    downsampleFactors, objectivePower] = openslide_get_slide_properties(slidePtr);

% Display properties
disp(['mppX: ',num2str(mppX)])
disp(['mppY: ',num2str(mppY)])
disp(['width: ',num2str(width)])
disp(['height: ',num2str(height)])
disp(['number of levels: ',num2str(numberOfLevels)])
disp(['downsample factors: ',num2str(transpose(downsampleFactors))])
disp(['objective power: ',num2str(objectivePower)])

% Read a part of the image

xHighLeftCorner = 11000;
yHighLeftCorner = 15000;
width = 2048;
height = 2048;

ARGB = openslide_read_region(slidePtr,xHighLeftCorner,yHighLeftCorner,width,height,0);

% Display RGB part
figure(3)
imshow(ARGB(:,:,2:4))
set(gcf,'Name','WSI','NumberTitle','off')

% Get property names and display them
propertyNames = openslide_get_property_names(slidePtr);
disp(propertyNames(:))

% Get a property value
propertyValue = openslide_get_property_value(slidePtr,propertyNames{5});
% disp(propertyNames{5})
% disp(propertyValue)

% Get all property values
% for p=1 : 68
%     propertyValue = openslide_get_property_value(slidePtr,propertyNames{p});
%     disp(propertyNames{p})
%     disp(propertyValue)
% end


% Get associated images
associatedImages = openslide_get_associated_image_names(slidePtr);
disp(associatedImages(:))

% Display all associated images
for k = 1 : length(associatedImages)
    disp(['Displaying: ',associatedImages{k}])
    label = openslide_read_associated_image(slidePtr,associatedImages{k});

    % Display label image
    figure(1+k)
    imshow(label(:,:,2:4))
    set(gcf,'Name',associatedImages{k},'NumberTitle','off')
    [w,h] = openslide_get_associated_image_dimensions(slidePtr,associatedImages{k});
    disp(['width: ',num2str(w)])
    disp(['height: ',num2str(h)])
end

% Close whole-slide image, note that the slidePtr must be removed manually
%openslide_close(slidePtr)
%clear slidePtr

% Unload library
%openslide_unload_library