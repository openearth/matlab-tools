function addGarretMunk
gmPath = 'S:\FREE\matlabToolboxes\GarrettMunkMatlab-master';
mixingPath = 'S:\FREE\matlabToolboxes\mixing_library';
if ~exist('Gm76Params','file')
    addSubPath(gmPath);
end
if ~exist('sw_f','file')
     addSubPath(mixingPath)
end
end


   