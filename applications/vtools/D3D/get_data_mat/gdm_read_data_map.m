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

function data=gdm_read_data_map(fdir_mat,fpath_map,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'do_load',1);
addOptional(parin,'tol_t',5/60/24);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'branch','');
addOptional(parin,'depth_average',false);
addOptional(parin,'elevation',[]);
% addOptional(parin,'bed_layers',[]); We use <layer> for flow and sediment

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
layer=parin.Results.layer;
do_load=parin.Results.do_load;
tol_t=parin.Results.tol_t;
idx_branch=parin.Results.idx_branch;
branch=parin.Results.branch;
depth_average=parin.Results.depth_average;
elevation=parin.Results.elevation;
% bed_layers=parin.Results.bed_layers;

%% CALC

% varname=D3D_var_derived2raw(varname); %I don't think I need it...
[ismor,is1d]=D3D_is(fpath_map);
[var_str,varname_changed]=D3D_var_num2str(varname,'is1d',is1d,'ismor',ismor); %in the call in <create_mat_map_2DH_01> we already change the name. Here we only need the save name. Otherwise we need to pass <simdef.D3D.structure>
% fpath_sal=mat_tmp_name(fdir_mat,var_str,'tim',time_dnum,'var_idx',var_idx,'branch',branch);
fpath_sal=mat_tmp_name(fdir_mat,var_str,'tim',time_dnum,'branch',branch); %`var_idx` cannot be in the name because it is not saved as such. 

if exist(fpath_sal,'file')==2
    if do_load
        messageOut(NaN,sprintf('Loading mat-file with raw data: %s',fpath_sal));
        load(fpath_sal,'data')
    else
        messageOut(NaN,sprintf('Mat-file with raw data exists: %s',fpath_sal));
        data=NaN;
    end
else
    messageOut(NaN,sprintf('Reading raw data for variable: %s',var_str));
    if isempty(idx_branch) %2D
        if ischar(varname)
            data=gdm_read_data_map_char(fpath_map,varname,'tim',time_dnum,'tol_t',tol_t);%,'bed_layers',bed_layers);
        else
            %outdated?
            data=gdm_read_data_map_num(fpath_map,varname,'tim',time_dnum);
        end
    else %1D
        [~,~,~,~,~,idx_tim]=D3D_time_dnum(fpath_map,time_dnum,'fdir_mat',fdir_mat);
        val=gdm_read_data_map_1D(fpath_map,var_str,idx_branch,idx_tim);
        data.val=val;
    end
    save_check(fpath_sal,'data');
end

%% layer

%layer
if ~isempty(layer)
    idx_f=D3D_search_index_layer(data);
    data.val=submatrix(data.val,idx_f,layer);
end

%get desired fractions
if ~isempty(var_idx)
    idx_f=D3D_search_index_fraction(data); 
    data.val=submatrix(data.val,idx_f,var_idx); %take submatrix along dimension
end

%depth averaged
if depth_average
    data=gdm_depth_average(data,fdir_mat,fpath_map,time_dnum);
end

%elevation
if ~isempty(elevation)
    data=gdm_2DH_elevation(data,fdir_mat,fpath_map,time_dnum,elevation);
end

end %function

%%

function  data=gdm_depth_average(data,fdir_mat,fpath_map,time_dnum)

data_zw=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_zw','tim',time_dnum); 
%values
%     idx_layer=D3D_search_index_layer(data);
idx_time=D3D_search_index_in_dimension(data,'time');
val=submatrix(data.val,idx_time,1); 
%elevation
%assumption. we should read it, but if 'mesh2d_flowelem_zw' is constructed by hand, I did not add it. 
idx_layer=3;
%     idx_face=2; 
%     idx_time=1;
thk=diff(data_zw.val,1,idx_layer); %m
if any(size(thk)~=size(val))
    %we should first check that `idx_#` of `val` and `zw` match and then permute if necessary.
    error('Dimensions do not agree. You have to permute them to be correct.')
end
thk_tot=sum(thk,idx_layer,'omitnan');
val_da=sum(val.*thk,idx_layer,'omitnan')./thk_tot;
data.val=val_da;
data.dimensions='[time,mesh2d_nFaces]';

end %function

%%

function data=gdm_2DH_elevation(data,fdir_mat,fpath_map,time_dnum,elevation)

data_zc=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_zc','tim',time_dnum); 
    
%2DO: there should be a thorough check on dimensions and permute if necessary
idx_faces=D3D_search_index_in_dimension(data,'mesh2d_nFaces');

z_sim=squeeze(data_zc.val);
v_sim=squeeze(data.val);

np=size(data.val,idx_faces);
v_sim_atmea=NaN(1,np);
for kp=1:np
    x=z_sim(kp,:);
    y=v_sim(kp,:);
    bol_n=isnan(x);
    if ~all(bol_n)
        z=interp1(x(~bol_n),y(~bol_n),elevation,'linear');
        v_sim_atmea(1,kp)=z;
    end
%     fprintf('%4.2f %% \n',kp/np*100);
end

data.val=v_sim_atmea;
data.dimensions='[time,mesh2d_nFaces]';

end %function