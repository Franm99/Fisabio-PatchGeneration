function [ss_factor, windowReducedDim] = getLowerReductionLevel(wDimension, strideProportion, maxLevel)
% GETLOWERREDUCTIONLEVEL gets the lower downsampling factor (level) for a
% WSI so whole divisions will take place in reduction, using powers of 2.
%
% [ss_factor, windowReducedDim] = getLowerReductionLevel(wDimension, strideProportion, maxLevel)
%
% INPUT ARGUMENTS
% wDimension                - Patch window dimension, in original
%                       resolution. It is supposed to be squared.
% strideProportion          - Stride proportion factor related to the patch
%                       dimensions. For instance, if wDimension is 20x20, a 
%                       stride proportion of 1/4 corresponds to 5px stride,
%                       starting from the ending of the last patch.
% maxLevel                  - Maximum reduction level supported by the
%                       current WSL pointer.
%
% OUPUT ARGUMENTS
% ss_factor                 - Subsampling factor = 2 ^ level
% windowReducedDim          - Resulting reduced patch dimensions.
%

for level = maxLevel : -1 : 1
    ss_factor = 2 ^ level;
    windowReducedDim = double(wDimension) / double(ss_factor);
    stride = windowReducedDim * double(strideProportion);
 
    if (floor(stride) == stride)
        break;
    end
end

end

