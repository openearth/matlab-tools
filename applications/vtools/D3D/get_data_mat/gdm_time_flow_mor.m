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

function [tim_dnum_p,tim_dtime_p]=gdm_time_flow_mor(flg_loc,simdef,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime)

%% PARSE

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

if isfield(simdef.D3D,'ismor')==0
    error('I do not know whether it is morphodynamic simulation')
end

%% CALC

if flg_loc.tim_type==1
    tim_dnum_p=time_dnum;
    tim_dtime_p=time_dtime;
elseif flg_loc.tim_type==2
    if ~simdef.D3D.ismor
        messageOut(NaN,'You aim to match morphodynamic time but there the simulation is not morphodynamic. It has been changed to flow time.')
        tim_dnum_p=time_dnum;
        tim_dtime_p=time_dtime;
    else
        tim_dnum_p=time_mor_dnum;
        tim_dtime_p=time_mor_dtime;
    end
else
    error('I do not know which type of time (`tim_type`) is %d',flg_loc.tim_type)
end

end %function