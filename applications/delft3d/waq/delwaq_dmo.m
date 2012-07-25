%DELWAQ_DMO Reads dmo file from delwaq
%
%   [name segments] = DELWAQ_OBS(dmoFile) Read the observation file
%   <obsFile>  and gives back x,y, layer and the id.
%   
%   NOTE: <obsFile> has to be a delwaq *.obs format
%   
%   
%   See also: 

%   Copyright 2011 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   2011-Jul-12 Created by Gaytan-Aguilar
%   email: sandra.gaytan@deltares.com
%--------------------------------------------------------------------------
function [name segments] = delwaq_dmo(dmoFile)

fid = fopen(dmoFile);

n = cell2mat(textscan(fid, '%f'));

for i = 1:n
    aname = textscan(fid, '%s',2);
    aname = aname{1};
    aname = char(aname{1});
    name{i} = aname(2:end); %#ok<*AGROW>
    ns{i} = cell2mat(textscan(fid, '%f',1));
    segments{i} = cell2mat(textscan(fid, '%f',ns));
end

fclose(fid);
