function [numid] =getmemberid(elArray,elString)
% GETMEMBERID Returns the id for a string that is a member of an array or
% cell array.
%
%     GETMEMBERID(A,B) where A is an array or cell array and B is an
%     string.

nIn = nargin;
elArray = strtrim(elArray);

if nIn < 2
  error('MATLAB:ISMEMBER:NotEnoughInputs', 'Not enough input arguments.');
elseif nIn > 3
  error('MATLAB:ISMEMBER:TooManyInputs', 'Too many input arguments.');
end

%numid = find(strncmp(elArray,elString,size(elString,2)));
numid = find(strcmp(elArray,elString));

if isempty(numid)
    numid = find(strcmpi(elArray,elString));
    if isempty(numid) 
        warning(['String not found in array:', '''',elString,'''']); 
        numid = false;
    else 
        warning(['Could not find an exact (case-sensitive) match for ', '''',elString,'''']); 
    end
end
