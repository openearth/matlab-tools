%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19717 $
%$Date: 2024-07-31 16:44:38 +0200 (wo, 31 jul 2024) $
%$Author: ottevan $
%$Id: D3D_compare_NC.m 19717 2024-07-31 14:44:38Z ottevan $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_compare_NC.m $
%
%compare netcdf files

function D3D_compare_NC(nc1,nc2,path_log)

%DEBUG
% clear
% clc
% 
% path_sims='c:\Users\chavarri\temporal\210215_testbench_update\01_simulations';
% 
% %updated
% nc1=fullfile(path_sims,'\c01_mc_sediment_transport_Engelund_Hansen\dflowfmoutput\c01_map.nc');
% 
% %updated pli
% % nc1=fullfile(path_sims,'c01_mc_sediment_transport_Engelund_Hansen_pli\dflowfmoutput\c01_map.nc');
% 
% %original in testnch
% % nc1='c:\Users\chavarri\temporal\210208_testbench\01_simulations\c01_mc_sediment_transport_Engelund_Hansen\dflowfmoutput\c01_map.nc';
% 
% %original in SVN
% nc2='c:\Users\chavarri\temporal\210215_testbench_update\01_original_simulations\c01_mc_sediment_transport_Engelund_Hansen\dflowfmoutput\c01_map.nc';
% 
% path_log=fullfile(strrep(nc1,'\dflowfmoutput\c01_map.nc','\log_comparison.txt'));
% 
% END DEBUG

if isnan(path_log)
    fid=NaN;
else
    fid=fopen(path_log,'w');
end

assert (exist(nc1) == 2,sprintf('Cannot find file: %s',nc1))
assert (exist(nc2) == 2,sprintf('Cannot find file: %s',nc2))

messageOut(fid,sprintf('File 1: %s',nc1));
messageOut(fid,sprintf('File 2: %s',nc2));

ncinf_1=ncinfo(nc1);
ncinf_2=ncinfo(nc2);

varname_1={ncinf_1.Variables.Name};
varname_2={ncinf_2.Variables.Name};

varname_all=[varname_1,varname_2];
var_u=unique(varname_all);

nv=numel(var_u);

for kv=1:nv
    messageOut(fid,sprintf('Variable %s:',var_u{1,kv}));
    
    %in file 1
    if isnan(find_str_in_cell(varname_1,var_u(1,kv)))
        isvar_1=false;
        messageOut(fid,'    Does not exist in file 1');
    else
        isvar_1=true;
        var_1=ncread(nc1,var_u{1,kv});
        var_1_c = ncisatt(nc1, var_u{1,kv}, 'coordinates'); 
        if var_1_c
            coords_1 = split(ncreadatt(nc1, var_u{1,kv},'coordinates'), ' ');
            for kc = 1:length(coords_1)
                coords_1_dat{kc} = ncread(nc1,coords_1{kc});
            end
        end
    end
    
    %in file 2
    if isnan(find_str_in_cell(varname_2,var_u(1,kv)))
        isvar_2=false;
        messageOut(fid,'    Does not exist in file 2');
    else
        isvar_2=true;
        var_2=ncread(nc2,var_u{1,kv});
        var_2_c = ncisatt(nc2, var_u{1,kv}, 'coordinates'); 
        if var_2_c
            coords_2 = split(ncreadatt(nc2, var_u{1,kv},'coordinates'), ' ');
            for kc = 1:length(coords_2)
                coords_2_dat{kc} = ncread(nc2,coords_2{kc});
            end
        end
    end
    
    %compare
    if isvar_1 && isvar_2
        if isinteger(var_1)
%             var_norm=var_1-var_2;
            messageOut(fid,'Integer');
        elseif isnumeric(var_1)
            if var_1_c & var_2_c
                coords_1_dat_mat = cell2mat(coords_1_dat);
                coords_2_dat_mat = cell2mat(coords_2_dat);
                [~, idx_1] = sortrows([coords_1_dat_mat, var_1]);
                [~, idx_2] = sortrows([coords_2_dat_mat, var_2]);
                [var_norm, idx] = max(abs(reshape(var_1(idx_1),1,[])-reshape(var_2(idx_2),1,[])));
                assert(coords_1_dat_mat(idx_1(idx),1) == coords_2_dat_mat(idx_2(idx),1));
                assert(coords_1_dat_mat(idx_1(idx),2) == coords_2_dat_mat(idx_2(idx),2));
                if var_norm > 0
                    messageOut(fid,sprintf('    Max. diff. =%e x,y=%f,%f', var_norm, coords_1_dat_mat(idx_1(idx),1), coords_1_dat_mat(idx_1(idx),2) ) );
                else
                    messageOut(fid,sprintf('    Max. diff. =%e', var_norm ));
                end
            else
                var_norm= max(reshape(sort(var_1),1,[])-reshape(sort(var_2),1,[]));
                messageOut(fid,sprintf('    No coordinate information - comparing sorted values'));
                messageOut(fid,sprintf('    Max. diff. =%e', var_norm ));
            end 
        end                    
    end
    
end %kv

if ~isnan(fid)
    fclose(fid);
end

%% CHECK
%  if 1
%      close all
% % varname='mesh1d_flowelem_bl';
% % varname='mesh1d_mor_bl';
% % varname='mesh1d_s1';
% varname='mesh1d_ucmag';
% % varname='mesh1d_q1';
% % varname='mesh1d_czs';
% % varname='mesh1d_czu';
% 
% var_1=ncread(nc1,varname);
% var_2=ncread(nc2,varname);
% 
% % var_1-var_2
% idx_1=1:10;
% % idx_1=1:40;
% var_p1=var_1(idx_1,:);
% var_p2=var_2(idx_1,:);
% figure
% hold on
% han_1=plot(var_p1,'-ok');
% % figure
% han_2=plot(var_p2,'--*r');
% legend([han_1(1),han_2(1)],{'1','2'})
% 
% var_diff=var_p1-var_p2;
% norm(var_diff)
% 
% %%
% figure
% % plot(squeeze(var_1))
% plot(squeeze(var_2))

%  end
% end

end %D3D_compare_NC
