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