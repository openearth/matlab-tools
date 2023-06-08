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
%Read text from nc-file and put in cell array

function c=NC_read_text(fpath,varname)

aux=ncread(fpath,varname)';
nobs_a=size(aux,1);
c=cell(nobs_a,1);
for k1=1:nobs_a
    c{k1,1}=deblank(aux(k1,:));
end

end %function