%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18514 $
%$Date: 2022-11-04 12:19:10 +0100 (Fri, 04 Nov 2022) $
%$Author: chavarri $
%$Id: gdm_load_grid.m 18514 2022-11-04 11:19:10Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_grid.m $
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