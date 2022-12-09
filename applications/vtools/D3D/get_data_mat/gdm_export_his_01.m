%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18488 $
%$Date: 2022-10-27 14:13:26 +0200 (Thu, 27 Oct 2022) $
%$Author: chavarri $
%$Id: create_mat_his_01.m 18488 2022-10-27 12:13:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_his_01.m $
%
%

function gdm_export_his_01(fid_log,flg_loc,fpath_mat_tmp,time_dtime)

%% PARSE

if isfield(flg_loc,'export')==0
    flg_loc.export=0;
end
 
%% CALC

%% txt

if any(flg_loc.export==1)
    load(fpath_mat_tmp,'data')
    fpath_txt_tmp=strrep(fpath_mat_tmp,'.mat','.txt');
    if exist(fpath_txt_tmp,'file')~=2 || flg_loc.overwrite==1
        matwrite=[seconds(time_dtime-time_dtime(1)),data];
%         writematrix(matwrite,fpath_txt_tmp); %fast but without control
        messageOut(fid_log,sprintf('Start exporting: %s',fpath_txt_tmp));
        write_2DMatrix(fpath_txt_tmp,matwrite,'check_existing',0,'delimiter',',');
        messageOut(fid_log,sprintf('Start exporting: %s',fpath_txt_tmp));
    end
end

end %function