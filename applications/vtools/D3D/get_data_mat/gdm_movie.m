%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18181 $
%$Date: 2022-06-20 08:15:58 +0200 (Mon, 20 Jun 2022) $
%$Author: chavarri $
%$Id: D3D_time_dnum.m 18181 2022-06-20 06:15:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_time_dnum.m $
%
%

function gdm_movie(fid_log,flg_loc,fpath_mov,time_dnum)
     
%% PARSE

if isfield(flg_loc,'do_movie')==0
    flg_loc.do_movie=1;
end

if isfield(flg_loc,'tim_movie')==0
    flg_loc.tim_movie=20; %[s] duration of the movie
end

if isfield(flg_loc,'fig_overwrite')==0
    flg_loc.fig_overwrite=0;
end

if isfield(flg_loc,'mov_overwrite')==0
    flg_loc.mov_overwrite=flg_loc.fig_overwrite;
end

if isfield(flg_loc,'rat')==0
    T=time_dnum(end)-time_dnum(1);
    flg_loc.rat=T/(flg_loc.tim_movie/24/3600); %[-] we want <rat> model seconds in each movie second
end

%%

if flg_loc.do_movie==0; return; end

%% CALC

dt_aux=diff(time_dnum);
dt=dt_aux(1)*24*3600; %[s] we have 1 frame every <dt> seconds 
make_video(fpath_mov,'frame_rate',1/dt*flg_loc.rat,'overwrite',flg_loc.mov_overwrite);
 
end %function