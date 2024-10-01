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

flg_loc=isfield_default(flg_loc,'do_plot_along_rkm',0);
flg_loc=isfield_default(flg_loc,'rkm_tol_x',1000);
flg_loc=isfield_default(flg_loc,'rkm_tol_y',1000);

if flg_loc.do_plot_along_rkm
    if ~isfield(flg_loc,'fpath_rkm_plot_along')
        error('Provide rkm file')
    else
        if ~exist(flg_loc.fpath_rkm_plot_along,'file')
            error('File with rkm does not exist')
        else
            rkm_file=gdm_read_rkm_file(flg_loc.fpath_rkm_plot_along);
        end
    end

    %order of analysis    
    nrkm=size(rkm_file{1,1},1);
    flg_loc.krkm_v=gdm_kt_v(flg_loc,nrkm);

    flg_loc.xlims=NaN(nrkm,2);
    flg_loc.ylimss=NaN(nrkm,2);
    for krkm=1:nrkm
        flg_loc.xlims(krkm,:)=rkm_file{1,1}(krkm)+[-flg_loc.rkm_tol_x,+flg_loc.rkm_tol_x];
        flg_loc.ylims(krkm,:)=rkm_file{1,2}(krkm)+[-flg_loc.rkm_tol_y,+flg_loc.rkm_tol_y];
    end

end

flg_loc=isfield_default(flg_loc,'do_rkm_disp',0);
if flg_loc.do_rkm_disp
    if ~isfield(flg_loc,'fpath_rkm_disp') 
        error('Provide rkm file')
    else
        if ~exist(flg_loc.fpath_rkm_disp,'file')
            error('File with rkm does not exist')
        else
            flg_loc.rkm_file_disp=gdm_read_rkm_file(flg_loc.fpath_rkm_disp);
        end
    end
else
    flg_loc.rkm_file_disp='';
end

end %function