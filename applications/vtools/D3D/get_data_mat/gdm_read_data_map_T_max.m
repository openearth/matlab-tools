%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18086 $
%$Date: 2022-06-01 10:12:31 +0200 (Wed, 01 Jun 2022) $
%$Author: chavarri $
%$Id: create_mat_map_sal_mass_01.m 18086 2022-06-01 08:12:31Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/create_mat_map_sal_mass_01.m $
%
%

function data_var=gdm_read_data_map_T_max(fdir_mat,fpath_map,varname,fpath_sub,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;

%% NUMBER TRACERS

sub=D3D_io_input('read',fpath_sub);

%ATTENTION! I am here assuming that all tracers
%have a devay and a conservative substance and
%that in all cases the age is computed!
% nsub=numel(sub.substance)/2; 

%% CALC
    
%decay rate
idx_dec_rate=find_str_in_cell({sub.parameter.name},{sprintf('RcDecTR%d',var_idx)});
dec_rate=-sub.parameter(idx_dec_rate).value; %positive in input, negative in math sense. 

varname_loc=sprintf('mesh2d_cTR%d',var_idx); %we don't use the name in <sub> because we want to be sure of which is the conservative and which the decaying
data_c=gdm_read_data_map(fdir_mat,fpath_map,varname_loc,'tim',time_dnum); %constituent conservative

varname_loc=sprintf('mesh2d_dTR%d',var_idx); %we don't use the name in <sub> because we want to be sure of which is the conservative and which the decaying
data_d=gdm_read_data_map(fdir_mat,fpath_map,varname_loc,'tim',time_dnum); %constituent conservative

%[concentration,layer]
val_c=squeeze(data_c.val);
val_d=squeeze(data_d.val);

switch varname
    case 'T_da'
        data_zw=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_zw','tim',time_dnum);
        thk=diff(squeeze(data_zw.val),1,2); %m
        thk_tot=sum(thk,2,'omitnan');
        thk_frac=thk./thk_tot;

        val_c=sum(val_c.*thk_frac,2,'omitnan'); 
        val_d=sum(val_d.*thk_frac,2,'omitnan'); 
    case 'T_surf'
        val_c=val_c(:,end);
        val_d=val_d(:,end);
    case 'T_max'
        %nothing to be done, max is applied at the end and does nothing if only one dimentions
    otherwise
        error('not sure what you want to do')
end

bol_c_neg=val_c<=0;
bol_d_neg=val_d<=0; 
bol_d_leq_c=val_d>=val_c;

%filter
val_c(bol_c_neg)=0;
val_d(bol_d_neg)=0;

val_d(bol_d_leq_c)=val_c(bol_d_leq_c);

%rest time
T_sub=log(val_d./val_c)./dec_rate;

T_max=max(T_sub,[],2,'omitnan'); %[faces,1], it only does something if it is 2D-array
        
%             model.tracer_dec.Val(model.tracer_dec.Val<=0)=0;
%             model.tracer.Val(model.tracer.Val<=0)=0;
%             model.tracer_dec.Val(model.tracer_dec.Val>=model.tracer.Val)=model.tracer.Val(model.tracer_dec.Val>=model.tracer.Val);
% 
%             model.restime       = log(model.tracer_dec.Val./model.tracer.Val)./-0.05;
            
%data
data_var.val=T_max;

end %function