function block_data = squeeze_block(block_data,variableCol,varargin)
%squeeze_block   squeezes out data flagged as 999999999999
%
%    block_data = donar.squeeze_block(block_data,variableCol)
%
% checks whether column variableCol from block_data = donar.read()
% has DONAR nodatavalue value 999999999999, and squeezes it out, so
% block_data becomes smaller in the 1st dimension. To keep the data
% in, set keyword 'nodatavalue' to nan instead of default [].
%
%See also: open, read

OPT.nodatavalue = [];

OPT = setproperty(OPT,varargin);

if isempty(OPT.nodatavalue)
   block_data(block_data(:,variableCol)> 999999999999 - .1, :) = [];
else
   block_data(block_data(:,variableCol)> 999999999999 - .1, :) = OPT.nodatavalue;
end
