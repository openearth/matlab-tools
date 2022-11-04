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

function fdir_loc=D3D_SMT_dir_output_loc(fdir_output,kf)

structure=D3D_SMT_structure(fdir_output);

if structure==4
    fdir_loc=fullfile(fdir_output,num2str(kf));
else
    output_time=D3D_SMTD3D4_sort_output(fdir_output); %should be moved outside the loop
    fdir_loc=fullfile(fdir_output,sprintf('%d.min',output_time(kf+1))); %<nf> is not the number of files but the integer in SMTFM. Hence, number of files is <nf+1>
end

end