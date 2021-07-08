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

function [names,names_clean]=D3D_clean_group_names(mdu)

names  = fieldnames(mdu);

%when writing a file read with delft3d_io_sed, the block names have a number. 
%Here we remove it
ngroup=numel(names);
names_clean=cell(ngroup,1);
for kb=1:ngroup
    tok=regexp(names{kb,1},'\d','split');
    names_clean{kb,1}=tok{1,1};
end %kb

end %function