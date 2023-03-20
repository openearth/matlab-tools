%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%
%I do not know who made this function first but I guess Bert Jaggers. I have
%adapted it a bit. 
%
%convert a shape file to a struct. 

function [outputvar] = shp2struct(fpath,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'read_val',false);
addOptional(parin,'xy_only',false);

parse(parin,varargin{:});

read_val=parin.Results.read_val;
xy_only=parin.Results.xy_only;

if read_val && xy_only
    warning('Conflicting input flags. I am reading values (i.e., not only xy)')
end

%% CALC

if exist(fpath,'file')~=2
    error('file does not exist: %s',fpath)
end
SHP=qpfopen(fpath);
Q=qpread(SHP);
objstr = {Q.Name};
outputvar.xy=qpread(SHP,objstr{1},'griddata');
if read_val
    for i=2:length(objstr)
      outputvar.val{i-1}=qpread(SHP,objstr{i},'data');
    end
end

if xy_only
    aux=polcell2nan(outputvar.xy.XY);
    outputvar=aux(:,1:2);
end

end %function