function [b] = isTissuePatch(im)
% ISTISSUEPATCH checks if a WSI patch corresponds either to Tissue or
% Non-Tissue part. Glomeruli can be found in the Tissue part.
%
% [b] = isTissuePatch(im)
%
% INPUT ARGUMENTS
% im                        - Patch to check
%
% OUTPUT ARGUMENTS
% b                         - true if Tissue, false if Non-Tissue
%

b = false;

[counts, ~] = imhist(im);
[countsOrdered, ~] = sort(counts);
medVal = median(countsOrdered);

if medVal >= 10
    b = true;
end

end

