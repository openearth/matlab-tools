%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 19442 $
%$Date: 2024-02-18 18:15:01 +0100 (Sun, 18 Feb 2024) $
%$Author: chavarri $
%$Id: gdm_read_data_map_ls_Q.m 19442 2024-02-18 17:15:01Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_ls_Q.m $
%
%

function data=gdm_read_data_map_ls_E(fdir_mat,fpath_map,varname,simdef,varargin)
        
%% PARSE

% parin=inputParser;
% 
% addOptional(parin,'tim',[]);
% % addOptional(parin,'layer',[]);
% addOptional(parin,'tol_t',5/60/24);
% addOptional(parin,'pli','');
% addOptional(parin,'pliname','');
% % addOptional(parin,'dchar',''); %why did I comment this out?
% addOptional(parin,'overwrite',false);
% addOptional(parin,'branch','');
% 
% parse(parin,varargin{:});
% 
% time_dnum=parin.Results.tim;
% tol_t=parin.Results.tol_t;
% pli=parin.Results.pli;
% overwrite=parin.Results.overwrite;
% branch=parin.Results.branch;
% pliname=parin.Results.pliname;
% % dchar=parin.Results.dchar;

%%

% data_bl=gdm_read_data_map_ls(fdir_mat,fpath_map,'bl',varargin{:});
% data_h=gdm_read_data_map_ls(fdir_mat,fpath_map,'wd',varargin{:});
data_wl=gdm_read_data_map_ls(fdir_mat,fpath_map,'wl',varargin{:});
data_u=gdm_read_data_map_ls(fdir_mat,fpath_map,'ucx',varargin{:});

% val=data_bl.val+data_h.val+data_u.vel_mag.^2/s*9.81;
val=data_wl.val+data_u.vel_mag.^2/(2*9.81);

data=data_wl;
data.val=val;

end %function