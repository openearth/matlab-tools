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

function data=gdm_load_snapped(fid_log,fdir_mat,simdef,tag,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'do_load',1);

parse(parin,varargin{:});

do_load=parin.Results.do_load;

%% PATHS

fname_fxw=sprintf('%s_snapped.mat',tag);
fpath_mat_fxw=fullfile(fdir_mat,fname_fxw);

%% LOAD 

if exist(fpath_mat_fxw,'file')==2
    if do_load
        messageOut(fid_log,sprintf('%s snapped mat-file exist. Loading.',tag))
        load(fpath_mat_fxw,'data')
    else
        messageOut(fid_log,'Fxw mat-file exist.')
    end
    return
end

%% READ

messageOut(fid_log,sprintf('%s snapped mat-file does not exist. Reading.',tag))

data=D3D_read_snapped(simdef,tag,'xy_only',1,'read_val',0);

save_check(fpath_mat_fxw,'data'); 

end %function