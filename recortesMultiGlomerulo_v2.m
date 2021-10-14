%% recortesMultiGlomerulo_v2.m %%
%
% This script reads WSI files, generate patches with workable size, and
% save them for subsequent segmentation tasks.
%
% Creation: 30/09/2021
% author: al409458@uji.es | fran_99_cbm@hotmail.com

%%
clear all
close all
clc

%% 1. PATHS INITIALIZATION

% Add folders to path
addpath(genpath('Tiras/'),genpath('Librerias\fordanic-openslide-matlab-240c223'),genpath('Librerias\openslide-win64-20160717'));

% Get current working directory
folder = getCurrentFolder();

% Prepare directories to work with
ims_folder = [folder, filesep, 'Tiras'];
ims_dest = [folder, filesep, 'Recortes'];
ims_subfolders = dir(ims_folder);
ims_subfolders = struct2cell(ims_subfolders(3:end));

%% 2. GATHER IMAGE INFORMATION

missingXmlFiles = [];  % List to save WSI names without an attached XML file.
for i=1:length(ims_subfolders)
    % 1. Save full path to a file folder (CONTAJE ...)
    data{i,1} = [ims_folder,filesep,ims_subfolders{1,i}];
    
    % 2. Save names of all needed files (tif and xml)
    data{i,2} = []; data{i,3} = [];
    tifFiles = dir([data{i,1},filesep,'*.tif']);
    for j=1:length(tifFiles)
        % 2.1. tif files
        data{i,2} = [data{i,2}, string(tifFiles(j).name)];
        
        % 2.2. xml files -> SPECIAL CASE: some *.xml files are missing. A 
        % previous check to avoid errors is needed, using the *.tif filename.
        temp = char(data{i,2}(j));
        temp = [temp(1:end-4),'.xml'];
        xmlFilename = [data{i,1},filesep,temp];
        if isfile(xmlFilename)
           data{i,3} = [data{i,3}, string(temp)];
        else
           warnMessage = [xmlFilename, ' expected, but missing.']; 
           missingXmlFiles = [missingXmlFiles, string(xmlFilename)];
           warning(warnMessage);
           data{i,3} = [data{i,3}, string()];
        end
    end
    
    % 3. Save the target directory for the obtained patches.
    data{i,4} = [ims_dest,  filesep,ims_subfolders{1,i}];
end

%% Load openslide library
openslide_load_library();

%% 3. LOOP FOR PATCH GENERATION
avoidMissingXmlCases = false; % Boolean to control special cases
wSquaredDimension = 3200;     % Patch (window) squared dimension
strideProportion = 1/4;       % Stride proportion based on patch size



% [INFO] Create first waitbar
h1 = waitbar(0, 'Looping over CONTAJE folders...');

[numFolders, ~] = size(data);
% Triple loop: CONTAJE - Slices - Patches
for folder = 1:numFolders
    numSlices = length(data{folder,2});
    
    % [INFO] Create second waitbar
    h2 = waitbar(0, 'Looping over the set of WSI...');
    pos_w1 = get(h1, 'position');
    pos_w2 = [pos_w1(1) pos_w1(2)-pos_w1(4) pos_w1(3) pos_w1(4)];
    set(h2, 'position', pos_w2, 'doublebuffer', 'on');
    
    for slice = 1:numSlices
        
        % When a xml file is missing, no patches will be generated
        if avoidMissingXmlCases && (data{folder,3}(slice) == "")
            continue;
        end
        
        % [INFO] Create third waitbar
        h3 = waitbar(0, 'Saving patches...');
        pos_w2 = get(h2, 'position');
        pos_w3 = [pos_w2(1) pos_w2(2)-pos_w2(4) pos_w2(3) pos_w2(4)];
        set(h3, 'position', pos_w3, 'doublebuffer', 'on');
        
        % 3.1. Pointer to WSI
        WSI = [data{folder,1}, filesep, char(data{folder,2}(slice))];
        slidePtr = openslide_open(WSI);
        
        % 3.2. Find best reduction level
        maxLevel = openslide_get_level_count(slidePtr) - 1;
        [widthWSI, heightWSI] = openslide_get_level_dimensions(slidePtr, 0);
        [ss_factor, windowReducedDim] = getLowerReductionLevel(wSquaredDimension, ...
                    strideProportion, maxLevel);
                
        % 3.3. Generate (or take from disk) thumbnail with desired level
        thumbnail = getThumbnail(slidePtr, ss_factor,  ...
            data{folder,1}, data{folder,2}(slice));
        
        % 3.4. Generate patches and save to Recortes/ folder
        [X, Y] = getPatchesFromThumb(thumbnail, windowReducedDim, ...
            strideProportion, ss_factor);
                
        % Get patches in original size using the collected coordinates
        for i = 1:length(X)
            
            ARGB = openslide_read_region(slidePtr,X(i),Y(i), ...
                wSquaredDimension, wSquaredDimension, 0);
            fig = figure('visible','off');
            imshow(ARGB(:,:,2:4));
            I = getimage(fig);
            
            orgName = char(data{folder,2}(slice));
            destPath = [data{folder,4}, filesep, orgName(1:end-4), ...
                '_x', num2str(X(i)), 'y', num2str(Y(i)),  ...
                's', num2str(wSquaredDimension), '.png'];
            % TODO: Why imwrite last so much saving an image?
            imwrite(I, destPath);
            close(fig);

            % Update third waitbar
            waitbar(i/length(X), h3, sprintf('%d/%d', i, length(X)));
        end
        
        % Update second waitbar
        waitbar(slice/numSlices, h2, sprintf('%d/%d', slice, numSlices));
        
        close(h3);
    end
    
    % Update first waitbar
    waitbar(folder/numFolders, h1, sprintf('%d/%d', folder, numFolders));
    
    close(h2);
end

close(h1);
close all;



%% Alternatively generate individual patch
folder = 1; slice = 2;

WSI = [data{folder,1}, filesep, char(data{folder,2}(slice))];
slidePtr = openslide_open(WSI);

windowProportion = 1/8; 
strideProportion = 1/2; 

[level, wSizeReduced, wSizeFullIm] = findBestReductionLevel(slidePtr, ...
    windowProportion, strideProportion);

ss_factor = 2^level;  
thumbnail = getThumbnail(slidePtr, ss_factor,  ...
    data{folder,1}, data{folder,2}(slice));

[X, Y] = getPatchesFromThumb(thumbnail, wSizeReduced, ...
    strideProportion, ss_factor);
        

i = 42;
x = X(i); y = Y(i);

ARGB = openslide_read_region(slidePtr,x,y, ...
                wSizeFullIm(1), wSizeFullIm(2), 0);
fig = figure('visible','off');
imshow(ARGB(:,:,2:4));
I = getimage(fig);

orgName = char(data{folder,2}(slice));
destPath = [data{folder,4}, filesep, orgName(1:end-4), ...
    '_x', num2str(X(i)), 'y', num2str(Y(i)),  ...
    's', num2str(wSizeFullIm(1)), '-', num2str(wSizeFullIm(2)), '.png'];
imwrite(I, destPath);





