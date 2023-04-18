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

function fxw=gdm_load_fxw(fid_log,fdir_mat,varargin)

%%

parin=inputParser;

addOptional(parin,'do_load',1);
% addOptional(parin,'dim',2);
addOptional(parin,'fpath_fxw','');
addOptional(parin,'fpath_mat_fxw',fullfile(fdir_mat,'fxw.mat'));

parse(parin,varargin{:});

do_load=parin.Results.do_load;
% dim=parin.Results.dim;
fpath_fxw=parin.Results.fpath_fxw;
fpath_mat_fxw=parin.Results.fpath_mat_fxw;

%% LOAD 

if exist(fpath_mat_fxw,'file')==2
    if do_load
        messageOut(fid_log,'Fxw mat-file exist. Loading.')
        load(fpath_mat_fxw,'fxw')
    else
        messageOut(fid_log,'Fxw mat-file exist.')
    end
    return
end

%% READ

messageOut(fid_log,'Fxw mat-file does not exist. Reading.')

% if iscell(fpath_fxw) %SMT-D3D4
    %I do not think it is needed. 
% else
fxw=D3D_io_input('read',fpath_fxw);
% end

save_check(fpath_mat_fxw,'fxw'); 

end %function