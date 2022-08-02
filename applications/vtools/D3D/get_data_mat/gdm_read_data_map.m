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

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'var_idx',[]);
addOptional(parin,'layer',[]);
addOptional(parin,'do_load',1);
addOptional(parin,'tol_t',5/60/24);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
var_idx=parin.Results.var_idx;
layer=parin.Results.layer;
do_load=parin.Results.do_load;
tol_t=parin.Results.tol_t;

%% CALC

% varname=D3D_var_derived2raw(varname); %I don't think I need it...
var_str=D3D_var_num2str(varname);
fpath_sal=mat_tmp_name(fdir_mat,var_str,'tim',time_dnum,'var_idx',var_idx);

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
    if ischar(varname)
        data=gdm_read_data_map_char(fpath_map,varname,'tim',time_dnum,'var_idx',var_idx,'tol_t',tol_t);
    else
        data=gdm_read_data_map_num(fpath_map,varname,'tim',time_dnum);
    end
    save_check(fpath_sal,'data');
end

%% layer

if ~isempty(layer)
   data.val=data.val(:,layer);
end

end %function