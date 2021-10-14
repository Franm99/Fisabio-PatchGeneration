function [X, Y] = getPatchesFromThumb(im, wsize, strideProportion, ss_factor)
% GETPATCHESFROMTHUMB Get patches coordinates, in original resolution,
% from the corresponding thumbnail of a WSI.
%
% [X, Y] = getPatchesFromThumb(im, wsize, stride, ss_factor)
%
% INPUT ARGUMENTS
% im                        - Thumbnail image
% wsize = [wWidth, wHeight] - Window dimensions (width, height)
% strideProportion          - Stride proportion between windows 
% ss_factor                 - Subsampling factor
%
% OUPUT ARGUMENTS
% [X, Y]                    - Lists of X and Y coordinates of the
%                             top-left corner from every useful patch
%
   
    X = []; Y = []; % Output initialization
    
    [h, w, ~] = size(im);
    
    stride = wsize * strideProportion;
    
%     f1 = figure; imshow(im); hold on;  % DEBUG
    for r = 0 : wsize - stride : h
        if r + wsize > h
            continue;
        end
        for c = 0 : wsize - stride : w
            if c + wsize > w
                continue;
            end
            
            patch = im(r+1:r+wsize, c+1:c+wsize, :);

%             isTissue = isTissuePatch(patch);
            isTissue = true;
            isCortex = isCortexPatch(patch);
%             isCortex = true;
            
            if isTissue && isCortex  % save patch coordinates
                R = r * ss_factor; C = c * ss_factor;
                X = [X C]; Y = [Y R];
%                 rectangle('Position', [c+1, r+1, wsize, wsize], ...
%                           'EdgeColor', 'g'); % debug                
            end
        end   
    end
