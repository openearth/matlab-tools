function [d] = readGridData(datatype, name, year, soundingID)
%READGRIDDATA   transforms processed data to proper meta data format
%
% input:
%   datatype
%   name
%   year
%   soundingID
%
%   See also readTransectData, readLineData, readPointData

% -------------------------------------------------------------
% Copyright (c) WL|Delft Hydraulics 2004-2008 FOR INTERNAL USE ONLY
% Version:      Version 1.3, Februari 2008 (Version 1.0, February 2004)
% By:           <M. van Koningsveld (email: mark.vankoningsveld@wldelft.nl>
% -------------------------------------------------------------

% datatype -> number or string
% name -> 
% year 
% soundingID
switch nargin
    case 0
        return
    case 1
        if ~isempty(str2num(datatype)) %#ok<ST2NM>
            % datatype number
        else
            temp=DBGetTableEntry('grid','datatypeinfo',datatype);
        end
    case 2
        if ~isempty(str2num(datatype)) %#ok<ST2NM>
            temp=DBGetTableEntry('grid','datatype',datatype,'name',name);
        else
            temp=DBGetTableEntry('grid','datatypeinfo',datatype,'name',name);
        end
    case 3
        if ~isempty(str2num(datatype)) %#ok<ST2NM>
            temp=DBGetTableEntry('grid','datatype',datatype,'name',name,'year',year);
        else
            temp=DBGetTableEntry('grid','datatypeinfo',datatype,'name',name,'year',year);
        end
    case 4
        if ~isempty(str2num(datatype)) %#ok<ST2NM>
            temp=DBGetTableEntry('grid','datatype',datatype,'name',name,'year',year,'soundingID',soundingID);
        else
            temp=DBGetTableEntry('grid','datatypeinfo',datatype,'name',name,'year',year,'soundingID',soundingID);
        end
end

d=rearrangeData(temp);

% d.fielddata.interpx -> vector
% d.fielddata.interpy -> vector
% d.X
% d.Y
% d.Z

function d = rearrangeData(temp)
d=temp;

if size(d.fielddata.interpx,1)==1 & size(d.fielddata.interpx,2)~=1 %#ok<AND2>
    d.fielddata.interpx = repmat(d.fielddata.interpx,size(d.fielddata.interpz,1),1);
end
if size(d.fielddata.interpy,2)==1 & size(d.fielddata.interpy,1)~=1 %#ok<AND2>
    d.fielddata.interpy = repmat(d.fielddata.interpy,1,size(d.fielddata.interpz,2));
end

try d.X=[d.fielddata.interpx]; end
try d.X(d.X==-999.99)=nan;     end
try d.Y=[d.fielddata.interpy]; end
try d.Y(d.Y==-999.99)=nan;     end
try d.Z=[d.fielddata.interpz]; end
try d.Z(d.Z==-999.99)=nan;     end
