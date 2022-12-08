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
%

function structure=D3D_SMT_structure(fdir_output)

dire=dir(fdir_output);
ndir=numel(dire);
for kdir=1:ndir
    if strcmp(dire(kdir).name,'.') || strcmp(dire(kdir).name,'..'); continue; end
    if dire(kdir).isdir==0 %in output folders of SMT there is no file
        structure=4;
    elseif strfind(dire(kdir).name,'min')
        structure=5;
    else
        structure=4;
    end 
    break
end

end %function