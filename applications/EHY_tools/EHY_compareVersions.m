function result = EHY_compareVersions(version1, version2)
%% EHY_compareVersions
% Compare two version numbers specified in the format "x.y.z"
% and return true if the first version number is larger than the second version
% number. Returns false otherwise.
%
% Example usage: result = EHY_compareVersions('1.2.93', '1.1.200');  [ TRUE ]

% Split the version strings into their constituent parts
parts1 = strsplit(version1, '.');
parts2 = strsplit(version2, '.');

% Convert the parts to numbers
numParts1 = str2double(parts1);
numParts2 = str2double(parts2);

% Compare the versions
if numParts1(1) > numParts2(1) || ...
        (numParts1(1) == numParts2(1) && numParts1(2) > numParts2(2)) || ...
        (numParts1(1) == numParts2(1) && numParts1(2) == numParts2(2) && numParts1(3) > numParts2(3))
    result = true;
else
    result = false;
end
