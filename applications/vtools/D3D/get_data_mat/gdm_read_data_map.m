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

addOptional(parin,'do_load',1);

parse(parin,varargin{:});

do_load=parin.Results.do_load;

%% CALC

% varname=D3D_var_derived2raw(varname); %I don't think I need it...
var_str=D3D_var_num2str(varname);
fpath_sal=mat_tmp_name(fdir_mat,var_str,varargin{:});

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
        data=gdm_read_data_map_char(fpath_map,varname,varargin{:});
    else
        data=gdm_read_data_map_num(fpath_map,varname,varargin{:});
    end
    save_check(fpath_sal,'data');
end

end %function