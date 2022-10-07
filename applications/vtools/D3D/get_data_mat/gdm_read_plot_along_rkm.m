%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18390 $
%$Date: 2022-09-27 12:07:53 +0200 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: plot_map_2DH_01.m 18390 2022-09-27 10:07:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/plot_map_2DH_01.m $
%
%

function in_p=gdm_read_plot_along_rkm(in_p,flg_loc)

if flg_loc.do_rkm_disp
    fid=fopen(flg_loc.fpath_rkm_disp,'r');
    rkm_file=textscan(fid,'%f %f %s %f','headerlines',1,'delimiter',',');
    fclose(fid);
    rkm_file{1,3}=cellfun(@(X)strrep(X,'_','\_'),rkm_file{1,3},'UniformOutput',false);
    in_p.rkm=rkm_file;
end

end %function