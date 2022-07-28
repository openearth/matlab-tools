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
%OUTPUT:
%   sta=1: not started
%   sta=2: running
%   sta=3: done
%   sta=4: interrupted (did not reach final time but exit controlled)

function [sta,time_comp,tgen,version,tim_ver,source]=D3D_status(simdef,varargin)

sta=NaN;
time_comp=NaT-datetime(2000,1,1); %duration
tgen=NaT;
version='';
tim_ver=NaT;
source='';

simdef=D3D_simpath(simdef);

%this can be improved seeing whether a map and his file are requested
if isfield(simdef.file,'map')==0 && isfield(simdef.file,'his')==0
    sta=1; 
    return
end

is_inter=D3D_is_interrupt(simdef,varargin);
if is_inter
    sta=4;
    time_comp=D3D_computation_time(simdef.file.dia);
    [tgen,version,tim_ver,source]=D3D_version(simdef,varargin);
    return 
end

is_done=D3D_is_done(simdef,varargin);

if is_done
    sta=3;
    time_comp=D3D_computation_time(simdef.file.dia);
    [tgen,version,tim_ver,source]=D3D_version(simdef,varargin);
    return 
end

sta=2; 
[tgen,version,tim_ver,source]=D3D_version(simdef,varargin);

end %function