%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18462 $
%$Date: 2022-10-21 13:10:57 +0200 (Fri, 21 Oct 2022) $
%$Author: ottevan $
%$Id: D3D_results_time_wrap.m 18462 2022-10-21 11:10:57Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_results_time_wrap.m $
%
%

function nf=D3D_SMT_nf(fdir_output)

dire=dir(fdir_output);

%structure
structure=D3D_SMT_structure(fdir_output);

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

if structure==4
    nf=length(cell2mat(regexp({dire.name}, '[0-9]+')))-1; %already the number of the files, which start at 0
else
    output_time=D3D_SMTD3D4_sort_output(fdir_output);
    nf=numel(output_time)-1; %<nf> is not the number of files but the integer in SMTFM. Hence, number of files is <nf+1>
end

end %function