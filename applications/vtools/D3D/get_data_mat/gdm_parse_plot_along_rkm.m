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

function flg_loc=gdm_parse_plot_along_rkm(flg_loc)

if isfield(flg_loc,'do_plot_along_rkm')==0
    flg_loc.do_plot_along_rkm=0;
end
if flg_loc.do_plot_along_rkm
    if ~isfield(flg_loc,'fpath_rkm_plot_along')
        error('Provide rkm file')
    else
        if ~exist(flg_loc.fpath_rkm_plot_along,'file')
            error('File with rkm does not exist')
        else
            fid=fopen(flg_loc.fpath_rkm_plot_along,'r');
            flg_loc.rkm_file=textscan(fid,'%f %f %s %f','headerlines',1,'delimiter',',');
            fclose(fid);
        end
    end

    %order of analysis    
    nrkm=size(flg_loc.rkm_file{1,1},1);
    flg_loc.krkm_v=gdm_kt_v(flg_loc,nrkm);

end

if isfield(flg_loc,'do_rkm_disp')==0
    flg_loc.do_rkm_disp=0;
end
if flg_loc.do_rkm_disp
    if ~isfield(flg_loc,'fpath_rkm_disp') 
        error('Provide rkm file')
    else
        if ~exist(flg_loc.fpath_rkm_disp,'file')
            error('File with rkm does not exist')
        end
    end
end

if isfield(flg_loc,'rkm_tol_x')==0
    flg_loc.rkm_tol_x=1000;
end

if isfield(flg_loc,'rkm_tol_y')==0
    flg_loc.rkm_tol_y=1000;
end

end %function