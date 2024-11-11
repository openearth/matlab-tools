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

function data=gdm_read_data_his(fdir_mat,fpath_his,varname,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'tim2',[]);
% addOptional(parin,'layer',[]);
addOptional(parin,'layer',NaN);
addOptional(parin,'station','');
addOptional(parin,'sim_idx','');
addOptional(parin,'structure',NaN); %no SMT
addOptional(parin,'do_load',1); 
addOptional(parin,'depth_average',false); 
addOptional(parin,'elevation',NaN); 
addOptional(parin,'version_date',NaN); 
% addOptional(parin,'tol_t',5/60/24);

parse(parin,varargin{:});

tim=parin.Results.tim;
tim2=parin.Results.tim2;
layer=parin.Results.layer;
station=parin.Results.station;
sim_idx=parin.Results.sim_idx;
structure=parin.Results.structure;
do_load=parin.Results.do_load;
depth_average=parin.Results.depth_average;
elev=parin.Results.elevation;
% tol_t=parin.Results.tol_t;

%% READ
    
% var_str=D3D_var_num2str(varname); %should not be necessary, done outside.

% if ~isempty(layer)
if ~ischar(layer)
    fpath_mat=mat_tmp_name(fdir_mat,varname,'station',station,'layer',layer,'tim',tim,'tim2',tim2);
else
    fpath_mat=mat_tmp_name(fdir_mat,varname,'station',station,'tim',tim,'tim2',tim2);
end
if exist(fpath_mat,'file')==2
    if do_load
        messageOut(NaN,sprintf('Loading mat-file with raw data: %s',fpath_mat));
        load(fpath_mat,'data')
    else
        messageOut(NaN,sprintf('Mat-file with raw data exists: %s',fpath_mat));
        data=NaN;
    end
else
    messageOut(NaN,sprintf('Reading raw data for variable: %s',varname));
    
    OPT.varName=varname; %OPT.varName=var_str; when calling <D3D_var_num2str>
    OPT.layer=layer;
    OPT.t0=tim;
    OPT.tend=tim2;

    switch structure
        case 1
            data=EHY_getmodeldata(fpath_his,station,'d3d',OPT);
        case 2
            data=EHY_getmodeldata(fpath_his,station,'dfm',OPT);
        case 3
            try
                data=EHY_getmodeldata(fpath_his,station,'sobek3',OPT);
            catch
                data=EHY_getmodeldata(fpath_his,station,'sobek3_new',OPT);
            end
        case 4
            his_u=unique(sim_idx);
            nhis=numel(his_u);
            fpath_his_ori=fpath_his; %save the one with '0' for replacing
            for khis=1:nhis
                sim_idx_loc=his_u(khis);
                fpath_his=strrep(fpath_his_ori,[filesep,'0',filesep],[filesep,num2str(sim_idx_loc),filesep]); 
                data_loc=EHY_getmodeldata(fpath_his,station,'dfm',OPT);
                data_loc.val=reshape(data_loc.val,[],1);
                if khis==1
                    data=data_loc;
                else
                    data.val=cat(1,data.val,data_loc.val);
                    data.times=cat(1,data.times,data_loc.times);
                end
            end
        otherwise
            error('do')
    end
    save_check(fpath_mat,'data');
end

%%

%find data at a given elevation
if ~isnan(elev)
   data_z=gdm_read_data_his(fdir_mat,fpath_his,'zcoordinate_c','station',station,'layer',layer,'tim',tim,'tim2',tim2,'structure',structure,'sim_idx',sim_idx);
   data=gdm_data_at_elevation(data,data_z,elev);
end

%depth-average data
if depth_average
    error('Do.')
end

end %function
