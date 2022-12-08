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

function fdir_loc=D3D_SMT_dir_output_loc(fdir_output,kf)

structure=D3D_SMT_structure(fdir_output);

if structure==4
    fdir_loc=fullfile(fdir_output,num2str(kf));
else
    output_time=D3D_SMTD3D4_sort_output(fdir_output); %should be moved outside the loop
    fdir_loc=fullfile(fdir_output,sprintf('%d.min',output_time(kf+1))); %<nf> is not the number of files but the integer in SMTFM. Hence, number of files is <nf+1>
end

end