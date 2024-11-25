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

function data=gdm_read_data_map_ls_E(fdir_mat,fpath_map,varname,simdef,varargin)
        
%% PARSE

parin=inputParser;
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