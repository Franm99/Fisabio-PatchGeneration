function [b] = isCortexPatch(im)
% ISCORTEXPATCH checks if a WSI patch corresponds either to Cortex or
% Medular part. Glomeruli can be found in the Cortex part.
%
% [b] = isCortexPatch(im)
%
% INPUT ARGUMENTS
% im                        - Patch to check
%
% OUTPUT ARGUMENTS
% b                         - true if Cortex, false if Medular
%

b = false;

% Working on HSV format
im_hsv = rgb2hsv(im);
S = im_hsv(:,:,2);

[counts, ~] = imhist(S);
counts = counts(4:end/2);
[countsOrdered, ~] = sort(counts);
medVal = median(countsOrdered);

if medVal >= 10
    b = true;
end

end

