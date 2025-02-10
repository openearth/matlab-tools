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
%Replaces the value in an NC variable to the fill value. 
%
%INPUT:
%   - fpath = full path to NC file; [char]
%   - varname = variable name; [char]
%
%OUTPUT:
%

function NC_fillvalue(fpath,varname)

var=ncread(fpath,varname);
fillvalue=ncreadatt(fpath,varname,'_FillValue'); 
ncwrite(fpath,varname,fillvalue*ones(size(var)),1);

end %function