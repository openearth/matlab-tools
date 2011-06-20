function [VSNEW,ErrMsg]=vs_put(varargin)
%VS_PUT Write data to a NEFIS file.
%   NewNFStruct = VS_PUT(NFStruct, ...
%      'GroupName',GroupIndex,'ElementName',ElementIndex,Data)
%
%   NewNFStruct = VS_PUT(NFStruct, 'GroupName', [], ...
%      AttributeName1,Value1,AttributeName2,Value2, ...)
%
%   Example 1
%      F = vs_use('trim-xxx.dat','trim-xxx.def');
%      vs_put(F,'map-series',{1:5},'S1',{1:30 1:20},X);
%      % Save the contents of the 5x30x20 matrix X containing the data of
%      % the first 5 time steps (dimension of map-series group) and first
%      % 30x20 values of the water level stored in element S1 of group
%      % map-series.
%
%   Example 2
%      F = vs_use('trim-xxx.dat','trim-xxx.def');
%      vs_put(F,'map-series',[],'MyLabel','Some text','MyValue',123);
%      % Save one character and one integer attribute to the map-series
%      group.
%
%   See also VS_USE, VS_INI, VS_DEF.

%   Copyright 2000-2009 Deltares, the Netherlands
%   http://www.delftsoftware.com
%   $Id$

% if ~all dims of Elm, read -> write
% if ~all dims of Grp, var.grp dim may be extended: based on dim spec!
% if all dims of Grp, var.grp dim may be extended: based on Data!
% size(Data) should match spec/nonspec. sizes (except var.dim.).
% var.dim.size(Data) should equal to dim spec if var.dim spec
% var.dim.size(Data) should be at least current var.dim.size.


error(sprintf('Missing p-file for %s, contact supplier of code.',mfilename))
