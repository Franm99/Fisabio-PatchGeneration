function [thumbnail] = getThumbnail(slidePtr, ss_factor, folder, name)
% GETTHUMBNAIL generates (if non existing) a thumbnail in *.png format for 
% a given WSI and subsampling factor.
%
% [thumbnail] = getThumbnail(slidePtr, ss_factor, folder, name)
%
% INPUT ARGUMENTS
% slidePtr                  - Pointer to current WSI.
% ss_factor                 - Desired sub-sampling factor
% folder                    - Current WSI source folder.
% name                      - Current WSI original name.
%
% OUPUT ARGUMENTS
% thumbnail                 - Resulting thumbnail image (RGB format).
%

level = openslide_get_best_level_for_downsample(slidePtr, ss_factor);

% Get dimensions of the desired subsampled version
[widthSubsampled, heightSubsampled] = openslide_get_level_dimensions(slidePtr, level);

% The function to read the region can be used to generate a subsampled
% version of the whole-slide image, indicating:
% - The desired (xPos, yPos) as the top-left corner pixel coordinates: (0,0).
% - The width and height of the region as the full size of the REDUCED version.
% - The level associated with the desired subsampling factor.
ARGB = openslide_read_region(slidePtr,0,0,widthSubsampled,heightSubsampled,level);

name = char(name);
destName = [name(1:end-4), '_thumbnail.png'];
destPath = [folder, filesep, destName];

overwrite = false;
if isfile(destPath)
    thumbnail = imread(destPath);
    [h, w, ~] = size(thumbnail);
    if (w ~= widthSubsampled) || (h ~= heightSubsampled)
        delete(destPath);
        overwrite = true;
    end
else
    thumbnail = ARGB(:,:,2:4);
end

if overwrite
    fig = figure('visible','off');
    imshow(thumbnail);
    I = getimage(fig);
    imwrite(I, destPath);
    close(fig);
    thumbnail = ARGB(:,:,2:4);
end

