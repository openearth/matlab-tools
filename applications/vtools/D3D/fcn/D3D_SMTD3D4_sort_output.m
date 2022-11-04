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

function tim_dir=D3D_SMTD3D4_sort_output(fdir_output)

%sort output folders
dire_out=dir(fdir_output);
nf=numel(dire_out);
tim_dir=[];
for kf=1:nf
    if ~dire_out(kf).isdir; continue; end
    if strcmp(dire_out(kf).name,'.') || strcmp(dire_out(kf).name,'..'); continue; end
    tim_dir=cat(1,tim_dir,str2double(strrep(dire_out(kf).name,'.min','')));
end
tim_dir=sort(tim_dir);

end