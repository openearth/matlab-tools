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
%Output is a structure with fields, at least, `val` and `times`. 

function data=gdm_read_data_his_simdef(fdir_mat,simdef,var_id,flags)

%% PARSE

%% CALC

fpath_his=simdef.file.his;

switch var_id
    case 'vpara'
        data=gdm_read_data_his_vpara(fdir_mat,fpath_his,flags);
        data.val=data.v_para;
    case 'vperp'
        data=gdm_read_data_his_vpara(fdir_mat,fpath_his,flags);
        data.val=data.v_perp;
    case 'scum'
        data=gdm_read_data_his_scum(simdef,flags);
    otherwise
        data=gdm_read_data_his(fdir_mat,fpath_his,var_id,flags);
end

end %function

%%
%% FUNCTIONS
%%

function data=gdm_read_data_his_scum(simdef,flags)

%% PARSE


%% CALC

fpath_his=simdef.file.his;
fdir_mat=simdef.file.fdir_mat;

nf=numel(gdm_read_dk(simdef));
flags.cumulative=true;
val_all=[];
for kf=1:nf
    varname=sprintf('cross_section_bedload_sediment_transport_Fraction%02d',kf);
    data=gdm_read_data_his(fdir_mat,fpath_his,varname,flags);
    %in `data.val` first is time, second is station, but we are only loading one station, so second dimension is 1.
    %we save fraction in second dimension.
    val_all=cat(2,val_all,data.val); 
end

data.val=val_all;
%change name of dimension

%% DEBUG

% figure
% hold on
% plot(data.times,data.val,'-o')

end %function