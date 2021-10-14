function [folder] = getCurrentFolder()
    [folder,~,~] = fileparts(mfilename('fullpath'));
end

