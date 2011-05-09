function [X,Success]=vs_let(varargin)
%VS_LET Read one or more elements from a NEFIS file.
%   X=VS_LET(NFStruct,'GroupName',GroupIndex,'ElementName',ElementIndex)
%   reads the data from the specified element (only specified element
%   indices) in the specified group (only speicified group indices) from
%   the NEFIS file specified by NFStruct into an array X. Any argument or
%   combination of arguments may be missing. During reading a wait bar will
%   show the progress.
%
%   If the file (NFStruct) is not specified, the NEFIS that was last opened
%   by VS_USE will be used to read the data. A file structure NFStruct can
%   be obtained as output argument from the function VS_USE.
%
%   If the group index (GroupIndex) is missing the element will be returned
%   for all group indices. If present the group index should be a 1xNGD
%   cell array where NGD equals the number of group dimensions of the
%   selected group. Each cell should contain the indices of the group
%   dimension concerned to be read.
%
%   If the element index (ElementIndex) is missing the whole element will
%   be returned. If present the element index should be a 1xNED cell
%   array where NED equals the number of element dimensions of the selected
%   element. Each cell should contain the indices of the element dimension
%   concerned to be read.
%
%   If a group or element name is missing or invalid, or if an index is
%   invalid a graphical user interface will appear that allows you to
%   correct your selection. If '*' is specified for the ElementName, all
%   elements in the specified group will be read and the data is returned
%   in a structure with fieldnames that mirror the element names; the
%   ElementIndex is ignored in that case.
%
%   X=VS_LET(...,'quiet') reads the specified values into X without showing
%   the wait bar.
%
%   X=VS_LET(...,'debug') write debug information to a file while reading
%   the data.
%
%   [X,Success]=VS_LET(...) returns as second argument whether the data was
%   read succesfully.
%
%   Example
%      F = vs_use('trim-xxx.dat','trim-xxx.def');
%      X = vs_let(F,'map-series',{1:5},'S1',{1:30 1:20});
%      % returns a 5x30x20 matrix containing the data of the first 5 time
%      % steps (dimension of map-series group) and first 30x20 values of
%      % the water level stored in element S1 of group map-series.
%      % This is more efficiently than reading all data and then indexing:
%      % AllX = vs_let(F,'map-series','S1');
%      % X = AllX(1:5,1:30,1:20);
%
%   See also VS_USE, VS_DISP, VS_GET, VS_DIFF, VS_FIND, VS_TYPE.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
