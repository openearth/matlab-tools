%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%$Revision$
%$Date$
%$Author$
%$Id$
%$HeadURL$
%

function stru_out=D3D_write_obs(fname, stru_in, varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'ver',1)

parse(parin,varargin{:})

ver=parin.Results.ver;

if ver == 1; 
    delft3d_io_obs('write',fname,stru_in);
elseif ver == 2; 
    S.m = stru_in.M.'; 
    S.n = stru_in.N.'; 
    S.namst = char(stru_in.Name); 
    delft3d_io_obs('write',fname,S);
else
    error('Unknown "ver" provided to D3D_write_obs.m')
end

end