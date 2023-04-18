%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18545 $
%$Date: 2022-11-15 13:06:55 +0100 (di, 15 nov 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_ls_grainsize.m 18545 2022-11-15 12:06:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_ls_grainsize.m $
%
%

function data=gdm_read_data_map_ls_Q(fdir_mat,fpath_map,varname,simdef,varargin)
        
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

data_h=gdm_read_data_map_ls(fdir_mat,fpath_map,'wd',varargin{:});
data_u=gdm_read_data_map_ls(fdir_mat,fpath_map,'ucx',varargin{:});

ds=diff(data_h.Scor)';
Q=data_h.val.*data_u.vel_perp.*ds;
data=data_h;
data.val=Q;

%if in the Scor there is a NaN, we take out the previous and itself in Scen
% bol_nan=isnan(data_h.Scor);
% bol_nan_cen=false(size(data_h.Scen));
% bol_nan_cen=bol_nan(1:end-1);
% bol_nan_cen(2:end)=bol_nan_cen(2:end) | bol_nan(1:end-2);

% scor=data_h.Scor(~bol_nan);
% ds=diff(scor);
% h=data_h.val(~bol_nan_cen);
% uperp=data_u.vel_perp(~bol_nan_cen);
% Q=h.*uperp.*ds';
% hypot(diff(varargin{1,2}(:,1)),diff(varargin{1,2}(:,2)))

end %function