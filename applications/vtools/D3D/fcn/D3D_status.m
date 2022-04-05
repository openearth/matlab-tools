%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17937 $
%$Date: 2022-04-05 13:43:41 +0200 (Tue, 05 Apr 2022) $
%$Author: chavarri $
%$Id: D3D_is_done.m 17937 2022-04-05 11:43:41Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_is_done.m $
%
%OUTPUT:
%   sta=1: not started
%   sta=2: running
%   sta=3: done

function [sta,time_comp]=D3D_status(simdef,varargin)

sta=NaN;
time_comp=NaN;

simdef=D3D_simpath(simdef);

if isfield(simdef.file,'map') || isfield(simdef.file,'his')
    sta=1; 
    return
end

is_done=D3D_is_done(simdef,varargin);

if is_done
    sta=3;
    time_comp=D3D_computation_time(simdef.file.dia);
    return 
end

sta=2; 


end %function