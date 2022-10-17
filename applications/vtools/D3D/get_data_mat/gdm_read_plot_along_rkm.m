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

function in_p=gdm_read_plot_along_rkm(in_p,flg_loc)

if flg_loc.do_rkm_disp
    fid=fopen(flg_loc.fpath_rkm_disp,'r');
    rkm_file=textscan(fid,'%f %f %s %f','headerlines',1,'delimiter',',');
    fclose(fid);
    rkm_file{1,3}=cellfun(@(X)strrep(X,'_','\_'),rkm_file{1,3},'UniformOutput',false);
    in_p.rkm=rkm_file;
end

end %function